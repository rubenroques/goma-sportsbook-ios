//
//  LiveMatchesPaginator.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import Combine
import SharedModels
import GomaLogger

/// Manages subscription to pre-live matches list structure changes and individual entity updates
/// 
/// This class provides two types of subscriptions:
/// 1. Match list structure changes: `subscribe()` - Only emits when matches are added/removed
/// 2. Individual entity updates: `subscribeToMarketUpdates()`, `subscribeToOutcomeUpdates()`, etc.
///    These provide real-time updates for specific entities (odds, market data, etc.)
class LiveMatchesPaginator: UnsubscriptionController {

    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let store: EveryMatrix.EntityStore
    private let eventInfoStore: EveryMatrix.EntityStore  // Focused store for MATCH and EVENT_INFO only

    // MARK: - State Management
    private var currentSubscription: EndpointPublisherIdentifiable?
    private var currentServiceSubscription: Subscription?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Pagination Publisher (NEW)
    /// PassthroughSubject that keeps the external subscription alive during pagination
    /// When loadNextPage() is called, we recreate internal subscriptions but emit via this subject
    private let contentSubject = PassthroughSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>()

    /// Internal subscription to WAMP that can be recreated during pagination
    private var internalSubscriptionCancellable: AnyCancellable?

    // MARK: - Configuration
    private let sportId: String
    private var currentEventLimit: Int        // Changed from immutable numberOfEvents
    private let eventLimitIncrement = 10      // Pagination increment
    private let maxEventLimit = 100           // Safety limit
    private let numberOfMarkets: Int
    private let filters: MatchesFilterOptions?

    // MARK: - Pagination State (NEW)
    private var isPaginationInProgress = false
    private var hasMoreEvents = true          // Assume true until proven otherwise

    /// Subject to emit pagination response when data arrives
    /// This allows loadNextPage() to return accurate boolean based on actual server response
    private var paginationResponseSubject: PassthroughSubject<Bool, ServiceProviderError>?

    // MARK: - Initialization
    init(connector: EveryMatrixSocketConnector,
         sportId: String,
         initialEventLimit: Int = 10,         // Renamed parameter
         numberOfMarkets: Int = 5,
         filters: MatchesFilterOptions? = nil) {
        self.connector = connector
        self.store = EveryMatrix.EntityStore()
        self.eventInfoStore = EveryMatrix.EntityStore()
        self.sportId = sportId
        self.currentEventLimit = initialEventLimit
        self.numberOfMarkets = numberOfMarkets
        self.filters = filters
    }

    //
    deinit {
        unsubscribe()
    }

    // MARK: - Public Methods

    /// Subscribe to live matches for the configured sport
    /// Returns a publisher that remains alive during pagination - internal subscriptions are recreated
    func subscribe() -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Start the internal subscription
        startInternalSubscription()

        // Return the subject that will emit all updates (initial and paginated)
        return contentSubject.eraseToAnyPublisher()
    }

    // MARK: - Internal Subscription Management

    /// Starts or restarts the internal WAMP subscription with current configuration
    /// This can be called multiple times during pagination without breaking the external subscription
    private func startInternalSubscription() {
        print("[LiveMatchesPaginator] Starting internal subscription with eventLimit=\(currentEventLimit)")

        // Cancel any existing internal subscription
        internalSubscriptionCancellable?.cancel()

        // Unsubscribe from WAMP topic
        if let currentSubscriptionValue = currentSubscription {
            connector.unsubscribe(currentSubscriptionValue)
            currentSubscription = nil
        }

        // Clear both stores for fresh data
        store.clear()
        eventInfoStore.clear()

        // Build router with current event limit
        let router = buildTopic()

        // Subscribe to WAMP and forward all events to contentSubject
        internalSubscriptionCancellable = connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription ID for cleanup
                if case .connect(let subscription) = content {
                    self?.currentSubscription = subscription
                }
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("[LiveMatchesPaginator] Internal subscription error: \(error)")

                        // Emit error to pagination subject if waiting
                        if let paginationSubject = self?.paginationResponseSubject {
                            paginationSubject.send(completion: .failure(error))
                            self?.paginationResponseSubject = nil
                        }

                        self?.contentSubject.send(completion: .failure(error))
                    }
                },
                receiveValue: { [weak self] wampContent in
                    self?.handleWAMPContent(wampContent)
                }
            )
    }

    /// Build WAMP router with current configuration
    private func buildTopic() -> WAMPRouter {
        
        let operatorId = EveryMatrixUnifiedConfiguration.shared.operatorId
        
        // Use custom aggregator if filters are provided
        if let filters = filters {
            return WAMPRouter.customMatchesAggregatorPublisher(
                operatorId: operatorId,
                language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
                sportId: sportId,
                locationId: filters.location.serverRawValue,
                tournamentId: filters.tournament.serverRawValue,
                hoursInterval: filters.timeRange.serverRawValue,
                sortEventsBy: filters.sortBy.serverRawValue,
                liveStatus: "LIVE",                           // Live matches only
                eventLimit: currentEventLimit,                // Use mutable currentEventLimit
                mainMarketsLimit: numberOfMarkets,
                optionalUserId: filters.optionalUserId
            )
        } else {
            // Fallback to simple live matches endpoint
            return WAMPRouter.liveMatchesPublisher(
                operatorId: operatorId,
                language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
                sportId: sportId,
                matchesCount: currentEventLimit               // Use mutable currentEventLimit
            )
        }
    }

    /// Handle WAMP content and forward to contentSubject
    private func handleWAMPContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) {
        guard let subscribableContent = try? handleSubscriptionContent(content) else {
            return
        }

        // Forward to external subscribers via contentSubject
        contentSubject.send(subscribableContent)
    }

    /// Load the next page of matches
    /// Increments eventLimit and re-subscribes with new limit
    /// Returns Publisher that emits true/false when data arrives (not immediately)
    /// - true: Pagination succeeded and more events might be available
    /// - false: End of data reached (no more events available)
    func loadNextPage() -> AnyPublisher<Bool, ServiceProviderError> {
        // Guard: Check if pagination is already in progress
        guard !isPaginationInProgress else {
            print("[LiveMatchesPaginator] ⚠️ Pagination already in progress, ignoring request")
            return Just(false)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Guard: Check if we've hit the max limit
        guard currentEventLimit < maxEventLimit else {
            print("[LiveMatchesPaginator] ⚠️ Max event limit reached (\(maxEventLimit))")
            hasMoreEvents = false
            return Just(false)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Guard: Check if there are more events
        guard hasMoreEvents else {
            print("[LiveMatchesPaginator] ℹ️ No more events available")
            return Just(false)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Cancel any pending pagination request
        if let previousSubject = paginationResponseSubject {
            previousSubject.send(completion: .finished)
            paginationResponseSubject = nil
        }

        // Calculate new limit
        let previousLimit = currentEventLimit
        let newLimit = min(currentEventLimit + eventLimitIncrement, maxEventLimit)

        print("[LiveMatchesPaginator] 📄 Loading next page: \(previousLimit) → \(newLimit) events")

        // Create subject to emit response when data arrives
        let responseSubject = PassthroughSubject<Bool, ServiceProviderError>()
        paginationResponseSubject = responseSubject

        // Update state
        isPaginationInProgress = true
        currentEventLimit = newLimit

        // Re-subscribe with new limit
        // This will trigger new data to flow through contentSubject
        // When data arrives, handleSubscriptionContent() will emit response through responseSubject
        startInternalSubscription()

        // Return subject that will emit when actual data arrives
        return responseSubject.eraseToAnyPublisher()
    }

    /// Refresh the current subscription
    func refresh() -> AnyPublisher<Void, ServiceProviderError> {
        return subscribe()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Clean up subscription and resources
    func unsubscribe() {
        // Cancel internal subscription
        internalSubscriptionCancellable?.cancel()
        internalSubscriptionCancellable = nil

        // Unsubscribe from WAMP topic
        if let subscription = currentSubscription {
            connector.unsubscribe(subscription)
            currentSubscription = nil
        }

        currentServiceSubscription = nil
        cancellables.removeAll()
    }

    // MARK: - Public State Access

    /// Check if more pages can be loaded
    func canLoadMore() -> Bool {
        return hasMoreEvents &&
               currentEventLimit < maxEventLimit &&
               !isPaginationInProgress
    }

    /// Get current number of matches in store
    func getCurrentEventCount() -> Int {
        return store.getAll(EveryMatrix.MatchDTO.self).count
    }

    /// Get current event limit (page size)
    func getCurrentEventLimit() -> Int {
        return currentEventLimit
    }
    
    // MARK: - Individual Entity Subscriptions
    
    /// Check if an outcome with the given ID exists in this paginator's store
    func marketExists(id: String) -> Bool {
        return store.get(EveryMatrix.MarketDTO.self, id: id) != nil
    }
    
    /// Subscribe to market updates for a specific market ID
    func subscribeToMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {
        GomaLogger.debug(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToMarketUpdates - CREATING subscription for MARKET:\(id)")
        return store.observeMarket(id: id)
            .handleEvents(receiveOutput: { marketDTO in
                if marketDTO != nil {
                    GomaLogger.info(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToMarketUpdates - RECEIVED MarketDTO update for MARKET:\(id)")
                }
            })
            .compactMap { marketDTO -> EveryMatrix.Market? in
                guard let marketDTO = marketDTO else { return nil }

                // Build hierarchical market from DTO
                return EveryMatrix.MarketBuilder.build(from: marketDTO, store: self.store)
            }
            .compactMap { market -> Market? in
                // Map internal model to domain model using existing mapper
                return EveryMatrixModelMapper.market(fromInternalMarket: market)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }
    
    /// Check if an outcome with the given ID exists in this paginator's store
    func outcomeExists(id: String) -> Bool {
        return store.get(EveryMatrix.OutcomeDTO.self, id: id) != nil
    }

    /// Check if a betting offer with the given ID exists in this paginator's store
    func bettingOfferExists(id: String) -> Bool {
        return store.get(EveryMatrix.BettingOfferDTO.self, id: id) != nil
    }

    /// Subscribe to outcome updates for a specific outcome ID
    func subscribeToOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        GomaLogger.debug(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToOutcomeUpdates - CREATING subscription for OUTCOME:\(id)")
        return store.observeOutcome(id: id)
            .handleEvents(receiveSubscription: { _ in
                GomaLogger.debug(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToOutcomeUpdates - SUBSCRIPTION active for OUTCOME:\(id)")
            }, receiveOutput: { outcomeDTO in
                if outcomeDTO != nil {
                    GomaLogger.info(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToOutcomeUpdates - RECEIVED OutcomeDTO update for OUTCOME:\(id)")
                }
            }, receiveCancel: {
                GomaLogger.debug(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.subscribeToOutcomeUpdates - CANCELLED subscription for OUTCOME:\(id)")
            })
            .compactMap { outcomeDTO -> EveryMatrix.Outcome? in
                guard let outcomeDTO = outcomeDTO else { return nil }

                // Build hierarchical outcome from DTO
                return EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store)
            }
            .map { outcome -> Outcome? in
                // Map internal model to domain model using existing mapper
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: outcome)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }

    /// Subscribe to betting offer updates and return the parent Outcome with updated odds
    /// This fixes the entity mismatch where BETTING_OFFER updates don't notify OUTCOME observers
    func subscribeToBettingOfferAsOutcomeUpdates(bettingOfferId: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        GomaLogger.debug(.realtime, category: "ODDS_FLOW",
            "LiveMatchesPaginator.subscribeToBettingOfferAsOutcomeUpdates - SUBSCRIBING to BETTING_OFFER:\(bettingOfferId)")

        return store.observeBettingOffer(id: bettingOfferId)
            .handleEvents(receiveOutput: { bettingOfferDTO in
                if bettingOfferDTO != nil {
                    GomaLogger.info(.realtime, category: "ODDS_FLOW",
                        "LiveMatchesPaginator - RECEIVED BettingOfferDTO update for BETTING_OFFER:\(bettingOfferId)")
                }
            })
            .compactMap { [weak self] bettingOfferDTO -> Outcome? in
                guard let self = self,
                      let bettingOfferDTO = bettingOfferDTO else { return nil }

                // Look up parent OutcomeDTO using the foreign key
                let outcomeId = bettingOfferDTO.outcomeId
                guard let outcomeDTO = self.store.get(EveryMatrix.OutcomeDTO.self, id: outcomeId) else {
                    GomaLogger.error(.realtime, category: "ODDS_FLOW",
                        "LiveMatchesPaginator - Parent OUTCOME:\(outcomeId) not found for BETTING_OFFER:\(bettingOfferId)")
                    return nil
                }

                // Build hierarchical Outcome with updated BettingOffers
                guard let internalOutcome = EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store) else {
                    return nil
                }

                // Map to domain Outcome
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: internalOutcome)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }

    /// Observe EVENT_INFO entities for a specific event using the focused store
    func observeEventInfosForEvent(eventId: String) -> AnyPublisher<EventLiveData, Never> {
        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "LiveMatchesPaginator.observeEventInfosForEvent called for event: \(eventId)")

        return eventInfoStore.observeEventInfosForEvent(eventId: eventId)
            .map { [weak self] eventInfos in
                guard let self = self else {
                    return EventLiveData(id: eventId, homeScore: nil, awayScore: nil, matchTime: nil, status: nil, detailedScores: nil, activePlayerServing: nil)
                }

                GomaLogger.debug(.realtime, category: "LIVE_SCORE", "Received \(eventInfos.count) EventInfos for event: \(eventId)")

                // Log each EventInfo type
                for info in eventInfos {
                    let typeName: String
                    switch info.typeId {
                    case "1": typeName = "SCORE"
                    case "2": typeName = "YELLOW_CARDS"
                    case "3": typeName = "YELLOW_RED_CARDS"
                    case "4": typeName = "RED_CARDS"
                    case "37": typeName = "SERVE"
                    case "92": typeName = "EVENT_STATUS"
                    case "95": typeName = "MATCH_TIME"
                    default: typeName = "UNKNOWN(\(info.typeId))"
                    }
                    GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - EventInfo typeId=\(info.typeId) (\(typeName))")
                }

                // Get the match data for participant mapping
                let matchData = self.eventInfoStore.get(EveryMatrix.MatchDTO.self, id: eventId)

                if let match = matchData {
                    GomaLogger.debug(.realtime, category: "LIVE_SCORE", "Match data found: \(match.homeParticipantName) vs \(match.awayParticipantName)")
                } else {
                    GomaLogger.debug(.realtime, category: "LIVE_SCORE", "No match data found for event: \(eventId)")
                }

                return self.buildEventLiveData(eventId: eventId, from: eventInfos, matchData: matchData)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods

    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[EventsGroup]>? {
        switch content {
        case .connect(let publisherIdentifiable):

            // Create a very simple subs with only the id
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")

            currentServiceSubscription = subscription
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            // Parse and store the flat entities (MATCH, MARKET, OUTCOME, BETTING_OFFER, and related entities)
            parseMatchesData(from: response)

            // Convert stored entities to EventsGroup array
            let eventsGroups = buildEventsGroups()

            // Check if we received fewer events than requested (end of data detection)
            let matchCount = store.getAll(EveryMatrix.MatchDTO.self).count
            if matchCount < currentEventLimit {
                hasMoreEvents = false
                print("[LiveMatchesPaginator] 🏁 Received \(matchCount) events, less than requested \(currentEventLimit) - no more pages available")
            }

            // If this was a pagination request, send response based on actual data
            if let paginationSubject = paginationResponseSubject {
                print("[LiveMatchesPaginator] 📤 Emitting pagination response: hasMoreEvents=\(hasMoreEvents)")
                paginationSubject.send(hasMoreEvents)  // true if more data, false if end
                paginationSubject.send(completion: .finished)
                paginationResponseSubject = nil
            }

            // Reset pagination state
            isPaginationInProgress = false

            return .contentUpdate(content: eventsGroups)

        case .updatedContent(let response):
            // OPTIMIZATION: Only rebuild EventsGroups if match list structure changes
            // This prevents excessive UI updates for odds/market/outcome changes

            // Get match IDs before update
            let matchIdsBeforeUpdate = Set(store.getAll(EveryMatrix.MatchDTO.self).map { $0.id })

            // Parse and store the updated entities (MATCH, MARKET, OUTCOME, BETTING_OFFER, and related entities)
            parseMatchesData(from: response)

            // Get match IDs after update
            let matchIdsAfterUpdate = Set(store.getAll(EveryMatrix.MatchDTO.self).map { $0.id })

            // Check if match list structure changed (added or removed matches)
            if matchIdsBeforeUpdate != matchIdsAfterUpdate {
                // Match list changed, rebuild and send update
                let eventsGroups = buildEventsGroups()
                return .contentUpdate(content: eventsGroups)
            }
            
            // Only content changed (odds, markets, etc.), don't emit any update
            // Store is already updated, individual entity subscriptions will work
            return nil
            
        case .disconnect:
            return .disconnected
        }
    }

    // MARK: - Future Methods for Hierarchical Data Building

    /// Build hierarchical matches from stored flat entities in original order
    private func buildHierarchicalMatches() -> [EveryMatrix.Match] {
        let matchDTOs = store.getAllInOrder(EveryMatrix.MatchDTO.self)
        return matchDTOs.compactMap { matchDTO in
            EveryMatrix.MatchBuilder.build(from: matchDTO, store: store)
        }
    }

    /// Build EventsGroups from stored entities
    private func buildEventsGroups() -> [EventsGroup] {
        let hierarchicalMatches = buildHierarchicalMatches()

        if hierarchicalMatches.isEmpty {
            return []
        }
        
        // Extract main markets from store and filter by sport
        let mainMarkets = extractMainMarketsForSport()
        
        // Create EventsGroup with main markets
        return [EveryMatrixModelMapper.eventsGroup(fromInternalMatches: hierarchicalMatches, mainMarkets: mainMarkets)]
    }
    
    /// Extract and convert main markets for the current sport in original API order
    private func extractMainMarketsForSport() -> [MainMarket]? {
        let allMainMarketsInOrder = store.getAllInOrder(EveryMatrix.MainMarketDTO.self)
        let filteredMainMarkets = allMainMarketsInOrder.filter { $0.sportId == sportId }
        
        if filteredMainMarkets.isEmpty {
            return nil
        }
        
        return filteredMainMarkets.map { mainMarketDTO in
            EveryMatrixModelMapper.mainMarket(fromInternalMainMarket: mainMarketDTO)
        }
    }

    /// Convert hierarchical matches to EventsGroup (to be implemented later)
    private func convertMatchesToEventsGroups(_ matches: [EveryMatrix.Match]) -> [EventsGroup] {
        // This method is now replaced by buildEventsGroups()
        return EveryMatrixModelMapper.eventsGroups(fromInternalMatches: matches)
    }
    
    // MARK: - Matches-Specific Parsing
    
    /// Parse only MATCH, MARKET, OUTCOME, BETTING_OFFER and related entities from the aggregator response
    private func parseMatchesData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            // INITIAL_DUMP records - only process match-related entities
            case .sport(let dto):
                store.store(dto)
            case .match(let dto):
                store.store(dto)
                eventInfoStore.store(dto)  // Also store in eventInfo store
            case .market(let dto):
                store.store(dto)
            case .outcome(let dto):
                store.store(dto)
            case .bettingOffer(let dto):
                store.store(dto)
            case .location(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                store.store(dto)
            case .mainMarket(let dto):
                store.store(dto)
            case .marketInfo(let dto):
                store.store(dto)
            case .nextMatchesNumber(let dto):
                store.store(dto)
            case .tournament(let dto):
                store.store(dto)
            case .eventInfo(let dto):
                store.store(dto)
                eventInfoStore.store(dto)  // Also store in eventInfo store
            case .marketGroup(let dto):
                store.store(dto)
                
            // UPDATE/DELETE/CREATE records - only process match-related changes
            case .changeRecord(let changeRecord):
                handleMatchesChangeRecord(changeRecord)
                
            case .unknown(let type):
                print("Unknown match-related entity type: \(type)")
                // Ignore unknown non-match entities
            }
        }
    }
    
    /// Handle change records for match-related entities only
    private func handleMatchesChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        
        switch change.changeType {
        case .create:
            // CREATE: Store the full entity if provided
            if let entityData = change.entity {
                storeEntityData(entityData)
            }
            
        case .update:
            // UPDATE: Merge changedProperties
            guard let changedProperties = change.changedProperties else {
                print("UPDATE change record missing changedProperties for \(change.entityType):\(change.id)")
                return
            }
            
            // Apply custom update logic based on entity type
            if change.entityType == EveryMatrix.BettingOfferDTO.rawType && changedProperties.keys.contains("odds") {
                // Only update betting offers with odds changes
                GomaLogger.info(.realtime, category: "ODDS_FLOW", "LiveMatchesPaginator.handleMatchesChangeRecord - ODDS UPDATE received for BettingOffer:\(change.id)")
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MarketDTO.rawType {
                // Update all market changes
                
                // TODO: check which properties we need to observe and update
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MatchDTO.rawType {
                // Update all match changes
                
                // TODO: check which properties we need to observe and update
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                eventInfoStore.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.EventInfoDTO.rawType {
                // Update EVENT_INFO changes - these are live data updates (scores, time, status)
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                eventInfoStore.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            }
            // Add more entity-specific logic as needed
            
        case .delete:
            // DELETE: Remove entity from store
            store.deleteEntity(type: change.entityType, id: change.id)
            
            // Also delete from eventInfoStore if it's a MATCH or EVENT_INFO
            if change.entityType == EveryMatrix.MatchDTO.rawType || 
               change.entityType == EveryMatrix.EventInfoDTO.rawType {
                eventInfoStore.deleteEntity(type: change.entityType, id: change.id)
            }
        }
    }
    
    /// Store entity data from change records
    private func storeEntityData(_ entityData: EveryMatrix.EntityData) {
        switch entityData {
        case .sport(let dto):
            store.store(dto)
        case .match(let dto):
            store.store(dto)
            eventInfoStore.store(dto)  // Also store in eventInfo store
        case .market(let dto):
            store.store(dto)
        case .outcome(let dto):
            store.store(dto)
        case .bettingOffer(let dto):
            store.store(dto)
        case .location(let dto):
            store.store(dto)
        case .eventCategory(let dto):
            store.store(dto)
        case .marketOutcomeRelation(let dto):
            store.store(dto)
        case .mainMarket(let dto):
            store.store(dto)
        case .marketInfo(let dto):
            store.store(dto)
        case .nextMatchesNumber(let dto):
            store.store(dto)
        case .tournament(let dto):
            store.store(dto)
        case .eventInfo(let dto):
            store.store(dto)
            eventInfoStore.store(dto)  // Also store in eventInfo store
        case .marketGroup(let dto):
            store.store(dto)
        case .unknown(let type):
            print("Unknown entity data type: \(type)")
        }
    }

    func unsubscribe(subscription: Subscription) {
        // 
    }
    
    // MARK: - Live Data Building

    /// Build EventLiveData from EventInfo DTOs
    /// Delegates to shared EventLiveDataBuilder for consistent transformation logic
    private func buildEventLiveData(eventId: String, from eventInfos: [EveryMatrix.EventInfoDTO], matchData: EveryMatrix.MatchDTO? = nil) -> EventLiveData {
        // Delegate to shared EventLiveDataBuilder for consistent transformation logic
        // This builder implements the full web app EVENT_INFO processing:
        // - 48 sports via template system (BASIC, SIMPLE, DETAILED, DEFAULT)
        // - 7 EVENT_INFO types: SCORE, YELLOW_CARDS, YELLOW_RED_CARDS, RED_CARDS, SERVE, EVENT_STATUS, MATCH_TIME
        // - Pattern-based score part matching (quarters, periods, innings, sets, games)
        // - Participant ID mapping for correct home/away assignment
        return EventLiveDataBuilder.buildEventLiveData(
            eventId: eventId,
            from: eventInfos,
            matchData: matchData
        )
    }

}
