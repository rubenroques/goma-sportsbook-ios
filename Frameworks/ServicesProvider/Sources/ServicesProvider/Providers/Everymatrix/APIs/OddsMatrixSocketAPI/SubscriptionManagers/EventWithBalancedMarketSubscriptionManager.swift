//
//  EventWithBalancedMarketSubscriptionManager.swift
//  ServicesProvider
//
//  Created on 2025-09-30.
//

import Foundation
import Combine
import SharedModels

/// Manages subscription to an event with its most balanced market for a given betting type + event part combination
///
/// This manager subscribes to the EveryMatrix balanced market endpoint which returns:
/// - Full event details (teams, scores, live data, status)
/// - Single "most balanced" market for the specified betting type and event part
///
/// The specific market returned may change over time as EveryMatrix rebalances odds.
/// Topic format: /sports/{op}/{lang}/{eventId}/match-odds/{bettingType}-{eventPartId}
class EventWithBalancedMarketSubscriptionManager {

    // MARK: - Dependencies (Full DI)
    private let connector: EveryMatrixSocketConnector
    private let eventId: String
    private let bettingTypeId: String
    private let eventPartId: String
    private let operatorId: String
    private let language: String

    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var balancedMarketSubscription: EndpointPublisherIdentifiable?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        connector: EveryMatrixSocketConnector,
        eventId: String,
        bettingTypeId: String,
        eventPartId: String,
        operatorId: String,
        language: String = "en"
    ) {
        self.connector = connector
        self.eventId = eventId
        self.bettingTypeId = bettingTypeId
        self.eventPartId = eventPartId
        self.operatorId = operatorId
        self.language = language
    }

    deinit {
        unsubscribe()
    }

    // MARK: - Public Interface

    /// Subscribe to event with balanced market updates
    ///
    /// Returns Event with:
    /// - Full event details (teams, scores, status, live data)
    /// - Single market in markets array (the most balanced for betting type + event part)
    func subscribe() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribe()

        // Subscribe to balanced market endpoint with hyphen separator
        // Topic: /sports/{op}/{lang}/{eventId}/match-odds/{bettingType}-{eventPartId}
        let router = WAMPRouter.matchBalancedMarketOdds(
            operatorId: operatorId,
            language: language,
            matchId: eventId,
            bettingType: bettingTypeId,
            eventPartId: eventPartId
        )

        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.balancedMarketSubscription = subscription
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<Event>? in
                return try? self?.handleBalancedMarketContent(content)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }

    /// Clean up all subscriptions and resources
    func unsubscribe() {
        if let subscription = balancedMarketSubscription {
            connector.unsubscribe(subscription)
            balancedMarketSubscription = nil
        }
        cancellables.removeAll()
        store.clear()
    }

    // MARK: - Private Methods

    private func handleBalancedMarketContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<Event>? {
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            // Process initial dump of event + balanced market
            parseBalancedMarketData(from: response)

            // Build and return event with single market
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil

        case .updatedContent(let response):
            // Process real-time updates (odds changes, market switches, event updates)
            parseBalancedMarketData(from: response)

            // Rebuild and return updated event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil

        case .disconnect:
            return .disconnected
        }
    }

    // MARK: - Data Parsing

    private func parseBalancedMarketData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            // Event-related entities
            case .match(let dto):
                store.store(dto)
            case .eventInfo(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .tournament(let dto):
                store.store(dto)
            case .location(let dto):
                store.store(dto)
            case .sport(let dto):
                store.store(dto)

            // Market-related entities (single balanced market)
            case .market(let dto):
                store.store(dto)
            case .outcome(let dto):
                store.store(dto)
            case .bettingOffer(let dto):
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                store.store(dto)
            case .marketInfo(let dto):
                store.store(dto)
            case .mainMarket(let dto):
                store.store(dto)
            case .marketGroup(let dto):
                store.store(dto)

            // Handle change records for real-time updates
            case .changeRecord(let changeRecord):
                handleChangeRecord(changeRecord)

            case .nextMatchesNumber(let dto):
                store.store(dto)
            case .unknown:
                break
            }
        }
    }

    private func handleChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        switch change.changeType {
        case .create:
            if let entityData = change.entity {
                storeEntity(entityData)
            }

        case .update:
            guard let changedProperties = change.changedProperties else {
                return
            }
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)

        case .delete:
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }

    private func storeEntity(_ entity: EveryMatrix.EntityData) {
        switch entity {
        case .match(let dto):
            store.store(dto)
        case .eventInfo(let dto):
            store.store(dto)
        case .eventCategory(let dto):
            store.store(dto)
        case .tournament(let dto):
            store.store(dto)
        case .location(let dto):
            store.store(dto)
        case .sport(let dto):
            store.store(dto)
        case .market(let dto):
            store.store(dto)
        case .outcome(let dto):
            store.store(dto)
        case .bettingOffer(let dto):
            store.store(dto)
        case .marketOutcomeRelation(let dto):
            store.store(dto)
        case .marketInfo(let dto):
            store.store(dto)
        case .mainMarket(let dto):
            store.store(dto)
        case .marketGroup(let dto):
            store.store(dto)
        case .nextMatchesNumber(let dto):
            store.store(dto)
        case .unknown:
            break
        }
    }

    // MARK: - Data Building

    private func buildEvent() -> Event? {
        // Get the match DTO
        guard let matchDTO = store.get(EveryMatrix.MatchDTO.self, id: eventId) else {
            return nil
        }

        // Build hierarchical match with all related data
        guard let internalMatch = EveryMatrix.MatchBuilder.build(from: matchDTO, store: store) else {
            return nil
        }

        // Convert to domain Event model
        // The Event will contain exactly one market (the balanced one) in its markets array
        return EveryMatrixModelMapper.event(fromInternalMatch: internalMatch)
    }
}
