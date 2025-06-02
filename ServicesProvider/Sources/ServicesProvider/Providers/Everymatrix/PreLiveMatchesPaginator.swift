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

class PreLiveMatchesPaginator {

    // MARK: - Dependencies
    private let connector: EveryMatrixConnector
    private let store: EveryMatrix.EntityStore

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
         numberOfEvents: Int = 50,
         numberOfMarkets: Int = 10) {
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
        let router = WAMPRouter.popularMatchesPublisher(
            operatorId: "4093",
            language: "en",
            sportId: sportId,
            matchesCount: numberOfEvents
        )

        // Subscribe to the websocket topic
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store the subscription for cleanup later
                if case .connect(let subscription) = content {
                    self?.currentSubscription = subscription
                }
            })
            .tryMap { [weak self] (content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) -> SubscribableContent<[EventsGroup]> in
                guard let self = self else {
                    throw ServiceProviderError.unknown
                }

                return try self.handleSubscriptionContent(content)
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

    // MARK: - Private Methods

    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[EventsGroup]> {
        switch content {
        case .connect(let publisherIdentifiable):

            // Create a very simple subs with only the id
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")

            currentServiceSubscription = subscription
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            // Parse and store the flat entities
            EveryMatrix.ResponseParser.parseAndStore(response: response, in: store)

            // Convert stored entities to EventsGroup array
            let eventsGroups = buildEventsGroups()
            return .contentUpdate(content: eventsGroups)

        case .updatedContent(let response):
            // Parse and store the updated entities
            EveryMatrix.ResponseParser.parseAndStore(response: response, in: store)

            // Convert stored entities to EventsGroup array
            let eventsGroups = buildEventsGroups()
            return .contentUpdate(content: eventsGroups)

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

}

// MARK: - UnsubscriptionController Conformance
extension PreLiveMatchesPaginator: UnsubscriptionController {
    func unsubscribe(subscription: Subscription) {
        // This is called when the Subscription object is deallocated
        // We clean up our internal subscription
        unsubscribe()
    }
}
