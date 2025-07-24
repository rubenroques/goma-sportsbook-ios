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
            let firstSport = sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }
    
    var football: Sport {
        return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
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
                    break
                case .failure(let error):
                    self?.activeSportsCurrentValueSubject.send(completion: .failure(error))
                    self?.sportsSubscription = nil
                }
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.sportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })
                self?.activeSportsCurrentValueSubject.send(.loaded(filteredSports))
            case .disconnected:
                break
            }
        })
        .store(in: &self.cancellables)
    }

    func getActiveSports() -> [Sport] {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value {
            return sports
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
