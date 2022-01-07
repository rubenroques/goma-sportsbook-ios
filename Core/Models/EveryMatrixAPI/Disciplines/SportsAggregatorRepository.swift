//
//  SportsAggregatorRepository.swift
//  Sportsbook
//
//  Created by André Lascas on 07/01/2022.
//

import Foundation
import Combine

class SportsAggregatorRepository {

    var sportsLive: [String: EveryMatrix.Discipline] = [:]
    var sportsLivePublisher: [String: CurrentValueSubject<EveryMatrix.Discipline, Never>] = [:]
    var numberOfSportsLive: CurrentValueSubject<Int, Never> = .init(0)
    var changedSportsLivePublisher = PassthroughSubject<Void, Never>.init()

    func processSportsAggregator(_ aggregator: EveryMatrix.SportsAggregator) {

        for content in aggregator.content ?? [] {

            switch content {

            case .sport(let sport):
                if let sportId = sport.id {
                    self.sportsLive[sportId] = sport
                    self.sportsLivePublisher[sportId] = .init(sport)
                }
            default:
                ()
            }
        }

    }

    func processContentUpdateSportsAggregator(_ aggregator: EveryMatrix.SportsAggregator) {
        guard
            let contentUpdates = aggregator.contentUpdates
        else {
            return
        }

        for update in contentUpdates {
            switch update {
            case .sportUpdate(let id, let numberOfLiveEvents):
                if let publisher = sportsLivePublisher[id] {

                    let sport = publisher.value
                    let updatedSport = sport.sportUpdated(numberOfLiveEvents: numberOfLiveEvents)
                    publisher.send(updatedSport)
                }
            case .fullSportUpdate(let sport):
                if let sportId = sport.id {
                    sportsLivePublisher[sportId] = .init(sport)
                    sportsLive[sportId] = sport

                }
                changedSportsLivePublisher.send()
            case .sportDelete(let sportId):
                if let sport = sportsLivePublisher[sportId] {
                    sportsLivePublisher.removeValue(forKey: sportId)
                    sportsLive.removeValue(forKey: sportId)
                }
                changedSportsLivePublisher.send()

            default:
                ()
            }
        }
    }
}
