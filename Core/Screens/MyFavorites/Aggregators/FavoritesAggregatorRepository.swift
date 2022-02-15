//
//  FavoritesAggregatorRepository.swift
//  Sportsbook
//
//  Created by André Lascas on 11/02/2022.
//

import Foundation

import Combine
import OrderedCollections

enum FavoritesAggregatorListType {
    case favoriteMatchEvents
    case favoriteCompetitionEvents
}

class FavoritesAggregatorsRepository {

    var matchesForType: [FavoritesAggregatorListType: [String] ] = [:]
    var matches: [String: EveryMatrix.Match] = [:]
    var marketsForMatch: [String: Set<String>] = [:]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:]

    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]
    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []

    var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]

    var tournamentsForLocation: [String: [String] ] = [:]
    var tournamentsForCategory: [String: [String] ] = [:]
    var tournaments: [String: EveryMatrix.Tournament] = [:]

    var matchesInfo: [String: EveryMatrix.MatchInfo] = [:]
    var matchesInfoForMatch: [String: Set<String> ] = [:]
    var matchesInfoForMatchPublisher: CurrentValueSubject<[String], Never> = .init([])

    private var cancellables: Set<AnyCancellable> = []

    func getLocations() {

        let resolvedRoute = TSRouter.getLocations(language: "en", sortByPopularity: false)
        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .sink(receiveCompletion: { _ in

            },
                  receiveValue: { [weak self] response in

                (response.records ?? []).forEach { location in

                    self?.locations[location.id] = location
                }

            })
            .store(in: &cancellables)
    }

    func processAggregator(_ aggregator: EveryMatrix.FavoritesAggregator, withListType type: FavoritesAggregatorListType, shouldClear: Bool = false) {

        if shouldClear {
            self.matchesForType = [:]
            self.mainMarkets = [:]
            self.mainMarketsOrder = []
        }

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament(let tournamentContent):
                tournaments[tournamentContent.id] = tournamentContent

            case .match(let matchContent):

                matches[matchContent.id] = matchContent

                if var marketsForIterationMatch = matchesForType[type] {
                    marketsForIterationMatch.append(matchContent.id)
                    matchesForType[type] = marketsForIterationMatch
                }
                else {
                    matchesForType[type] = [matchContent.id]
                }

            case .matchInfo(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                        var matchIdArray = matchesInfoForMatchPublisher.value
                        matchIdArray.append(matchId)
                        matchesInfoForMatchPublisher.send(matchIdArray)
                    }
                }

            case .market(let marketContent):
                marketsPublishers[marketContent.id] = CurrentValueSubject<EveryMatrix.Market, Never>.init(marketContent)

                if let matchId = marketContent.eventId {
                    if var marketsForIterationMatch = marketsForMatch[matchId] {
                        marketsForIterationMatch.insert(marketContent.id)
                        marketsForMatch[matchId] = marketsForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(marketContent.id)
                        marketsForMatch[matchId] = newSet
                    }
                }
            case .betOutcome(let betOutcomeContent):
                betOutcomes[betOutcomeContent.id] = betOutcomeContent

            case .bettingOffer(let bettingOfferContent):
                if let outcomeIdValue = bettingOfferContent.outcomeId {
                    bettingOffers[outcomeIdValue] = bettingOfferContent
                }
                bettingOfferPublishers[bettingOfferContent.id] = CurrentValueSubject<EveryMatrix.BettingOffer, Never>.init(bettingOfferContent)

            case .mainMarket(let market):
                mainMarkets[market.id] = market
                mainMarketsOrder.append(market.bettingTypeId ?? "")

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
            case .location(let location):
                self.locations[location.id] = location
            case .eventPartScore:
                ()
            case .unknown:
                () // print("Unknown type ignored")
            }
        }

        print("Finished dump processing")
    }

    func processContentUpdateAggregator(_ aggregator: EveryMatrix.FavoritesAggregator) {

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
                                                                               statusId: "", // TODO: Code Review - Add status id
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
            case .matchInfo(let id, let paramFloat1, let paramFloat2, let paramEventPartName1):
                for matchInfoForMatch in matchesInfoForMatch {
                    for matchInfoId in matchInfoForMatch.value {
                        if let matchInfo = matchesInfo[id] {
                            matchesInfo[id] = matchInfo.matchInfoUpdated(paramFloat1: paramFloat1,
                                                                         paramFloat2: paramFloat2,
                                                                         paramEventPartName1: paramEventPartName1)
                        }
                    }
                }
            case .fullMatchInfoUpdate(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                    }
                    var matchIdArray = matchesInfoForMatchPublisher.value
                    matchIdArray.append(matchId)
                    matchesInfoForMatchPublisher.send(matchIdArray)
                }
            case .unknown:
                print("uknown")
            }
        }
    }

    func oddPublisherForBettingOfferId(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func rawMatchesForListType(_ listType: FavoritesAggregatorListType) -> EveryMatrix.Matches {
        guard let matchesIds = self.matchesForType[listType] else {
            return []
        }

        let matchesList = matchesIds.map { id in
            return matches[id]
        }
        .compactMap({$0})

        return matchesList
    }

    func matchesForListType(_ listType: FavoritesAggregatorListType) -> [Match] {

        guard let matchesIds = self.matchesForType[listType] else {
            return []
        }

        let rawMatchesList = matchesIds.map { id in
            return matches[id]
        }
        .compactMap({$0})

        var matchesList: [Match] = []

        for rawMatch in rawMatchesList {

            var matchMarkets: [Market] = []

            let marketsIds = self.marketsForMatch[rawMatch.id] ?? []
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
                                                        value: rawBettingOffer.oddsValue ?? 0.0,
                                                        statusId: "", // TODO: Code Review - Add status id
                                                        isLive: rawBettingOffer.isLive ?? false,
                                                        isAvailable: rawBettingOffer.isAvailable ?? true)

                        let outcome = Outcome(id: rawOutcome.id,
                                              codeName: rawOutcome.headerNameKey ?? "",
                                              typeName: rawOutcome.headerName ?? "",
                                              translatedName: rawOutcome.translatedName ?? "",
                                              nameDigit1: rawOutcome.paramFloat1,
                                              nameDigit2: rawOutcome.paramFloat2,
                                              nameDigit3: rawOutcome.paramFloat3,
                                              paramBoolean1: rawOutcome.paramBoolean1,
                                              marketName: rawMarket.shortName ?? "",
                                              marketId: rawMarket.id,
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
                                    nameDigit1: rawMarket.paramFloat1,
                                    nameDigit2: rawMarket.paramFloat2,
                                    nameDigit3: rawMarket.paramFloat3,
                                    eventPartId: rawMarket.eventPartId,
                                    bettingTypeId: rawMarket.bettingTypeId,
                                    outcomes: sortedOutcomes)
                matchMarkets.append(market)
            }

            let sortedMarkets = matchMarkets.sorted { market1, market2 in
                let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 10000
                let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 10000
                return position1 < position2
            }

            var location: Location?
            if let rawLocation = self.location(forId: rawMatch.venueId ?? "") {
                location = Location(id: rawLocation.id, name: rawLocation.name ?? "", isoCode: rawLocation.code ?? "")
            }

            let match = Match(id: rawMatch.id,
                              competitionId: rawMatch.parentId ?? "",
                              competitionName: rawMatch.parentName ?? "",
                              homeParticipant: Participant(id: rawMatch.homeParticipantId ?? "",
                                                           name: rawMatch.homeParticipantName ?? ""),
                              awayParticipant: Participant(id: rawMatch.awayParticipantId ?? "",
                                                           name: rawMatch.awayParticipantName ?? ""),
                              date: rawMatch.startDate ?? Date(timeIntervalSince1970: 0),
                              sportType: rawMatch.sportId ?? "",
                              venue: location,
                              numberTotalOfMarkets: rawMatch.numberOfMarkets ?? 0,
                              markets: sortedMarkets,
                              rootPartId: rawMatch.rootPartId ?? "",
                              sportName: rawMatch.sportName ?? "")

            matchesList.append(match)
        }

        return matchesList
    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

}
