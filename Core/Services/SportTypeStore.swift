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
    var liveSportsRequestRetries = 0
    var maxRequestSportsRetries = 5

    var defaultSport: Sport {
        if let firstSport = self.sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: nil, showEventCategory: false, liveEventsCount: 0)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var sports = [Sport]()
    private var preLiveSports = [Sport]()
    private var liveSports = [Sport]()

    func getSportTypesList() {

        self.getLiveSports()

        self.getPreLiveSports()

        Publishers.CombineLatest(self.isLoadingLiveSportsPublisher, self.isLoadingPreLiveSportsPublisher)
            .sink(receiveValue: { [weak self] isLoadingLiveSports, isLoadingPreLiveSports in

                if !isLoadingLiveSports && !isLoadingPreLiveSports {

                    if let liveSports = self?.liveSports,
                       let preLiveSports = self?.preLiveSports {

                        self?.mergeAllSports(liveSports: liveSports, preLiveSports: preLiveSports)
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func getLiveSports() {

        Env.servicesProvider.subscribeLiveSportTypes()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("LIVE SPORTS ERROR: \(error)")
                    self?.liveSportsRequestRetries += 1

                    if let liveSportsRequestRetries = self?.liveSportsRequestRetries,
                       liveSportsRequestRetries < 5 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.getLiveSports()
                        }
                    }
                    else {
                        self?.isLoadingLiveSportsPublisher.send(false)
                    }
                }
                print("SportTypeStore subscribeLiveSportTypes completed \(completion)")
        }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in

            switch subscribableContent {
            case .connected(let subscription):
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
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                ()
            case .failure(let error):

                self?.preLiveSportsRequestRetries += 1

                if let preLiveSportsRequestRetries = self?.preLiveSportsRequestRetries,
                   preLiveSportsRequestRetries < 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.getPreLiveSports()
                    }
                }
                else {
                    self?.isLoadingPreLiveSportsPublisher.send(false)
                }
            }
        }, receiveValue: { [weak self] sportsList in

            self?.preLiveSports = sportsList.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
            self?.isLoadingPreLiveSportsPublisher.send(false)

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
}
