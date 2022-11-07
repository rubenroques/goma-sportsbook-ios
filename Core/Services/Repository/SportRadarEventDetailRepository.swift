//
//  SportRadarEventDetailRepository.swift
//  
//
//  Created by André Lascas on 07/11/2022.
//

import Foundation
import Combine
import OrderedCollections
import ServiceProvider

class SportRadarEventDetailRepository {

    var eventMarkets: [EventMarket] = []
    var eventMarketsPublisher: CurrentValueSubject<[EventMarket], Never> = .init([])

    var marketGroups: OrderedDictionary<String, EveryMatrix.MarketGroup> = [:]
    var marketGroupsPublisher: CurrentValueSubject<[EveryMatrix.MarketGroup], Never> = .init([])

    var availableMarketGroups: [String: [AvailableMarket]] = [:]

    private var cancellables = Set<AnyCancellable>()

    init() {

        self.getMarketFilters()
    }

    func getMarketFilters() {

        Env.serviceProvider.getMarketFilters()?
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {

                case .finished:
                    print("MARKET FILTER FINISHED")
                case .failure(let error):
                    print("MARKET FILTER ERROR: \(error)")

                }
            }, receiveValue: { [weak self] marketFilter in
                print("MARKET FILTER RESPONSE: \(marketFilter)")
                self?.processMarketFilters(marketFilter: marketFilter)

            })
            .store(in: &cancellables)
    }

    private func processMarketFilters(marketFilter: MarketFilter) {

        // All Market
        let allMarket = marketFilter.allMarkets
        let allEventMarket = EventMarket(id: "\(allMarket.displayOrder)", name: allMarket.translations?.english ?? "", marketIds: [])
        self.eventMarkets.append(allEventMarket)

        // Popular Market
        let popularMarket = marketFilter.popularMarkets
        var popularMarketIds: [String] = []
        if let popularMarketSportsIds = popularMarket.marketsSportType?.all {

            for marketId in popularMarketSportsIds {
                if let marketSportId = marketId.ids[safe: 0] {
                    popularMarketIds.append(marketSportId)
                }
            }
        }
        let popularEventMarket = EventMarket(id: "\(popularMarket.displayOrder)", name: popularMarket.translations?.english ?? "", marketIds: popularMarketIds)
        self.eventMarkets.append(popularEventMarket)

        // Total Market
        let totalMarket = marketFilter.totalMarkets
        var totalMarketIds: [String] = []
        if let totalMarketSportsIds = totalMarket.marketsSportType?.all {

            for marketId in totalMarketSportsIds {
                if let marketSportId = marketId.ids[safe: 0] {
                    totalMarketIds.append(marketSportId)
                }
            }
        }
        let totalEventMarket = EventMarket(id: "\(totalMarket.displayOrder)", name: totalMarket.translations?.english ?? "", marketIds: totalMarketIds)
        self.eventMarkets.append(totalEventMarket)

        // Total Market
        let goalMarket = marketFilter.goalMarkets
        var goalMarketIds: [String] = []
        if let goalMarketSportsIds = goalMarket.marketsSportType?.all {

            for marketId in goalMarketSportsIds {
                if let marketSportId = marketId.ids[safe: 0] {
                    goalMarketIds.append(marketSportId)
                }
            }
        }
        let goalEventMarket = EventMarket(id: "\(goalMarket.displayOrder)", name: goalMarket.translations?.english ?? "", marketIds: goalMarketIds)
        self.eventMarkets.append(goalEventMarket)

        // Handicap Market
        let handicapMarket = marketFilter.handicapMarkets
        var handicapMarketIds: [String] = []
        if let handicapMarketSportsIds = handicapMarket.marketsSportType?.all {

            for marketId in handicapMarketSportsIds {
                if let marketSportId = marketId.ids[safe: 0] {
                    handicapMarketIds.append(marketSportId)
                }
            }
        }
        let handicapEventMarket = EventMarket(id: "\(handicapMarket.displayOrder)", name: handicapMarket.translations?.english ?? "", marketIds: handicapMarketIds)
        self.eventMarkets.append(handicapEventMarket)

        // Other Market
        let otherMarket = marketFilter.otherMarkets
        var otherMarketIds: [String] = []
        if let otherMarketSportsIds = otherMarket.marketsSportType?.all {

            for marketId in otherMarketSportsIds {
                if let marketSportId = marketId.ids[safe: 0] {
                    otherMarketIds.append(marketSportId)
                }
            }
        }
        let otherEventMarket = EventMarket(id: "\(otherMarket.displayOrder)", name: otherMarket.translations?.english ?? "", marketIds: otherMarketIds)
        self.eventMarkets.append(otherEventMarket)

        self.eventMarketsPublisher.send(self.eventMarkets)

    }

    func storeMarketGroups(fromMarketFilters marketFilters: [EventMarket], match: Match) {

        self.marketGroups = [:]

        var availableMarkets: [String: [AvailableMarket]] = [:]

        let matchMarkets = match.markets

        for matchMarket in matchMarkets {

            if let marketTypeId = matchMarket.marketTypeId {

                for eventMarket in marketFilters {

                    if eventMarket.marketIds.contains(marketTypeId) {

                        if availableMarkets[eventMarket.name] == nil {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                            availableMarkets[eventMarket.name] = [availableMarket]
                        }
                        else {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                            availableMarkets[eventMarket.name]?.append(availableMarket)
                        }

                    }

                }

                // Add to All Market aswell
                let allEventMarket = marketFilters.filter({
                    $0.id == "1"
                })

                if let eventMarket = allEventMarket[safe: 0] {
                    if availableMarkets[eventMarket.name] == nil {
                        let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                        availableMarkets[eventMarket.name] = [availableMarket]
                    }
                    else {
                        let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                        availableMarkets[eventMarket.name]?.append(availableMarket)
                    }
                }

            }
            else {
                let allEventMarket = marketFilters.filter({
                    $0.id == "1"
                })

                if let eventMarket = allEventMarket[safe: 0] {
                    if availableMarkets[eventMarket.name] == nil {
                        let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                        availableMarkets[eventMarket.name] = [availableMarket]
                    }
                    else {
                        let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id)
                        availableMarkets[eventMarket.name]?.append(availableMarket)
                    }
                }

            }
        }

        for availableMarket in availableMarkets {
            let marketGroup = EveryMatrix.MarketGroup(type: availableMarket.key,
                                                      id: availableMarket.value.first?.marketGroupId ?? "0",
                                                      groupKey: "\(availableMarket.value.first?.marketGroupId ?? "0")",
                                                      translatedName: availableMarket.key.capitalized,
                                                      position: Int(availableMarket.value.first?.marketGroupId ?? "0") ?? 0,
                                                      isDefault: availableMarket.key == "all" ? true : false,
                                                      numberOfMarkets: availableMarket.value.count)

            self.marketGroups[availableMarket.key] = marketGroup
        }

        let marketGroupsArray = Array(marketGroups.values)
        self.marketGroupsPublisher.send(marketGroupsArray)

    }

    func marketGroupsArray() -> [EveryMatrix.MarketGroup] {
        return Array(marketGroups.values)
    }
}

struct EventMarket {
    var id: String
    var name: String
    var marketIds: [String]

}
