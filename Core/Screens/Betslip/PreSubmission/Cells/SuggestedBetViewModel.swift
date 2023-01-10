//
//  SuggestedBetViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 17/01/2022.
//

import Foundation
import Combine
import OrderedCollections

class SuggestedBetViewModel: NSObject {

    var betsArray: [Match] = []
    var suggestedBetCardSummary: SuggestedBetCardSummary
    
    var betslipTickets: [BettingTicket] = []
    var gameSuggestedViewsArray: [GameSuggestedView] = []
    var totalOdd: Double = 0
    var numberOfSelection: Int = 0
    var suggestedBetsArray: [Int: [Match]] = [:]
    var totalGomaSuggestedBets: Int = 0
    var reloadedState: Bool = false

    var suggestedCancellables = Set<AnyCancellable>()
    var cancellables = Set<AnyCancellable>()
    var suggestedBetsRegisters: [EndpointPublisherIdentifiable] = []
    var suggestedBet1RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet2RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet3RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet4RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBetsRetrievedPublishers: [CurrentValueSubject<Bool, Never>] = []
    var isViewModelFinishedLoading: CurrentValueSubject<Bool, Never> = .init(false)

    // Suggested Aggregator Variables
    var matches: [String: EveryMatrix.Match] = [:]
    var match: EveryMatrix.Match?
    var marketsForMatch: [String: Set<String>] = [:]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:]
    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var tournaments: [String: EveryMatrix.Tournament] = [:]
    var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []
    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    // Publishers
    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    init(suggestedBetCardSummary: SuggestedBetCardSummary) {

        self.suggestedBetCardSummary = suggestedBetCardSummary

        super.init()

        self.getLocations()
            .sink { [weak self] locations in
                for location in locations {
                    self?.locations[location.id] = location
                }
                self?.getSuggestedBetsOdds()
            }
            .store(in: &cancellables)
    }

    deinit {
        print("SuggestedBetViewModel deinit")
        self.unregisterSuggestedBets()
    }

    func getSuggestedBetsOdds() {

        self.suggestedBetsRetrievedPublishers.append(suggestedBet1RetrievedPublisher)
        self.suggestedBetsRetrievedPublishers.append(suggestedBet2RetrievedPublisher)
        self.suggestedBetsRetrievedPublishers.append(suggestedBet3RetrievedPublisher)
        self.suggestedBetsRetrievedPublishers.append(suggestedBet4RetrievedPublisher)

        Publishers.CombineLatest4(self.suggestedBet1RetrievedPublisher,
                                  self.suggestedBet2RetrievedPublisher,
                                  self.suggestedBet3RetrievedPublisher,
                                  self.suggestedBet4RetrievedPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bet1, bet2, bet3, bet4 in
                if bet1 && bet2 && bet3 && bet4 {
                    self?.setupBets()
                }
            })
            .store(in: &cancellables)

        self.subscribeSuggestedBet(suggestedBetCardSummary: self.suggestedBetCardSummary)

    }

    func unregisterSuggestedBets() {
        for suggestedBetRegister in self.suggestedBetsRegisters {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: suggestedBetRegister)
        }
    }

    func setupBets() {
        var totalOdd = 0.0
        var firstOdd = true

        var validMarkets = 0

        for gomaBet in self.suggestedBetCardSummary.bets {

            for match in betsArray {

                if match.id == "\(gomaBet.matchId)" {

                    // Regular market
                    if gomaBet.paramFloat == nil {
                        let gameTitle = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"

                        for market in match.markets {

                            for betOutcome in market.outcomes {

                                if betOutcome.codeName == gomaBet.bettingOption && market.typeId == "\(gomaBet.bettingType)" {

                                    if firstOdd {
                                        totalOdd = betOutcome.bettingOffer.decimalOdd
                                        firstOdd = false
                                    }
                                    else {
                                        totalOdd *= betOutcome.bettingOffer.decimalOdd
                                    }

                                    let gameInfo = "\(market.name)"

                                    let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)

                                    if let countryIsoCode = match.venue?.isoCode, let countryId = match.venue?.id {
                                        gameSuggestedView.setMatchFlag(isoCode: countryIsoCode, countryId: countryId)
                                    }

                                    validMarkets += 1

                                    self.gameSuggestedViewsArray.append(gameSuggestedView)

                                    self.addOutcomeToTicketArray(match: match, market: market, outcome: betOutcome)
                                }
                            }
                        }
                    }

                    // Over/Under Market
                    else {
                        let gameTitle = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"

                        for market in match.markets {

                            for betOutcome in market.outcomes {

                                var nameOddString = ""

                                if let nameOdd = betOutcome.nameDigit1 {
                                    nameOddString = "\(nameOdd)"
                                }

                                let nameOddGoma = gomaBet.paramFloat

                                if betOutcome.codeName == gomaBet.bettingOption && nameOddString == nameOddGoma {

                                    if firstOdd {
                                        totalOdd = betOutcome.bettingOffer.decimalOdd
                                        firstOdd = false
                                    }
                                    else {
                                        totalOdd *= betOutcome.bettingOffer.decimalOdd
                                    }

                                    let gameInfo = "\(market.name)"

                                    let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)

                                    if let countryIsoCode = match.venue?.isoCode, let countryId = match.venue?.id {
                                        gameSuggestedView.setMatchFlag(isoCode: countryIsoCode, countryId: countryId)
                                    }

                                    validMarkets += 1
                                    gameSuggestedView.frame.size.height = 60

                                    self.gameSuggestedViewsArray.append(gameSuggestedView)

                                    self.addOutcomeToTicketArray(match: match, market: market, outcome: betOutcome)
                                }
                            }

                        }
                    }
                }

            }
        }

        self.totalOdd = totalOdd
        self.numberOfSelection = validMarkets

        self.isViewModelFinishedLoading.send(true)
    }

    func getLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({ $0 })
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

    }

    func addOutcomeToTicketArray(match: Match, market: Market, outcome: Outcome) {
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        self.betslipTickets.append(bettingTicket)
    }

    func subscribeSuggestedBet(suggestedBetCardSummary: SuggestedBetCardSummary) {

        let betArray = suggestedBetCardSummary.bets
        
        self.totalGomaSuggestedBets = betArray.count

        for (index, bet) in betArray.enumerated() {

            let endpoint = TSRouter.matchMarketOdds(operatorId: Env.appSession.operatorId,
                                                    language: "en",
                                                    matchId: "\(bet.matchId)",
                                                    bettingType: "\(bet.bettingType)",
                                                    eventPartId: "\(bet.eventPartId)")

            Env.everyMatrixClient.manager
                .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { [weak self] state in
                    switch state {
                    case .connect(let publisherIdentifiable):
                        self?.suggestedBetsRegisters.append(publisherIdentifiable)
                    case .initialContent(let aggregator):
                        self?.setupSuggestedMatchesAggregatorProcessor(aggregator: aggregator, index: index)
                    case .updatedContent:
                        // TODO: Update odds for suggested bets
                        ()
                    case .disconnect:
                        ()
                    }
                })
                .store(in: &suggestedCancellables)
        }

    }

    private func setupSuggestedMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator, index: Int) {

        self.processSuggestedMatchAggregator(aggregator)

        let processedSuggestedMatch = self.processSuggestedMatch()

        if let suggestedMatch = processedSuggestedMatch {
            self.betsArray.append(suggestedMatch)
        }

        self.suggestedBetsRetrievedPublishers[index].send(true)
    }

    func processSuggestedMatchAggregator(_ aggregator: EveryMatrix.Aggregator) {

        self.match = nil

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament(let tournamentContent):
                tournaments[tournamentContent.id] = tournamentContent

            case .match(let matchContent):

                match = matchContent

            case .matchInfo:
                ()
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
            case .marketGroup:
                ()
            case .location:
                ()
            case .cashout:
               ()
            case .event:
                ()
            case .eventPartScore:
                ()
            case .unknown:
                ()
            }
        }

    }

    func processSuggestedMatch() -> Match? {

        guard let rawMatch = match else { return nil }

        var processedMatch: Match?

        var matchMarkets: [Market] = []

        let marketsIds = self.marketsForMatch[rawMatch.id] ?? []

        let rawMarketsList = marketsIds.map { [weak self] id in
            return self?.marketsPublishers[id]?.value
        }
        .compactMap({$0})

        for rawMarket  in rawMarketsList {

            let rawOutcomeIds = self.bettingOutcomesForMarket[rawMarket.id] ?? []

            let rawOutcomesList = rawOutcomeIds.map { [weak self] id in
                return self?.betOutcomes[id]
            }
            .compactMap({$0})

            var outcomes: [Outcome] = []
            for rawOutcome in rawOutcomesList {

                if let rawBettingOffer = self.bettingOffers[rawOutcome.id] {
                    let bettingOffer = BettingOffer(id: rawBettingOffer.id,
                                                    decimalOdd: rawBettingOffer.oddsValue ?? 0.0,
                                                    statusId: rawBettingOffer.statusId ?? "1",
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
            let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 100
            let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 100
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
                          rootPartId: rawMatch.rootPartId ?? "")

        processedMatch = match

        return processedMatch

    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

}
