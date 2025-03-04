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
            print("[SERVICEPROVIDER][STORE] Using first available sport as default: \(firstSport.name)")
            return firstSport
        }
        else {
            print("[SERVICEPROVIDER][STORE] No sports available, using fallback default sport")
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }

    var defaultLiveSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
           let firstLiveSport = sports.first(where: { sport in sport.liveEventsCount > 0 }) {
            print("[SERVICEPROVIDER][STORE] Using first live sport as default: \(firstLiveSport.name)")
            return firstLiveSport
        }
        else {
            print("[SERVICEPROVIDER][STORE] No live sports available, falling back to default sport")
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
        print("[SERVICEPROVIDER][STORE] Initializing SportTypeStore")
    }

    deinit {
        print("[SERVICEPROVIDER][STORE] Deinitializing SportTypeStore")
    }

    func requestInitialSportsData() {
        print("[SERVICEPROVIDER][STORE] Requesting initial sports data")
        self.getSports()
    }

    private func getSports() {
        print("[SERVICEPROVIDER][STORE] Starting sports subscription")
        self.activeSportsCurrentValueSubject.send(.loading)

        Env.servicesProvider.subscribeSportTypes()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("[SERVICEPROVIDER][STORE] Sports subscription completed successfully")
                case .failure(let error):
                    print("[SERVICEPROVIDER][STORE] Sports subscription failed with error: \(error)")
                    self?.activeSportsCurrentValueSubject.send(completion: .failure(error))
                    self?.sportsSubscription = nil
                }
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("[SERVICEPROVIDER][STORE] Connected to sports subscription")
                self?.sportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                print("[SERVICEPROVIDER][STORE] Received sports update with \(sportTypes.count) sports")
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })
                print("[SERVICEPROVIDER][STORE] Filtered to \(filteredSports.count) active sports")
                self?.activeSportsCurrentValueSubject.send(.loaded(filteredSports))
                case .disconnected:
                print("[SERVICEPROVIDER][STORE] Sports subscription disconnected")
            }
        })
        .store(in: &self.cancellables)
    }

    func getActiveSports() -> [Sport] {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value {
            print("[SERVICEPROVIDER][STORE] Retrieved \(sports.count) active sports")
            return sports
        }
        else {
            print("[SERVICEPROVIDER][STORE] No active sports available")
            return []
        }
    }

    func getSportId(sportCode: String) -> String? {
        print("[SERVICEPROVIDER][STORE] Looking up sport ID for code: \(sportCode)")
        let sportId = self.getActiveSports().first(where: {
            $0.alphaId == sportCode
        })?.id
        print("[SERVICEPROVIDER][STORE] Found sport ID: \(sportId ?? "not found")")
        return sportId
    }

    func getSportIdByName(sportName: String) -> String? {
        print("[SERVICEPROVIDER][STORE] Looking up sport ID for name: \(sportName)")
        let sportId = self.getActiveSports().first(where: {
            $0.name == sportName
        })?.id
        print("[SERVICEPROVIDER][STORE] Found sport ID: \(sportId ?? "not found")")
        return sportId
    }

}
