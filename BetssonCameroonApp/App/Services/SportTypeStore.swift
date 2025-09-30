//
//  SportTypeStore 2.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation
import Combine
import ServicesProvider

class SportTypeStore {

    var defaultSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
           let firstSport = sports.sorted(by: \.id).first {
            return firstSport
        }
        else {
            return Sport(
                id: "1",
                name: "Football",
                alphaId: "FBL",
                numericId: "1",
                showEventCategory: false,
                liveEventsCount: 0,
                eventsCount: 1,
                hasMatches: true,
                hasOutrights: false)
        }
    }
    
    var football: Sport {
        return Sport(
            id: "1",
            name: "Football",
            alphaId: "FBL",
            numericId: "1",
            showEventCategory: false,
            liveEventsCount: 0,
            eventsCount: 1,
            hasMatches: true,
            hasOutrights: false)
    }

    var defaultLiveSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
           let firstLiveSport = sports.first(where: { sport in sport.liveEventsCount > 0 }) {
            return firstLiveSport
        }
        else {
            return self.defaultSport
        }
    }

    private var activeSportsCurrentValueSubject: CurrentValueSubject<LoadableContent<[Sport]>, ServiceProviderError> = .init(.idle)
    var activeSportsPublisher: AnyPublisher<LoadableContent<[Sport]>, ServiceProviderError> {
        return self.activeSportsCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private var liveSportsCountSubscription: ServicesProvider.Subscription?
    private var sportsSubscription: ServicesProvider.Subscription?

    private var cancellables = Set<AnyCancellable>()

    init() {
    }

    deinit {
    }

    func requestInitialSportsData() {
        self.getSports()
    }

    private func getSports() {
        print("SportTypeStore: Starting sports subscription")
        self.activeSportsCurrentValueSubject.send(.loading)

        //self.activeSportsCurrentValueSubject.send(.loaded([self.defaultSport]))
        //return
        
        //
        Env.servicesProvider.subscribeSportTypes()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    // print("SportTypeStore: Subscription finished")
                    break
                case .failure(let error):
                    print("❌ SportTypeStore: Subscription failed with error: \(error)")
                    self?.activeSportsCurrentValueSubject.send(completion: .failure(error))
                    self?.sportsSubscription = nil
                }
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                // print(" SportTypeStore: Connected to sports subscription (id: \(subscription.id))")
                self?.sportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                // print(" SportTypeStore: Received \(sportTypes.count) sport types from server")
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                // print(" SportTypeStore: Mapped to \(sports.count) sports")
                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })
                // print(" SportTypeStore: Filtered to \(filteredSports.count) sports with events")
                self?.activeSportsCurrentValueSubject.send(.loaded(filteredSports))
            case .disconnected:
                // print(" SportTypeStore: Disconnected from sports subscription")
                break
            }
        })
        .store(in: &self.cancellables)
    }

    func getActiveSports() -> [Sport] {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value {
            return sports.filter { sport in
                return sport.hasMatches
            }
        }
        else {
            return []
        }
    }

    func getSportId(sportCode: String) -> String? {
        let sportId = self.getActiveSports().first(where: {
            $0.alphaId == sportCode
        })?.id
        return sportId
    }

    func getSportIdByName(sportName: String) -> String? {
        let sportId = self.getActiveSports().first(where: {
            $0.name == sportName
        })?.id
        return sportId
    }

}
