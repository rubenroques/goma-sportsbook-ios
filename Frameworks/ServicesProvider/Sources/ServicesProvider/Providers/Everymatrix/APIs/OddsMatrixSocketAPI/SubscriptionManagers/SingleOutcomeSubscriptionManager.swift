//
//  SingleOutcomeSubscriptionManager.swift
//  ServicesProvider
//
//  Created for single outcome subscription (betslip odds tracking)
//

import Foundation
import Combine
import SharedModels

/// Manages subscription to a single outcome's live updates via bettingOfferPublisher
///
/// This manager provides real-time updates for a single outcome by:
/// 1. Subscribing to EveryMatrix's bettingOfferPublisher WebSocket endpoint
/// 2. Maintaining a focused EntityStore for the outcome and related entities
/// 3. Building a minimal Event structure (1 market, 1 outcome) from updates
///
/// Use case: Betslip odds tracking where each betslip item needs its own subscription
class SingleOutcomeSubscriptionManager {

    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let operatorId: String

    // MARK: - Configuration
    let eventId: String
    let outcomeId: String  // This is the bettingOfferId in EveryMatrix

    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var currentSubscription: EndpointPublisherIdentifiable?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(connector: EveryMatrixSocketConnector,
         operatorId: String,
         eventId: String,
         outcomeId: String) {
        self.connector = connector
        self.eventId = eventId
        self.outcomeId = outcomeId
        self.operatorId = operatorId
    }

    deinit {
        unsubscribe()
    }

    // MARK: - Public Interface

    /// Subscribe to single outcome updates via bettingOfferPublisher
    /// Returns Event with single market containing single outcome
    func subscribe() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        print("[SingleOutcome] Starting subscription for outcomeId: \(outcomeId), eventId: \(eventId)")

        // Clean up any existing subscription
        unsubscribe()

        // Clear the store for fresh subscription
        store.clear()

        // Create the WAMP router for betting offer subscription
        let language = EveryMatrixUnifiedConfiguration.shared.defaultLanguage
        let router = WAMPRouter.bettingOfferPublisher(
            operatorId: operatorId,
            language: language,
            bettingOfferId: outcomeId
        )

        print("[SingleOutcome] Subscribing to: /sports/\(operatorId)/\(language)/bettingOffers/\(outcomeId)")

        // Subscribe to the websocket topic
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store the subscription for cleanup later
                if case .connect(let subscription) = content {
                    print("[SingleOutcome] Connected to WebSocket, subscription ID: \(subscription.identificationCode)")
                    self?.currentSubscription = subscription
                }
            })
            .compactMap { [weak self] (content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) -> SubscribableContent<Event>? in
                guard let self = self else {
                    return nil
                }

                return try? self.handleSubscriptionContent(content)
            }
            .mapError { error -> ServiceProviderError in
                print("[SingleOutcome] Subscription error: \(error)")
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }

    /// Unsubscribe from the current subscription
    func unsubscribe() {
        if let subscription = currentSubscription {
            print("[SingleOutcome] Unsubscribing from outcomeId: \(outcomeId)")
            connector.unsubscribe(subscription)
            currentSubscription = nil
        }
        cancellables.removeAll()
        store.clear()
    }

    // MARK: - Private Methods

    /// Handle subscription content and convert to domain Event model
    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<Event>? {

        switch content {
        case .connect(let publisherIdentifiable):
            print("[SingleOutcome] Connection confirmed for outcomeId: \(outcomeId)")
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            print("[SingleOutcome] Received INITIAL content for outcomeId: \(outcomeId)")
            print("[SingleOutcome] Records count: \(response.records.count)")

            // Process initial dump of single outcome data
            parseOutcomeData(from: response)

            // Build and return Event with single outcome
            if let event = buildSingleOutcomeEvent() {
                print("[SingleOutcome] Built event successfully from initial content")
                return .contentUpdate(content: event)
            }
            print("[SingleOutcome] Failed to build event from initial content")
            return nil

        case .updatedContent(let response):
            print("[SingleOutcome] Received UPDATE for outcomeId: \(outcomeId)")
            print("[SingleOutcome] Update records count: \(response.records.count)")

            // Process real-time updates for the outcome
            parseOutcomeData(from: response)

            // Rebuild Event with updated outcome data
            if let event = buildSingleOutcomeEvent() {
                print("[SingleOutcome] Built event successfully from update")
                return .contentUpdate(content: event)
            }
            print("[SingleOutcome] Failed to build event from update")
            return nil

        case .disconnect:
            print("[SingleOutcome] Disconnected from WebSocket for outcomeId: \(outcomeId)")
            // Handle disconnection
            return .disconnected
        }
    }

    /// Build Event containing single market with single outcome
    ///
    /// The store only contains data for our subscribed outcome, so the builders
    /// will naturally return a Match with one Market containing one Outcome
    private func buildSingleOutcomeEvent() -> Event? {
        print("[SingleOutcome] Building event for eventId: \(eventId), outcomeId: \(outcomeId)")

        // Log store contents for debugging
        let matchCount = store.getAll(EveryMatrix.MatchDTO.self).count
        let marketCount = store.getAll(EveryMatrix.MarketDTO.self).count
        let outcomeCount = store.getAll(EveryMatrix.OutcomeDTO.self).count
        let bettingOfferCount = store.getAll(EveryMatrix.BettingOfferDTO.self).count
        print("[SingleOutcome] Store contents: \(matchCount) matches, \(marketCount) markets, \(outcomeCount) outcomes, \(bettingOfferCount) offers")

        // Get the match DTO from store
        guard let matchDTO = store.get(EveryMatrix.MatchDTO.self, id: eventId) else {
            print("[SingleOutcome] Match DTO not found for event: \(eventId)")
            return nil
        }

        print("[SingleOutcome] Found match: \(matchDTO.name)")

        // Use MatchBuilder to build the hierarchical structure
        // The builder will automatically:
        // 1. Find markets for this match (only one in our store)
        // 2. Find outcomes for each market (only one in our store)
        // 3. Find betting offers for each outcome (what we subscribed to)
        guard let internalMatch = EveryMatrix.MatchBuilder.build(from: matchDTO, store: store) else {
            print("[SingleOutcome] Failed to build match from DTO")
            return nil
        }

        print("[SingleOutcome] Built match with \(internalMatch.markets.count) markets")
        if let market = internalMatch.markets.first {
            print("[SingleOutcome] Market has \(market.outcomes.count) outcomes")
            if let outcome = market.outcomes.first {
                print("[SingleOutcome] Outcome has \(outcome.bettingOffers.count) betting offers")
                if let offer = outcome.bettingOffers.first {
                    print("[SingleOutcome] Current odds: \(offer.odds), available: \(offer.isAvailable)")
                }
            }
        }

        // Convert internal match to domain Event model
        let event = EveryMatrixModelMapper.event(fromInternalMatch: internalMatch)
        print("[SingleOutcome] Event built successfully")
        return event
    }

    // MARK: - Outcome-Specific Parsing

    /// Parse outcome-related entities from the aggregator response
    private func parseOutcomeData(from response: EveryMatrix.AggregatorResponse) {
        var entityCounts: [String: Int] = [:]

        for record in response.records {
            switch record {
            // Store outcome and related entities
            case .outcome(let dto):
                entityCounts["OUTCOME", default: 0] += 1
                store.store(dto)
            case .bettingOffer(let dto):
                entityCounts["BETTING_OFFER", default: 0] += 1
                store.store(dto)
            case .market(let dto):
                entityCounts["MARKET", default: 0] += 1
                store.store(dto)
            case .match(let dto):
                entityCounts["MATCH", default: 0] += 1
                store.store(dto)
            case .marketInfo(let dto):
                entityCounts["MARKET_INFO", default: 0] += 1
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                entityCounts["MARKET_OUTCOME_RELATION", default: 0] += 1
                store.store(dto)

            // Store match metadata if available
            case .sport(let dto):
                entityCounts["SPORT", default: 0] += 1
                store.store(dto)
            case .location(let dto):
                entityCounts["LOCATION", default: 0] += 1
                store.store(dto)
            case .eventCategory(let dto):
                entityCounts["EVENT_CATEGORY", default: 0] += 1
                store.store(dto)
            case .tournament(let dto):
                entityCounts["TOURNAMENT", default: 0] += 1
                store.store(dto)
            case .eventInfo(let dto):
                entityCounts["EVENT_INFO", default: 0] += 1
                store.store(dto)

            // Handle change records
            case .changeRecord(let changeRecord):
                entityCounts["CHANGE_RECORD", default: 0] += 1
                handleOutcomeChangeRecord(changeRecord)

            // Ignore non-outcome entities
            case .mainMarket, .nextMatchesNumber, .marketGroup:
                break

            case .unknown:
                break
            }
        }

        // Log what we parsed
        if !entityCounts.isEmpty {
            let summary = entityCounts.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            print("[SingleOutcome] Parsed entities: \(summary)")
        }
    }

    /// Handle change records for outcome and related entities
    private func handleOutcomeChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Process changes for relevant entity types
        let relevantTypes = [
            EveryMatrix.OutcomeDTO.rawType,
            EveryMatrix.BettingOfferDTO.rawType,
            EveryMatrix.MarketDTO.rawType,
            EveryMatrix.MatchDTO.rawType,
            EveryMatrix.MarketInfoDTO.rawType,
            EveryMatrix.MarketOutcomeRelationDTO.rawType
        ]

        guard relevantTypes.contains(change.entityType) else {
            return
        }

        print("[SingleOutcome] Change record: \(change.changeType) for \(change.entityType) id: \(change.id)")

        switch change.changeType {
        case .create:
            print("[SingleOutcome] CREATE: \(change.entityType)")
            // CREATE: Store the full entity if provided
            if let entityData = change.entity {
                storeEntity(entityData)
            }

        case .update:
            // UPDATE: Merge changedProperties
            guard let changedProperties = change.changedProperties else {
                print("[SingleOutcome] UPDATE change record missing changedProperties for \(change.entityType):\(change.id)")
                return
            }

            print("[SingleOutcome] UPDATE: \(change.entityType) with properties: \(changedProperties.keys.joined(separator: ", "))")

            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)

        case .delete:
            print("[SingleOutcome] DELETE: \(change.entityType)")
            // DELETE: Remove entity from store
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }

    private func storeEntity(_ entity: EveryMatrix.EntityData) {
        switch entity {
        case .outcome(let dto):
            store.store(dto)
        case .bettingOffer(let dto):
            store.store(dto)
        case .market(let dto):
            store.store(dto)
        case .match(let dto):
            store.store(dto)
        case .marketInfo(let dto):
            store.store(dto)
        case .marketOutcomeRelation(let dto):
            store.store(dto)
        case .sport(let dto):
            store.store(dto)
        case .location(let dto):
            store.store(dto)
        case .eventCategory(let dto):
            store.store(dto)
        case .tournament(let dto):
            store.store(dto)
        case .eventInfo(let dto):
            store.store(dto)
        case .mainMarket, .nextMatchesNumber, .marketGroup:
            break
        case .unknown:
            break
        }
    }
}

// MARK: - Entity Store Access

extension SingleOutcomeSubscriptionManager {

    /// Exposes the entity store for granular outcome observations if needed
    var entityStore: EveryMatrix.EntityStore {
        return store
    }

    /// Observe changes to the subscribed outcome
    func observeOutcome() -> AnyPublisher<Outcome?, Never> {
        return store.observeOutcome(id: outcomeId)
            .compactMap { [weak self] outcomeDTO -> EveryMatrix.Outcome? in
                guard let outcomeDTO = outcomeDTO else { return nil }
                return EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalOutcome -> Outcome? in
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: internalOutcome)
            }
            .eraseToAnyPublisher()
    }
}
