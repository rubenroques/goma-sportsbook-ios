//
//  SportTypeStore.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2022.
//

import Foundation
import Combine
import ServicesProvider

class SportTypeStore {

    var defaultSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value, let firstSport = sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "19781.1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }

    private var activeSportsCurrentValueSubject: CurrentValueSubject<LoadableContent<[Sport]>, Never> = .init(.idle)
    var activeSportsPublisher: AnyPublisher<LoadableContent<[Sport]>, Never> {
        return self.activeSportsCurrentValueSubject.eraseToAnyPublisher()
    }

    private var sportsSubscription: ServicesProvider.Subscription?
    private var cancellables = Set<AnyCancellable>()

    init() {

    }

    deinit {
        print("SportTypeStore deinit")
    }

    func requestInitialSportsData() {
        self.getAllSports()
    }

    private func getAllSports() {

        self.activeSportsCurrentValueSubject.send(.loading)

        Env.servicesProvider.subscribeAllSportTypes()
            .retry(2)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("All sports error: \(error)")
                    self?.activeSportsCurrentValueSubject.send(.failed)
                }
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.sportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                // Prelive sports
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))

                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })

                self?.activeSportsCurrentValueSubject.send(.loaded(filteredSports))

            case .disconnected:
                ()
            }

        })
        .store(in: &cancellables)
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
        return self.getActiveSports().first(where: {
            $0.alphaId == sportCode
        })?.id
    }
}
