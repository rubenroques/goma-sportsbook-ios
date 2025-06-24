//
//  PreLiveMatchesPaginator.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import Combine


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
    private let connector: EveryMatrixConnector
    private let store: EveryMatrix.EntityStore

    // MARK: - Public Access
    /// Access to the entity store for granular subscriptions
    var entityStore: EveryMatrix.EntityStore {
        return store
    }

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

        // Clear the store for fresh subscription
        store.clear()

        // Create the WAMP router using the existing popularMatchesPublisher case
        // I am using this live version to better test the changes in the matches/market/outcomes
        // TODO: revert to popularMatchesPublisher when the changes are tested
        let router = WAMPRouter.popularMatchesPublisher( // liveMatchesPublisher( // ) popularMatchesPublisher(
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
            .compactMap { outcome -> Outcome? in
                // Map internal model to domain model using existing mapper
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: outcome)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }
    
    /// Check if an outcome with the given ID exists in this paginator's store
    func outcomeExists(id: String) -> Bool {
        return store.get(EveryMatrix.OutcomeDTO.self, id: id) != nil
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

    /// Build hierarchical matches from stored flat entities
    private func buildHierarchicalMatches() -> [EveryMatrix.Match] {
        let matchDTOs = store.getAll(EveryMatrix.MatchDTO.self)
        return matchDTOs.compactMap { matchDTO in
            EveryMatrix.MatchBuilder.build(from: matchDTO, store: store)
        }
    }

    /// Build EventsGroups from stored entities
    private func buildEventsGroups() -> [EventsGroup] {
        let hierarchicalMatches = buildHierarchicalMatches()

        // Group matches by competition/category for better organization
        return EveryMatrixModelMapper.eventsGroups(
            fromInternalMatches: hierarchicalMatches,
            groupByCategory: true
        )
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
        case .unknown(let type):
            print("Unknown entity data type: \(type)")
        
        }
    }

    func unsubscribe(subscription: Subscription) {
        // 
    }
}
