//
//  PreLiveMatchesPaginator.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import Combine
import GomaPerformanceKit
import GomaLogger

struct SimpleSubscription: EndpointPublisherIdentifiable {
    var identificationCode: Int
}

/// Manages subscription to pre-live matches list structure changes and individual entity updates
/// 
/// This class provides two types of subscriptions:
/// 1. Match list structure changes: `subscribe()` - Only emits when matches are added/removed
/// 2. Individual entity updates: `subscribeToMarketUpdates()`, `subscribeToOutcomeUpdates()`, etc.
///    These provide real-time updates for specific entities (odds, market data, etc.)
class PreLiveMatchesPaginator: UnsubscriptionController {

    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let store: EveryMatrix.EntityStore

    private let operatorId: String
    
    // MARK: - Public Access
    /// Access to the entity store for granular subscriptions
    var entityStore: EveryMatrix.EntityStore {
        return store
    }

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

    // MARK: - Performance Tracking
    private var hasReceivedFirstData = false  // Track if we've received initial content (for performance tracking)

    // MARK: - Initialization
    init(connector: EveryMatrixSocketConnector,
         operatorId: String,
         sportId: String,
         initialEventLimit: Int = 10,         // Renamed parameter
         numberOfMarkets: Int = 5,
         filters: MatchesFilterOptions? = nil) {
        self.connector = connector
        self.operatorId = operatorId
        self.store = EveryMatrix.EntityStore()
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

    /// Subscribe to pre-live matches for the configured sport
    /// Returns a publisher that remains alive during pagination - internal subscriptions are recreated
    func subscribe() -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Start performance tracking for initial subscription only
        PerformanceTracker.shared.start(
            feature: .sportsData,
            layer: .api,
            metadata: [
                "type": "subscription",
                "sport": sportId,
                "initialEventLimit": "\(currentEventLimit)"
            ]
        )

        // Start the internal subscription
        startInternalSubscription()

        // Return the subject that will emit all updates (initial and paginated)
        return contentSubject.eraseToAnyPublisher()
    }

    // MARK: - Internal Subscription Management

    /// Starts or restarts the internal WAMP subscription with current configuration
    /// This can be called multiple times during pagination without breaking the external subscription
    private func startInternalSubscription() {
        print("[PreLiveMatchesPaginator] Starting internal subscription with eventLimit=\(currentEventLimit)")

        // Cancel any existing internal subscription
        internalSubscriptionCancellable?.cancel()

        // Unsubscribe from WAMP topic
        if let currentSubscriptionValue = currentSubscription {
            connector.unsubscribe(currentSubscriptionValue)
            currentSubscription = nil
        }

        // Clear store for fresh data
        store.clear()

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
                        print("[PreLiveMatchesPaginator] Internal subscription error: \(error)")

                        // End performance tracking on FIRST error only (not pagination errors)
                        if self?.hasReceivedFirstData == false {
                            self?.hasReceivedFirstData = true
                            PerformanceTracker.shared.end(
                                feature: .sportsData,
                                layer: .api,
                                metadata: [
                                    "status": "error",
                                    "error": error.localizedDescription
                                ]
                            )
                        }

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
        
        if let filters = filters {
            return WAMPRouter.customMatchesAggregatorPublisher(
                operatorId: self.operatorId,
                language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
                sportId: sportId,
                locationId: filters.location.serverRawValue,
                tournamentId: filters.tournament.serverRawValue,
                hoursInterval: filters.timeRange.serverRawValue,
                sortEventsBy: filters.sortBy.serverRawValue,
                liveStatus: "NOT_LIVE",
                eventLimit: currentEventLimit,           // Use mutable currentEventLimit
                mainMarketsLimit: numberOfMarkets,
                optionalUserId: filters.optionalUserId
            )
        } else {
            return WAMPRouter.popularMatchesPublisher(
                operatorId: self.operatorId,
                language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
                sportId: sportId,
                matchesCount: currentEventLimit          // Use mutable currentEventLimit
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
            print("[PreLiveMatchesPaginator] ⚠️ Pagination already in progress, ignoring request")
            return Just(false)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Guard: Check if we've hit the max limit
        guard currentEventLimit < maxEventLimit else {
            print("[PreLiveMatchesPaginator] ⚠️ Max event limit reached (\(maxEventLimit))")
            hasMoreEvents = false
            return Just(false)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Guard: Check if there are more events
        guard hasMoreEvents else {
            print("[PreLiveMatchesPaginator] ℹ️ No more events available")
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

        print("[PreLiveMatchesPaginator] 📄 Loading next page: \(previousLimit) → \(newLimit) events")

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
        return store.observeMarket(id: id)
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
        let realPublisher = store.observeOutcome(id: id)
            .handleEvents(receiveSubscription: { subscription in
                // print("entityStore.observeOutcome.subscription")
            }, receiveOutput: { outcome in
                // print("entityStore.observeOutcome.outcome: \(outcome)")
            }, receiveCompletion: { completion in
                // print("entityStore.observeOutcome.completion: \(completion)")
            }, receiveCancel: {
                // print("entityStore.observeOutcome.cancel")
            }, receiveRequest: { demand in
                // print("entityStore.observeOutcome.demand: \(demand)")
            })
            .map { outcomeDTO -> Outcome? in
                guard let outcomeDTO = outcomeDTO else { return nil }
                
                // Build hierarchical outcome from DTO
                guard let hierarchicalOutcome = EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store) else {
                    return nil
                }
                
                // Map internal model to domain model using existing mapper
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: hierarchicalOutcome)
            }
            .setFailureType(to: ServiceProviderError.self)
        
//        #if DEBUG
//        // Create simulation publisher with random intervals
//        let simulationPublisher = createRandomIntervalSimulationPublisher(for: id)
//        
//        // Merge real and simulated updates
//        return Publishers.Merge(realPublisher, simulationPublisher)
//            .eraseToAnyPublisher()
//        #else
//        return realPublisher.eraseToAnyPublisher()
//        #endif
        return realPublisher.eraseToAnyPublisher()
    }

    /// Subscribe to betting offer updates and return the parent Outcome with updated odds
    /// This fixes the entity mismatch where BETTING_OFFER updates don't notify OUTCOME observers
    func subscribeToBettingOfferAsOutcomeUpdates(bettingOfferId: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        GomaLogger.debug(.realtime, category: "ODDS_FLOW",
            "PreLiveMatchesPaginator.subscribeToBettingOfferAsOutcomeUpdates - SUBSCRIBING to BETTING_OFFER:\(bettingOfferId)")

        return store.observeBettingOffer(id: bettingOfferId)
            .handleEvents(receiveOutput: { bettingOfferDTO in
                if bettingOfferDTO != nil {
                    GomaLogger.info(.realtime, category: "ODDS_FLOW",
                        "PreLiveMatchesPaginator - RECEIVED BettingOfferDTO update for BETTING_OFFER:\(bettingOfferId)")
                }
            })
            .compactMap { [weak self] bettingOfferDTO -> Outcome? in
                guard let self = self,
                      let bettingOfferDTO = bettingOfferDTO else { return nil }

                // Look up parent OutcomeDTO using the foreign key
                let outcomeId = bettingOfferDTO.outcomeId
                guard let outcomeDTO = self.store.get(EveryMatrix.OutcomeDTO.self, id: outcomeId) else {
                    GomaLogger.error(.realtime, category: "ODDS_FLOW",
                        "PreLiveMatchesPaginator - Parent OUTCOME:\(outcomeId) not found for BETTING_OFFER:\(bettingOfferId)")
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
                print("[PreLiveMatchesPaginator] 🏁 Received \(matchCount) events, less than requested \(currentEventLimit) - no more pages available")
            }

            // End performance tracking on FIRST data arrival only (not pagination re-subscriptions)
            if !hasReceivedFirstData {
                hasReceivedFirstData = true
                PerformanceTracker.shared.end(
                    feature: .sportsData,
                    layer: .api,
                    metadata: [
                        "status": "subscribed",
                        "matchCount": "\(matchCount)"
                    ]
                )
            }

            // If this was a pagination request, send response based on actual data
            if let paginationSubject = paginationResponseSubject {
                print("[PreLiveMatchesPaginator] 📤 Emitting pagination response: hasMoreEvents=\(hasMoreEvents)")
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
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MarketDTO.rawType {
                // Update all market changes
                
                // TODO: check which properties we need to observe and update
                // store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MatchDTO.rawType {
                // Update all match changes
                
                // TODO: check which properties we need to observe and update
                // store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            }
            // Add more entity-specific logic as needed
            
        case .delete:
            // DELETE: Remove entity from store
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
    
    /// Store entity data from change records
    private func storeEntityData(_ entityData: EveryMatrix.EntityData) {
        switch entityData {
        case .sport(let dto):
            store.store(dto)
        case .match(let dto):
            store.store(dto)
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
        case .marketGroup(let dto):
            store.store(dto)
            
        case .unknown(let type):
            print("Unknown entity data type: \(type)")
        
        }
    }

    func unsubscribe(subscription: Subscription) {
        // 
    }
    
    #if DEBUG
    // MARK: - Simulation Helpers
    
    /// Creates a publisher that emits at random intervals between 0.3 and 3.5 seconds
    private func createRandomIntervalSimulationPublisher(for outcomeId: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        // Create a subject to emit values
        let subject = PassthroughSubject<Outcome?, ServiceProviderError>()
        
        // Function to schedule the next random emission
        func scheduleNextEmission() {
            // Random delay between 0.3 and 3.5 seconds
            let randomDelay = Double.random(in: 0.3...3.5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { [weak self] in
                guard let self = self else { return }
                
                // Get current outcome data
                guard let outcomeDTO = self.store.get(EveryMatrix.OutcomeDTO.self, id: outcomeId),
                      let outcome = EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store) else {
                    // Schedule next emission even if outcome not found
                    scheduleNextEmission()
                    return
                }
                
                // Create and emit simulated outcome
                if let simulatedOutcome = self.createSimulatedOutcome(from: outcome) {
                    subject.send(simulatedOutcome)
                }
                
                // Schedule the next emission
                scheduleNextEmission()
            }
        }
        
        // Start the emission cycle
        scheduleNextEmission()
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Creates a simulated outcome with random odds variation
    private func createSimulatedOutcome(from outcome: EveryMatrix.Outcome) -> Outcome? {
        // Get the first available betting offer
        guard let firstOffer = outcome.bettingOffers.first(where: { $0.isAvailable }) else {
            return nil
        }
        
        let currentOdds = firstOffer.odds
        let variationPercent = Double.random(in: 0.05...0.65)
        let isIncrease = Bool.random()
        let newOdds: Double
        
        if isIncrease {
            newOdds = currentOdds * (1 + variationPercent)
        } else {
            newOdds = max(1.01, currentOdds * (1 - variationPercent)) // Ensure odds don't go below 1.01
        }
        
        // Create a modified betting offer with new odds
        let modifiedOffer = EveryMatrix.BettingOffer(
            id: firstOffer.id,
            odds: newOdds,
            isAvailable: firstOffer.isAvailable,
            isLive: firstOffer.isLive,
            lastChangedTime: Date(), // Use current time for the change
            providerId: firstOffer.providerId
        )
        
        // Create a modified outcome with the new betting offer
        let modifiedOutcome = EveryMatrix.Outcome(
            id: outcome.id,
            name: outcome.name,
            shortName: outcome.shortName,
            typeName: outcome.typeName,
            code: outcome.code,
            bettingOffers: [modifiedOffer], // Use only the modified offer
            headerName: outcome.headerName,
            headerNameKey: outcome.headerNameKey,
            paramFloat1: outcome.paramFloat1
        )
                
        // Convert to public Outcome model
        return EveryMatrixModelMapper.outcome(fromInternalOutcome: modifiedOutcome)
    }
    #endif
    
}
