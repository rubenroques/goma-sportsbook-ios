//
//  SportTypeStore.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2022.
//

import Foundation
import Combine
import ServicesProvider
import SwiftPrettyPrint

class LegacySportTypeStore {

    var defaultSport: Sport {
        if case .loaded(let sports) = self.activeSportsCurrentValueSubject.value,
            let firstSport = sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: "19781.1", showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
        }
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

    private var liveSportsCountCurrentValueSubject: CurrentValueSubject<[String: LiveSport], ServiceProviderError> = .init([:])
    
    private var activeSportsCurrentValueSubject: CurrentValueSubject<LoadableContent<[Sport]>, ServiceProviderError> = .init(.idle)
    
    var activeSportsPublisher: AnyPublisher<LoadableContent<[Sport]>, ServiceProviderError> {
        Publishers.CombineLatest(self.activeSportsCurrentValueSubject, self.liveSportsCountCurrentValueSubject)
            .map { sportsList, liveCountDict -> LoadableContent<[Sport]> in
                switch sportsList {
                case .idle, .failed, .loading:
                    return sportsList
                case .loaded(let sportsList):
                    var updatedSportsList: [Sport] = []
                    
                    for sport in sportsList {
                        if let alphaId = sport.alphaId {
                            if let newLiveCount = liveCountDict[alphaId] {
                                var updatedSport = sport
                                updatedSport.liveEventsCount = newLiveCount.numberEvents
                                updatedSportsList.append(updatedSport)
                            }
                            else {
                                var updatedSport = sport
                                updatedSport.liveEventsCount = 0
                                updatedSportsList.append(updatedSport)
                            }
                        }
                        else {
                            updatedSportsList.append(sport)
                        }
                    }
                    
                    // Find alphaCodes from the dictionary that are not present in the sportsArray
                    let missingLiveSports = liveCountDict.keys.filter { alphaCode in
                        !updatedSportsList.contains { sport in
                            sport.alphaId == alphaCode
                        }
                    }

                    // Add missing alphaCodes to the sportsArray
                    for missingLiveSport in missingLiveSports {
                        if let liveSport = liveCountDict[missingLiveSport] {
                            let newSport = Sport(id: liveSport.id,
                                                 name: liveSport.name,
                                                 alphaId: liveSport.id,
                                                 numericId: nil,
                                                 showEventCategory: false,
                                                 liveEventsCount: liveSport.numberEvents)
                            
                            updatedSportsList.append(newSport)
                        }
                    }
                    return .loaded(updatedSportsList)
                }
            }
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
        self.getAllSports()
    }

    private func getAllSports() {

        self.activeSportsCurrentValueSubject.send(.loading)

        Env.servicesProvider.subscribeLiveSportTypes()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.liveSportsCountCurrentValueSubject.send(completion: .failure(error))
                }
            }, receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.liveSportsCountSubscription = subscription
                case .contentUpdate(let sportTypes):
                    let mappedSportTypes = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                    
                    var sportLiveCount: [String: LiveSport] = [:]
                    let currentLiveCount = self?.liveSportsCountCurrentValueSubject.value ?? [:]

                    for sport in mappedSportTypes {
                        let liveSport = LiveSport(id: sport.id, name: sport.name, numberEvents: sport.eventsCount, iconIdentifier: sport.id)
                        sportLiveCount[sport.alphaId ?? sport.id] = liveSport
                    }
                    
                    let mergedSports = currentLiveCount.merging(sportLiveCount) { (_, new) in new }
                    
                    let finalSports = mergedSports.filter { $0.value.numberEvents != 0 }
                    
                    self?.liveSportsCountCurrentValueSubject.send(finalSports)
                case .disconnected:
                    break
                }
            })
            .store(in: &self.cancellables)
        
        Env.servicesProvider.subscribeAllSportTypes()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SportTypeStore: All sports error: \(error)")
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

struct LiveSport {
    var id: String
    var name: String
    var numberEvents: Int
    var iconIdentifier: String
}
