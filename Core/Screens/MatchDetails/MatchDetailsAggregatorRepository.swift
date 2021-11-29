//
//  MatchDetailsAggregatorRepository.swift
//  Sportsbook
//
//  Created by Ruben Roques on 25/11/2021.
//

import Foundation
import Combine
import OrderedCollections

class MatchDetailsAggregatorRepository: NSObject {

    var matchId: String

    var marketGroupsPublisher: CurrentValueSubject<[EveryMatrix.MarketGroup], Never> = .init([])
    var totalMarketsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    // Caches
    var marketGroups: OrderedDictionary<String, EveryMatrix.MarketGroup> = [:]

    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]

    private var marketsForGroup: [String: OrderedSet<String>] = [:]   // [Group ID: [Markets IDs] ]
    private var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    private var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    private var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]
    private var bettingOutcomesForMarket: [String: Set<String>] = [:]
    private var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]

    // Publishers
    private var isLoadingMarketGroups: CurrentValueSubject<Bool, Never> = .init(false)
    private var isLoadingMarketGroupDetails: [String: CurrentValueSubject<Bool, Never>] = [:]

    private var matchMarketGroupsPublisher: AnyCancellable?
    private var marketGroupsDetailsCancellable: Set<AnyCancellable> = []

    private var matchMarketGroupsRegister: EndpointPublisherIdentifiable?
    private var marketGroupsDetailsRegisters: [EndpointPublisherIdentifiable] = []

    private var cancellable: Set<AnyCancellable> = []

    init(matchId: String) {
        self.matchId = matchId

        super.init()

        self.connectPublishers()
    }

    func connectPublishers() {
        self.connectMarketGroupsPublisher()
        // market groups details are called after the groups are processed (matchMarketGroupsPublisher initial dump)
    }

    func connectMarketGroupsPublisher() {

        self.marketGroups = [:]
        self.marketsPublishers = [:]
        self.marketsForGroup = [:]
        self.betOutcomes = [:]
        self.bettingOfferPublishers = [:]
        self.bettingOutcomesForMarket = [:]
        self.marketOutcomeRelations = [:]

        self.totalMarketsPublisher.send(marketsPublishers.count)

        self.isLoadingMarketGroups.send(true)

        let language = "en"
        let mainMarketsEndpoint = TSRouter.matchMarketGroupsPublisher(operatorId: Env.appSession.operatorId,
                                                                   language: language,
                                                                      matchId: self.matchId)

        if let matchMarketGroupsRegister = self.matchMarketGroupsRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: matchMarketGroupsRegister)
        }

        self.matchMarketGroupsPublisher?.cancel()
        self.matchMarketGroupsPublisher = nil

        self.matchMarketGroupsPublisher = TSManager.shared
            .registerOnEndpoint(mainMarketsEndpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingMarketGroups.send(false)

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("SportsViewModel competitionsMatchesPublisher connect")
                    self?.matchMarketGroupsRegister = publisherIdentifiable

                case .initialContent(let aggregator):
                    print("SportsViewModel competitionsMatchesPublisher initialContent")
                    self?.storeMarketGroups(fromAggregator: aggregator)
                    self?.connectMarketGroupListDetailsPublisher()

                case .updatedContent(let aggregatorUpdates):
                    print("SportsViewModel competitionsMatchesPublisher updatedContent")
                    self?.updateStoredMarketGroups(fromAggregator: aggregatorUpdates)

                case .disconnect:
                    print("SportsViewModel competitionsMatchesPublisher disconnect")

                }
            })

    }


    func connectMarketGroupListDetailsPublisher() {

        //
        // cancel old market groups observations
        self.marketGroupsDetailsCancellable.forEach({ $0.cancel() })
        self.marketGroupsDetailsRegisters.forEach({ TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: $0) })
        self.isLoadingMarketGroupDetails.values.forEach({
            $0.send(true)
        })

        self.isLoadingMarketGroupDetails = [:]
        self.marketGroupsDetailsCancellable = []
        self.marketGroupsDetailsRegisters = []

        //
        // Request new market groups info
        let language = "en"

        for marketGroup in self.marketGroups.values {

            guard
                let marketGroupKey = marketGroup.groupKey
            else {
                continue
            }


            let endpoint = TSRouter.matchMarketGroupDetailsPublisher(operatorId: Env.appSession.operatorId,
                                                                     language: language,
                                                                     matchId: self.matchId,
                                                                     marketGroupName: marketGroupKey)

            if let isLoadingMarketGroupDetails = isLoadingMarketGroupDetails[marketGroupKey] {
                isLoadingMarketGroupDetails.send(true)
            }
            else {
                isLoadingMarketGroupDetails[marketGroupKey] = CurrentValueSubject.init(true)
            }

            TSManager.shared
                .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure:
                        print("Error retrieving data!")
                    case .finished:
                        print("Data retrieved!")
                    }

                }, receiveValue: { [weak self] state in
                    switch state {
                    case .connect(let publisherIdentifiable):
                        print("SportsViewModel competitionsMatchesPublisher connect")
                        self?.marketGroupsDetailsRegisters.append(publisherIdentifiable)

                    case .initialContent(let aggregator):
                        print("SportsViewModel competitionsMatchesPublisher initialContent")
                        self?.storeMarketGroupDetails(fromAggregator: aggregator, onMarketGroup: marketGroupKey)
                        self?.isLoadingMarketGroupDetails[marketGroupKey]?.send(false)

                    case .updatedContent(let aggregatorUpdates):
                        print("SportsViewModel competitionsMatchesPublisher updatedContent")
                        self?.updateMarketGroupDetails(fromAggregator: aggregatorUpdates)

                    case .disconnect:
                        print("SportsViewModel competitionsMatchesPublisher disconnect")

                    }
                })
                .store(in: &marketGroupsDetailsCancellable)

        }

    }

    func storeMarketGroups(fromAggregator aggregator: EveryMatrix.Aggregator) {

        self.marketGroups = [:]

        for content in aggregator.content ?? [] {
            switch content {
            case .marketGroup(let marketGroup):
                if let groupKey = marketGroup.groupKey, groupKey != "Bet_Builder" {
                    marketGroups[groupKey] = marketGroup
                }
            default:
                ()
            }
        }

        let marketGroupsArray = Array(marketGroups.values)
        self.marketGroupsPublisher.send(marketGroupsArray)
    }


    func updateStoredMarketGroups(fromAggregator aggregator: EveryMatrix.Aggregator) {

//        for content in aggregator.contentUpdates ?? [] {
//            switch content {
//            case .marketGroup(let marketGroup):
//                if let groupKey = marketGroup.groupKey {
//                    marketGroups[groupKey] = marketGroup
//                }
//            default:
//                ()
//            }
//        }

    }

    func storeMarketGroupDetails(fromAggregator aggregator: EveryMatrix.Aggregator, onMarketGroup marketGroupKey: String) {

        for content in aggregator.content ?? [] {
            switch content {
            case .market(let marketContent):
                marketsPublishers[marketContent.id] = CurrentValueSubject<EveryMatrix.Market, Never>.init(marketContent)

                if var marketsForIterationMatch = marketsForGroup[marketGroupKey] {
                    marketsForIterationMatch.append(marketContent.id)
                    marketsForGroup[marketGroupKey] = marketsForIterationMatch
                }
                else {
                    var newSet = OrderedSet<String>.init()
                    newSet.append(marketContent.id)
                    marketsForGroup[marketGroupKey] = newSet
                }

            case .betOutcome(let betOutcomeContent):
                betOutcomes[betOutcomeContent.id] = betOutcomeContent

            case .bettingOffer(let bettingOfferContent):
                if let outcomeIdValue = bettingOfferContent.outcomeId {
                    bettingOffers[outcomeIdValue] = bettingOfferContent
                }
                bettingOfferPublishers[bettingOfferContent.id] = CurrentValueSubject<EveryMatrix.BettingOffer, Never>.init(bettingOfferContent)

            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                marketOutcomeRelations[marketOutcomeRelationContent.id] = marketOutcomeRelationContent

                if let marketId = marketOutcomeRelationContent.marketId, let outcomeId = marketOutcomeRelationContent.outcomeId {
                    if var outcomesForMatch = bettingOutcomesForMarket[marketId] {
                        outcomesForMatch.insert(outcomeId)
                        bettingOutcomesForMarket[marketId] = outcomesForMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(outcomeId)
                        bettingOutcomesForMarket[marketId] = newSet
                    }
                }
                
            default:
                ()
            }
        }

        self.totalMarketsPublisher.send(marketsPublishers.count)
    }

    func updateMarketGroupDetails(fromAggregator aggregator: EveryMatrix.Aggregator) {

        guard
            let contentUpdates = aggregator.contentUpdates
        else {
            return
        }

        for update in contentUpdates {
            switch update {
            case .bettingOfferUpdate(let id, let odd, let isLive, let isAvailable):
                if let publisher = bettingOfferPublishers[id] {
                    let bettingOffer = publisher.value
                    let updatedBettingOffer = bettingOffer.bettingOfferUpdated(withOdd: odd,
                                                                               isLive: isLive,
                                                                               isAvailable: isAvailable)
                    publisher.send(updatedBettingOffer)
                }
            case .marketUpdate(let id, let isAvailable, let isClosed):
                if let marketPublisher = marketsPublishers[id] {
                    let market = marketPublisher.value
                    let updatedMarket = market.martketUpdated(withAvailability: isAvailable, isCLosed: isClosed)
                    marketPublisher.send(updatedMarket)
                }
            case .unknown:
                print("uknown")
            }
        }
    }

    /*
    Replace the call above with the following aggregator:
    /sports/{operatorId}/{lang}/match-aggregator-groups-overview/{matchId}/1

     /sports/2474/en/match-aggregator-groups-overview/155503665771237376/1  -> match and event-infos
     example matchid: 155503665771237376

    Market Groups (Subscribe):
    /sports/{operatorId}/{lang}/event/{matchId}/market-groups
    /sports/2474/en/event/155503665771237376/market-groups

    List Market Groups Markets (Aggregator) (Subscribe):
    /sports/{operatorId}/{lang}/{matchId}/match-odds/market-group/Main
    /sports/2474/en/155503665771237376/match-odds/market-group/Sets

     */


    func marketsForGroup(withGroupKey key: String) -> [Market] {
        guard let marketsIds = self.marketsForGroup[key] else { return [] }

        var markets: [Market] = []

        let rawMarketsList = marketsIds.map { id in
            return self.marketsPublishers[id]?.value
        }
        .compactMap({$0})

        for rawMarket  in rawMarketsList {

            let rawOutcomeIds = self.bettingOutcomesForMarket[rawMarket.id] ?? []

            let rawOutcomesList = rawOutcomeIds.map { id in
                return self.betOutcomes[id]
            }
            .compactMap({$0})

            var outcomes: [Outcome] = []
            for rawOutcome in rawOutcomesList {

                if let rawBettingOffer = self.bettingOffers[rawOutcome.id] {
                    let bettingOffer = BettingOffer(id: rawBettingOffer.id,
                                                    value: rawBettingOffer.oddsValue ?? 0.0)

                    let outcome = Outcome(id: rawOutcome.id,
                                          codeName: rawOutcome.headerNameKey ?? "",
                                          typeName: rawOutcome.headerName ?? "",
                                          translatedName: rawOutcome.translatedName ?? "",
                                          nameDigit1: rawOutcome.paramFloat1,
                                          nameDigit2: rawOutcome.paramFloat2,
                                          nameDigit3: rawOutcome.paramFloat3,
                                          bettingOffer: bettingOffer)
                    outcomes.append(outcome)
                }
            }

            let sortedOutcomes = outcomes.sorted { out1, out2 in
                let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1.codeName)
                let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2.codeName)
                return out1Value < out2Value
            }

            let market = Market(id: rawMarket.id,
                                typeId: rawMarket.bettingTypeId ?? "",
                                name: rawMarket.shortName ?? "",
                                outcomes: sortedOutcomes)
            markets.append(market)
        }

        return markets
    }
}
