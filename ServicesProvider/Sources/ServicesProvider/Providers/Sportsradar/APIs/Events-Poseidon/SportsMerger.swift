//
//  SportsMerger.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 20/02/2025.
//

import Foundation
import Combine

// Responsible for merging sports data from different sources while maintaining proper counting and IDs
final class SportsMerger {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let session = URLSession.init(configuration: .default)

    private var sportsCurrentValueSubject: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError> = .init(.disconnected)

    // Content identifiers
    private let liveSportsIdentifier: ContentIdentifier
    private let allSportsIdentifier: ContentIdentifier

    // Subscriptions
    private var liveSportsSubscription: Subscription? // TODO: SP should be weak to avoid retain c
    private var allSportsSubscription: Subscription? // TODO: SP should be weak to avoid retain c

    private let sessionToken: String
    private var waitingSubscription = true

    // Only keep live counts state
    private var liveSportsCounts: [String: Int] = [:]

    var isActive: Bool {
        return true
    }

    // MARK: - Public Interface
    var sportsPublisher: AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        return sportsCurrentValueSubject.eraseToAnyPublisher()
    }

    init(sessionToken: String) {
        print("[SPORTSBOOK][MERGER] Initializing SportsMerger with session token")
        self.sessionToken = sessionToken

        // Setup content identifiers
        self.liveSportsIdentifier = ContentIdentifier(
            contentType: .liveSports,
            contentRoute: .liveSports
        )

        self.allSportsIdentifier = ContentIdentifier(
            contentType: .allSports,
            contentRoute: .allSports
        )

        // Subscribe to state changes
        self.sportsCurrentValueSubject
            .sink { completion in
                print("[SPORTSBOOK][MERGER.value] Subject completed with: \(completion)")
            } receiveValue: { state in
                switch state {
                case .disconnected:
                    print("[SPORTSBOOK][MERGER.value] Subject is in disconnected state")
                case .connected:
                    print("[SPORTSBOOK][MERGER.value] Subject is in connected state")
                case .contentUpdate(let sports):
                    print("[SPORTSBOOK][MERGER.value] Subject is in contentUpdate state with \(sports.count) sports")
                }
            }
            .store(in: &cancellables)

        // Start subscriptions
        self.setupSubscriptions()
    }

    private func setupSubscriptions() {
        print("[SPORTSBOOK][MERGER] Setting up subscriptions")
        
        if let allSportsSubscription = self.allSportsSubscription {
            self.sportsCurrentValueSubject.send(.connected(subscription: allSportsSubscription))
        } else {
            let subscription = Subscription(
                contentIdentifier: self.allSportsIdentifier,
                sessionToken: self.sessionToken,
                unsubscriber: self
            )
            self.sportsCurrentValueSubject.send(.connected(subscription: subscription))
            self.allSportsSubscription = subscription
        }
        
        // Subscribe to all sports first
        self.subscribeAllSports()
            .flatMap { [weak self] _ -> AnyPublisher<Void, ServiceProviderError> in
                print("[SPORTSBOOK][MERGER] All sports subscription successful, subscribing to live sports")
                guard let self = self else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
                // Subscribe to live sports
                return self.subscribeLiveSports()
            }
            .sink { [weak self] completion in
                guard let self = self else { return }

                switch completion {
                case .finished:
                    print("[SPORTSBOOK][MERGER] All subscriptions completed successfully")
                   
                case .failure(let error):
                    print("[SPORTSBOOK][MERGER] Subscription setup failed with error: \(error)")
                    self.sportsCurrentValueSubject.send(completion: .failure(error))
                }
                self.waitingSubscription = false

            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    private func subscribeAllSports() -> AnyPublisher<Void, ServiceProviderError> {
        print("[SPORTSBOOK][MERGER] Subscribing to all sports")
        let endpoint = SportRadarRestAPIClient.subscribe(
            sessionToken: self.sessionToken,
            contentIdentifier: self.allSportsIdentifier
        )

        guard let request = endpoint.request() else {
            print("[SPORTSBOOK][MERGER] Failed to create request for all sports subscription")
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    print("[SPORTSBOOK][MERGER] All sports subscription request failed")
                    throw ServiceProviderError.onSubscribe
                }
                print("[SPORTSBOOK][MERGER] All sports subscription request successful")
                return data
            }
            .mapError { _ in
                print("[SPORTSBOOK][MERGER] Error mapping all sports subscription response")
                return ServiceProviderError.onSubscribe
            }
            .flatMap { data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8),
                   responseString.lowercased().contains("version") {
                    print("[SPORTSBOOK][MERGER] All sports subscription response validated")
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    print("[SPORTSBOOK][MERGER] Invalid all sports subscription response format")
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func subscribeLiveSports() -> AnyPublisher<Void, ServiceProviderError> {
        print("[SPORTSBOOK][MERGER] Subscribing to live sports")
        let endpoint = SportRadarRestAPIClient.subscribe(
            sessionToken: self.sessionToken,
            contentIdentifier: self.liveSportsIdentifier
        )

        guard let request = endpoint.request() else {
            print("[SPORTSBOOK][MERGER] Failed to create request for live sports subscription")
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return Future<Void, ServiceProviderError> { [weak self] promise in
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard
                    error == nil,
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    print("[SPORTSBOOK][MERGER] Live sports subscription request failed")
                    promise(.failure(.onSubscribe))
                    return
                }

                if let self = self {
                    print("[SPORTSBOOK][MERGER] Creating live sports subscription")
                    let subscription = Subscription(
                        contentIdentifier: self.liveSportsIdentifier,
                        sessionToken: self.sessionToken,
                        unsubscriber: self
                    )
                    self.liveSportsSubscription = subscription
                    self.allSportsSubscription?.associateSubscription(subscription)
                    print("[SPORTSBOOK][MERGER] Live sports subscription created and associated")
                }

                print("[SPORTSBOOK][MERGER] Live sports subscription successful")
                promise(.success(()))
            }
            task.resume()
        }.eraseToAnyPublisher()
    }

    func updateSports(_ sports: [SportType], forContentIdentifier identifier: ContentIdentifier) {
        guard identifier == self.allSportsIdentifier || identifier == self.liveSportsIdentifier else {
            //
            return
        }
        
        print("[SPORTSBOOK][MERGER] Updating sports for identifier: \(identifier.contentType.rawValue)")
        print("[SPORTSBOOK][MERGER.value] Current sportsCurrentValueSubject state: \(String(describing: self.sportsCurrentValueSubject.value))")

        if identifier == self.allSportsIdentifier {
            print("[SPORTSBOOK][MERGER] Updating base sports list with \(sports.count) sports")

            // Merge with existing live counts
            var updatedSports = sports
            for (index, sport) in updatedSports.enumerated() {
                if let alphaId = sport.alphaId {
                    updatedSports[index].numberLiveEvents = self.liveSportsCounts[alphaId] ?? 0
                }
            }

            print("[SPORTSBOOK][MERGER] Sending contentUpdate with \(updatedSports.count) sports")
            self.sportsCurrentValueSubject.send(.contentUpdate(content: updatedSports))
            print("[SPORTSBOOK][MERGER] New sportsCurrentValueSubject state after all sports update: \(String(describing: self.sportsCurrentValueSubject.value))")

        } else if identifier == self.liveSportsIdentifier {
            print("[SPORTSBOOK][MERGER] Updating live counts")
            // Update live counts dictionary
            for sport in sports {
                if let alphaId = sport.alphaId {
                    self.liveSportsCounts[alphaId] = sport.numberLiveEvents
                }
            }

            // Get current sports from subject and merge with live counts
            switch self.sportsCurrentValueSubject.value {
            case .disconnected:
                print("[SPORTSBOOK][MERGER] WARNING: Subject is in disconnected state")
            case .connected:
                print("[SPORTSBOOK][MERGER] WARNING: Subject is in connected state but no sports data")
            case .contentUpdate(let currentSports):
                print("[SPORTSBOOK][MERGER] Found \(currentSports.count) current sports to update")
                var updatedSports = currentSports
                for (index, sport) in updatedSports.enumerated() {
                    if let alphaId = sport.alphaId {
                        updatedSports[index].numberLiveEvents = self.liveSportsCounts[alphaId] ?? 0
                    }
                }

                print("[SPORTSBOOK][MERGER] Sending contentUpdate with \(updatedSports.count) sports")
                self.sportsCurrentValueSubject.send(.contentUpdate(content: updatedSports))
                print("[SPORTSBOOK][MERGER] New sportsCurrentValueSubject state after live update: \(String(describing: self.sportsCurrentValueSubject.value))")
            }
        }
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        print("[SPORTSBOOK][MERGER] Reconnecting with new session token")
        // Resubscribe with new token
        let allSportsEndpoint = SportRadarRestAPIClient.subscribe(
            sessionToken: newSessionToken,
            contentIdentifier: self.allSportsIdentifier
        )

        if let request = allSportsEndpoint.request() {
            print("[SPORTSBOOK][MERGER] Resubscribing to all sports")
            let task = session.dataTask(with: request)
            task.resume()
        } else {
            print("[SPORTSBOOK][MERGER] Failed to create request for all sports resubscription")
        }

        let liveSportsEndpoint = SportRadarRestAPIClient.subscribe(
            sessionToken: newSessionToken,
            contentIdentifier: self.liveSportsIdentifier
        )

        if let request = liveSportsEndpoint.request() {
            print("[SPORTSBOOK][MERGER] Resubscribing to live sports")
            let task = session.dataTask(with: request)
            task.resume()
        } else {
            print("[SPORTSBOOK][MERGER] Failed to create request for live sports resubscription")
        }
    }
}

// MARK: - UnsubscriptionController
extension SportsMerger: UnsubscriptionController {
    func unsubscribe(subscription: Subscription) {
        print("[SPORTSBOOK][MERGER] Unsubscribing from content: \(subscription.contentIdentifier.contentType.rawValue)")
        let endpoint = SportRadarRestAPIClient.unsubscribe(
            sessionToken: subscription.sessionToken,
            contentIdentifier: subscription.contentIdentifier
        )

        guard let request = endpoint.request() else {
            print("[SPORTSBOOK][MERGER] Failed to create unsubscribe request")
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("[SPORTSBOOK][MERGER] Unsubscribe request failed with error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            print("[SPORTSBOOK][MERGER] Successfully unsubscribed from \(subscription.contentIdentifier.contentType.rawValue)")
        }
        task.resume()
    }
}

// MARK: - Live Data Handling
extension SportsMerger {
    /// Updates live event counts for sports
    /// - Parameters:
    ///   - sports: Current list of sports
    ///   - liveCounts: Dictionary of sport IDs to live event counts
    /// - Returns: Updated sports array with new live counts
    func updateLiveEventCounts(sports: [SportType], liveCounts: [String: Int]) -> [SportType] {
        print("[SPORTSBOOK][MERGER] Updating live event counts for \(sports.count) sports")
        let updatedSports = sports.map { sport in
            var updatedSport = sport
            if let alphaId = sport.alphaId {
                let newCount = liveCounts[alphaId] ?? 0
                print("[SPORTSBOOK][MERGER] Setting live count for sport \(alphaId): \(newCount)")
                updatedSport.numberLiveEvents = newCount
            }
            return updatedSport
        }
        print("[SPORTSBOOK][MERGER] Finished updating live event counts")
        return updatedSports
    }
}

// MARK: - Event Counting
extension SportsMerger {
    /// Updates total event counts for sports
    /// - Parameters:
    ///   - sports: Current list of sports
    ///   - eventCounts: Dictionary of sport IDs to total event counts
    /// - Returns: Updated sports array with new event counts
    func updateEventCounts(sports: [SportType], eventCounts: [String: Int]) -> [SportType] {
        print("[SPORTSBOOK][MERGER] Updating event counts for \(sports.count) sports")
        let updatedSports = sports.map { sport in
            var updatedSport = sport
            if let numericId = sport.numericId {
                let newCount = eventCounts[numericId] ?? 0
                print("[SPORTSBOOK][MERGER] Setting event count for sport \(numericId): \(newCount)")
                updatedSport.numberEvents = newCount
            }
            return updatedSport
        }
        print("[SPORTSBOOK][MERGER] Finished updating event counts")
        return updatedSports
    }

    /// Updates the event count for a specific sport
    /// - Parameters:
    ///   - nodeId: The numeric ID of the sport to update
    ///   - eventCount: The new event count
    func updateSportEventCount(nodeId: String, eventCount: Int) {
        print("[SPORTSBOOK][MERGER] Updating event count for sport \(nodeId): \(eventCount)")
        if case .contentUpdate(let currentSports) = sportsCurrentValueSubject.value {
            var updatedSports = currentSports
            if let sportIndex = updatedSports.firstIndex(where: { $0.numericId == nodeId }) {
                updatedSports[sportIndex].numberEvents = eventCount
                print("[SPORTSBOOK][MERGER] Found sport at index \(sportIndex), updating event count")
                updateSports(updatedSports, forContentIdentifier: allSportsIdentifier)
            } else {
                print("[SPORTSBOOK][MERGER] Sport not found for nodeId: \(nodeId)")
            }
        } else {
            print("[SPORTSBOOK][MERGER] No current sports available to update event count")
        }
    }

    /// Updates the live event count for a specific sport
    /// - Parameters:
    ///   - nodeId: The numeric ID of the sport to update
    ///   - liveCount: The new live event count
    func updateSportLiveCount(nodeId: String, liveCount: Int) {
        print("[SPORTSBOOK][MERGER] Updating live count for sport \(nodeId): \(liveCount)")
        if case .contentUpdate(let currentSports) = sportsCurrentValueSubject.value {
            var updatedSports = currentSports
            if let sportIndex = updatedSports.firstIndex(where: { $0.numericId == nodeId }) {
                updatedSports[sportIndex].numberLiveEvents = liveCount
                print("[SPORTSBOOK][MERGER] Found sport at index \(sportIndex), updating live count")
                updateSports(updatedSports, forContentIdentifier: liveSportsIdentifier)
            } else {
                print("[SPORTSBOOK][MERGER] Sport not found for nodeId: \(nodeId)")
            }
        } else {
            print("[SPORTSBOOK][MERGER] No current sports available to update live count")
        }
    }
}
