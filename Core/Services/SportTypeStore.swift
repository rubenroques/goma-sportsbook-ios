//
//  SportTypeStore 2.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation
import Combine
import ServicesProvider
import SwiftPrettyPrint

class SportTypeStore {

    var defaultSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
            let firstSport = sports.first {
            print("[SPORTSBOOK][STORE] Using first available sport as default: \(firstSport.name)")
            return firstSport
        }
        else {
            print("[SPORTSBOOK][STORE] No sports available, using fallback default sport")
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }

    var defaultLiveSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
           let firstLiveSport = sports.first(where: { sport in sport.liveEventsCount > 0 }) {
            print("[SPORTSBOOK][STORE] Using first live sport as default: \(firstLiveSport.name)")
            return firstLiveSport
        }
        else {
            print("[SPORTSBOOK][STORE] No live sports available, falling back to default sport")
            return self.defaultSport
        }
    }

    private var activeSportsCurrentValueSubject: CurrentValueSubject<LoadableContent<[Sport]>, ServiceProviderError> = .init(.idle)
    var activeSportsPublisher: AnyPublisher<LoadableContent<[Sport]>, ServiceProviderError> {
        return self.activeSportsCurrentValueSubject.eraseToAnyPublisher()
    }

    private var liveSportsCountSubscription: ServicesProvider.Subscription?
    private var sportsSubscription: ServicesProvider.Subscription?

    private var cancellables = Set<AnyCancellable>()

    init() {
        print("[SPORTSBOOK][STORE] Initializing SportTypeStore")
    }

    deinit {
        print("[SPORTSBOOK][STORE] Deinitializing SportTypeStore")
    }

    func requestInitialSportsData() {
        print("[SPORTSBOOK][STORE] Requesting initial sports data")
        self.getSports()
    }

    private func getSports() {
        print("[SPORTSBOOK][STORE] Starting sports subscription")
        self.activeSportsCurrentValueSubject.send(.loading)

        Env.servicesProvider.subscribeSportTypes()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("[SPORTSBOOK][STORE] Sports subscription completed successfully")
                case .failure(let error):
                    print("[SPORTSBOOK][STORE] Sports subscription failed with error: \(error)")
                    self?.activeSportsCurrentValueSubject.send(completion: .failure(error))
                    self?.sportsSubscription = nil
                }
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("[SPORTSBOOK][STORE] Connected to sports subscription")
                self?.sportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                print("[SPORTSBOOK][STORE] Received sports update with \(sportTypes.count) sports")
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })
                print("[SPORTSBOOK][STORE] Filtered to \(filteredSports.count) active sports")
                self?.activeSportsCurrentValueSubject.send(.loaded(filteredSports))
            case .disconnected:
                print("[SPORTSBOOK][STORE] Sports subscription disconnected")
                break
            }
        })
        .store(in: &self.cancellables)
    }

    func getActiveSports() -> [Sport] {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value {
            print("[SPORTSBOOK][STORE] Retrieved \(sports.count) active sports")
            return sports
        }
        else {
            print("[SPORTSBOOK][STORE] No active sports available")
            return []
        }
    }

    func getSportId(sportCode: String) -> String? {
        print("[SPORTSBOOK][STORE] Looking up sport ID for code: \(sportCode)")
        let sportId = self.getActiveSports().first(where: {
            $0.alphaId == sportCode
        })?.id
        print("[SPORTSBOOK][STORE] Found sport ID: \(sportId ?? "not found")")
        return sportId
    }

    func getSportIdByName(sportName: String) -> String? {
        print("[SPORTSBOOK][STORE] Looking up sport ID for name: \(sportName)")
        let sportId = self.getActiveSports().first(where: {
            $0.name == sportName
        })?.id
        print("[SPORTSBOOK][STORE] Found sport ID: \(sportId ?? "not found")")
        return sportId
    }

}
