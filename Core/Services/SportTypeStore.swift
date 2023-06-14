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

    var isLoadingSportTypesPublisher = CurrentValueSubject<Bool, Never>(true)
    var isLoadingPreLiveSportsPublisher = CurrentValueSubject<Bool, Never>(true)
    var isLoadingLiveSportsPublisher = CurrentValueSubject<Bool, Never>(true)

    var preLiveSportsRequestRetries = 0

    var maxRequestSportsRetries = 5

    var defaultSport: Sport {
        if let firstSport = self.sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: nil, showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }

    var defaultSportWithCodeId: Sport {
        if let firstSportWithCodeId = self.sports.first(where: {
            $0.numericId != nil
        }) {
            return firstSportWithCodeId
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "19781.1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
    }

    private var cancellables = Set<AnyCancellable>()

    private var preLiveSportsSubscription: ServicesProvider.Subscription?
    private var liveSportsSubscription: ServicesProvider.Subscription?

    private var sports = [Sport]()
    private var preLiveSports = [Sport]()
    private var liveSports = [Sport]()

    var sportsPublisher: CurrentValueSubject<[Sport], Never> = .init([])

    init() {

    }

    deinit {
        print("SportTypeStore deinit")
    }

    func requestInitialSportsData() {

        self.getAllSports()

    }

    private func getAllSports() {
        Env.servicesProvider.subscribeAllSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("All sports error: \(error)")
                    self?.isLoadingPreLiveSportsPublisher.send(false)
                    self?.isLoadingLiveSportsPublisher.send(false)
                    self?.isLoadingSportTypesPublisher.send(false)
                }

        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.preLiveSportsSubscription = subscription
            case .contentUpdate(let sportTypes):
                // Prelive sports
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))

                let filteredSports = sports.filter({
                    $0.eventsCount > 0 || $0.liveEventsCount > 0 || $0.outrightEventsCount > 0
                })

                self?.preLiveSports = filteredSports

                self?.isLoadingPreLiveSportsPublisher.send(false)

                // Live sports
                let liveSports = sports.filter({
                    $0.liveEventsCount > 0
                })

                self?.liveSports = liveSports

                self?.isLoadingLiveSportsPublisher.send(false)

                self?.sports = filteredSports

                self?.sportsPublisher.send(filteredSports)

                self?.isLoadingSportTypesPublisher.send(false)
            case .disconnected:
                ()
            }

        })
        .store(in: &cancellables)
    }

    private func getLiveSports() {

        Env.servicesProvider.subscribeLiveSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("Live sports error: \(error)")
                    self?.isLoadingLiveSportsPublisher.send(false)
                }

        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.liveSportsSubscription = subscription
                self?.liveSports = []
            case .contentUpdate(let sportTypes):
                let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                self?.liveSports = sports
                self?.isLoadingLiveSportsPublisher.send(false)
            case .disconnected:
                self?.liveSports = []
            }

        })
        .store(in: &cancellables)
    }

    private func getPreLiveSports() {
        Env.servicesProvider.getAvailableSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                ()
            case .failure(let error):
                print("Prelive sports error: \(error)")
                self?.isLoadingPreLiveSportsPublisher.send(false)
            }
        }, receiveValue: { [weak self] sportsList in
            self?.preLiveSports = sportsList.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))

            let liveSports = sportsList.filter( {
                $0.numberLiveEvents > 0
            })

            self?.liveSports = liveSports.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
            
            self?.isLoadingPreLiveSportsPublisher.send(false)

            self?.getLiveSports()
        })
        .store(in: &cancellables)
    }

    private func mergeAllSports(liveSports: [Sport], preLiveSports: [Sport]) {

        var mergedSports = [Sport]()

        mergedSports.append(contentsOf: liveSports)

        for preLiveSport in preLiveSports {
            if !mergedSports.contains(where: { $0.name.lowercased() == preLiveSport.name.lowercased() }) {
                mergedSports.append(preLiveSport)
            }
        }

        self.sports.append(contentsOf: mergedSports)

        self.isLoadingSportTypesPublisher.send(false)
    }

    func getAvailableSports() -> [Sport] {
        return self.sports
    }

    func getSportId(sportCode: String) -> String? {

        return self.sports.first(where: {
            $0.alphaId == sportCode
        })?.id
    }
}
