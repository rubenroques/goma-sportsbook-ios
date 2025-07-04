//
//  LiveMatchesPaginator.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import Combine
import SharedModels


/// Manages subscription to pre-live matches list structure changes and individual entity updates
/// 
/// This class provides two types of subscriptions:
/// 1. Match list structure changes: `subscribe()` - Only emits when matches are added/removed
/// 2. Individual entity updates: `subscribeToMarketUpdates()`, `subscribeToOutcomeUpdates()`, etc.
///    These provide real-time updates for specific entities (odds, market data, etc.)
class LiveMatchesPaginator: UnsubscriptionController {

    // MARK: - Dependencies
    private let connector: EveryMatrixConnector
    private let store: EveryMatrix.EntityStore
    private let eventInfoStore: EveryMatrix.EntityStore  // Focused store for MATCH and EVENT_INFO only

    // MARK: - State Management
    private var currentSubscription: EndpointPublisherIdentifiable?
    private var currentServiceSubscription: Subscription?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Configuration
    private let sportId: String
    private let numberOfEvents: Int
    private let numberOfMarkets: Int

    // MARK: - Initialization
    init(connector: EveryMatrixConnector,
         sportId: String,
         numberOfEvents: Int = 10,
         numberOfMarkets: Int = 5) {
        self.connector = connector
        self.store = EveryMatrix.EntityStore()
        self.eventInfoStore = EveryMatrix.EntityStore()
        self.sportId = sportId
        self.numberOfEvents = numberOfEvents
        self.numberOfMarkets = numberOfMarkets
    }

    //
    deinit {
        unsubscribe()
    }

    // MARK: - Public Methods

    /// Subscribe to pre-live matches for the configured sport
    func subscribe() -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribe()

        // Clear both stores for fresh subscription
        store.clear()
        eventInfoStore.clear()

        // Create the WAMP router using the existing popularMatchesPublisher case
        // I am using this live version to better test the changes in the matches/market/outcomes
        let router = WAMPRouter.liveMatchesPublisher(
            operatorId: "4093",
            language: "en",
            sportId: sportId,
            matchesCount: numberOfEvents // 1
        )

        

        // Subscribe to the websocket topic
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store the subscription for cleanup later
                if case .connect(let subscription) = content {
                    self?.currentSubscription = subscription
                }
            })
            .compactMap { [weak self] (content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) -> SubscribableContent<[EventsGroup]>? in
                guard let self = self else {
                    return nil
                }

                return try? self.handleSubscriptionContent(content)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }

    /// Load the next page of matches (for future pagination implementation)
    func loadNextPage() -> AnyPublisher<Bool, ServiceProviderError> {
        // TODO: Implement pagination logic
        // This would involve subscribing to a different topic with updated parameters
        return Just(false)
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }

    /// Refresh the current subscription
    func refresh() -> AnyPublisher<Void, ServiceProviderError> {
        return subscribe()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Clean up subscription and resources
    func unsubscribe() {
        if let subscription = currentSubscription {
            connector.unsubscribe(subscription)
            currentSubscription = nil
        }
        currentServiceSubscription = nil
        cancellables.removeAll()
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
    
    /// Subscribe to outcome updates for a specific outcome ID
    func subscribeToOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        return store.observeOutcome(id: id)
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
            .compactMap { outcomeDTO -> EveryMatrix.Outcome? in
                guard let outcomeDTO = outcomeDTO else { return nil }
                
                // Build hierarchical outcome from DTO
                return EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store)
            }
            .map { outcome -> Outcome? in
                // Map internal model to domain model using existing mapper
                print("#DEBUG [LiveMatchesPaginator] subscribeToOutcomeUpdates outcome: \(outcome)")
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: outcome)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }
    
    
    /// Observe EVENT_INFO entities for a specific event using the focused store
    func observeEventInfosForEvent(eventId: String) -> AnyPublisher<EventLiveData, Never> {
        print("[LiveMatchesPaginator] observeEventInfosForEvent called for event: \(eventId)")
        
        return eventInfoStore.observeEventInfosForEvent(eventId: eventId)
            .map { [weak self] eventInfos in
                guard let self = self else {
                    return EventLiveData(id: eventId, homeScore: nil, awayScore: nil, matchTime: nil, status: nil, detailedScores: nil, activePlayerServing: nil)
                }
                
                // Get the match data for participant mapping
                let matchData = self.eventInfoStore.get(EveryMatrix.MatchDTO.self, id: eventId)
                
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
                // print("[LiveMatchesPaginator] 🔄 Real odds update - BettingOffer ID: \(change.id), changedProperties: \(changedProperties)")
                store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MarketDTO.rawType {
                // Update all market changes
                
                // TODO: check which properties we need to observe and update
                // store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
            } else if change.entityType == EveryMatrix.MatchDTO.rawType {
                // Update all match changes
                
                // TODO: check which properties we need to observe and update
                // store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                // eventInfoStore.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                
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
        case .unknown(let type):
            print("Unknown entity data type: \(type)")
        }
    }

    func unsubscribe(subscription: Subscription) {
        // 
    }
    
    // MARK: - Live Data Building
    
    private func buildEventLiveData(eventId: String, from eventInfos: [EveryMatrix.EventInfoDTO], matchData: EveryMatrix.MatchDTO? = nil) -> EventLiveData {
        var homeScore: Int?
        var awayScore: Int?
        var matchTimeMinutes: Int?
        var eventPartName: String? // For "1st Half", "2nd Half", etc.
        var status: EventStatus?
        var detailedScores: [String: Score] = [:]
        var activePlayerServing: ActivePlayerServe?

        for info in eventInfos {
            switch info.typeId {
            case "1": // Score
                if let eventPartName = info.eventPartName {
                    let homeValue = Int(info.paramFloat1 ?? 0)
                    let awayValue = Int(info.paramFloat2 ?? 0)
                    
                    // Determine score type based on event part name
                    let score: Score
                    if eventPartName == "Whole Match" || eventPartName.contains("Match") {
                        score = .matchFull(home: homeValue, away: awayValue)
                        // Set main scores for the event
                        homeScore = homeValue
                        awayScore = awayValue
                    } else if eventPartName.contains("Set") {
                        // Extract set number if possible
                        let setIndex = extractSetIndex(from: eventPartName)
                        score = .set(index: setIndex, home: homeValue, away: awayValue)
                    } else {
                        // Game part (current game within a set)
                        score = .gamePart(home: homeValue, away: awayValue)
                    }
                    
                    detailedScores[eventPartName] = score
                }
                
            case "37": // Serve
                if let participantId = info.paramParticipantId1,
                   let match = matchData {
                    // Determine if serving participant is home or away
                    if participantId == match.homeParticipantId {
                        activePlayerServing = .home
                    } else if participantId == match.awayParticipantId {
                        activePlayerServing = .away
                    }
                    // If participantId doesn't match either, leave activePlayerServing as nil
                }
                
            case "92": // Current event status
                if let statusName = info.paramEventStatusName1?.lowercased() {
                    switch statusName {
                    case "not started", "not_started":
                        status = .notStarted
                    case "ended", "finished":
                        status = .ended(info.paramEventPartName1 ?? statusName)
                    default:
                        status = .inProgress(info.paramEventPartName1 ?? statusName)
                    }
                }
                
            case "95": // Match Time
                if let minutes = info.paramFloat1 {
                    matchTimeMinutes = Int(minutes)
                }
                
            // case "51": // Number of event parts (could indicate current set/period)
            //    break
                
            case "278": // Played at
                // Additional context information
                break
                
            default:
                // Handle other EVENT_INFO types as needed
                print("    - Unknown EVENT_INFO typeId: \(info.typeId)")
                print("      - paramFloat1: \(info.paramFloat1 ?? -1)")
                print("      - paramFloat2: \(info.paramFloat2 ?? -1)")
                print("      - eventPartName: \(info.eventPartName ?? "nil")")
                break
            }
        }

        return EventLiveData(
            id: eventId,
            homeScore: homeScore,
            awayScore: awayScore,
            matchTime: matchTimeMinutes != nil ? "\(matchTimeMinutes!)" : nil,
            status: status,
            detailedScores: detailedScores.isEmpty ? nil : detailedScores,
            activePlayerServing: activePlayerServing
        )
    }
    
    private func extractSetIndex(from eventPartName: String) -> Int {
        // Extract set number from strings like "1st Set", "2nd Set", etc.
        let numbers = eventPartName.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        return numbers.first ?? 1
    }
    
}
