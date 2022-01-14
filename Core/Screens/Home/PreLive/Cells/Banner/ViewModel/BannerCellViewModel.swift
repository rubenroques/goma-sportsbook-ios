//
//  BannerCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2021.
//

import Foundation
import Combine

class BannerLineCellViewModel {

    var banners: [BannerCellViewModel]

    init(banners: [BannerCellViewModel]) {
        self.banners = banners
    }
}

class BannerCellViewModel {

    enum PresentationType {
        case image
        case match
    }

    var presentationType: PresentationType
    var matchId: String?
    var imageURL: URL?

    var match: CurrentValueSubject<EveryMatrix.Match?, Never> = .init(nil)

    var completeMatch: CurrentValueSubject<Match?, Never> = .init(nil)

    // Aggregator variables
    var matches: [String: EveryMatrix.Match] = [:]
    // var markets: [String: EveryMatrix.Market] = [:]
    var marketsForMatch: [String: Set<String>] = [:]   // [Match ID: [Markets IDs] ]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]

    var cancellables = Set<AnyCancellable>()

    init(matchId: String?, imageURL: String) {
        self.matchId = matchId
        let imageURLString = imageURL

        if let matchId = self.matchId {
            self.presentationType = .match
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            self.requestMatchInfo(matchId)
            self.requestMatchOdds()
        }
        else {
            self.presentationType = .image
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
        }

    }

    func requestMatchOdds() {
        guard let matchId = self.matchId else {return}
        
        let matchPublisher = Env.everyMatrixClient.manager
            .getModel(router: TSRouter.getMatchOdds(language: "en", matchId: matchId, bettingTypeId: "69"),
                      decodingType: EveryMatrix.MatchOdds.self)
            .eraseToAnyPublisher()

        matchPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { value in
                self.processOddAggregator(value)
            }
        .store(in: &cancellables)

    }

    func requestMatchInfo(_ matchId: String) {
        let language = "en"
        Env.everyMatrixClient.getMatchDetails(language: language, matchId: matchId)
            .sink { _ in

            } receiveValue: { response in
                if let match = response.records?.first {
                    self.match.send(match)
                }
            }
            .store(in: &cancellables)
    }

    func processOddAggregator(_ aggregator: EveryMatrix.MatchOdds, shouldClear: Bool = false) {

        for content in aggregator.content ?? [] {
            switch content {

            case .match(let matchContent):

                matches[matchContent.id] = matchContent

            case .market(let marketContent):

                // markets[marketContent.id] = marketContent
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
            
            case .unknown:
                () // print("Unknown type ignored")

            }
        }

        self.joinMatchMarkets()
    }

    func joinMatchMarkets() {

        var matchMarkets: [Market] = []

        guard let rawMatch = self.match.value else {return}

        let marketsIds = self.marketsForMatch[rawMatch.id] ?? []
        let rawMarketsList = marketsIds.map { id in
            return self.marketsPublishers[id]?.value
        }
        .compactMap({$0})

        for rawMarket  in rawMarketsList {

            // Only 1X2 Ordinary Time
            if rawMarket.eventPartId == "3" {

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
                                              paramBoolean1: rawOutcome.paramBoolean1,
                                              marketName: rawMarket.shortName ?? "",
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
                                outcomes: sortedOutcomes)
            matchMarkets.append(market)
            }
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
                          numberTotalOfMarkets: rawMatch.numberOfMarkets ?? 0,
                          markets: matchMarkets,
                          rootPartId: rawMatch.rootPartId ?? ""
                          )

        self.completeMatch.send(match)

    }

    func oddPublisherForBettingOfferId(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }
    
}
