//
//  MatchWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation
import Combine

class MatchWidgetCellViewModel {

    var homeTeamName: String
    var awayTeamName: String
    var countryISOCode: String
    var startDateString: String
    var startTimeString: String
    var competitionName: String
    var isToday: Bool
    var countryId: String
    var store: AggregatorStore
    
    var match: Match?

    var firstMarketPublisher: CurrentValueSubject<Market?, Never> = .init(nil)

    private var cancellables = Set<AnyCancellable>()


    private var marketsForMatch: [String: Set<String>] = [:]   // [Match ID: [Markets IDs] ]
    private var markets: [String: EveryMatrix.Market] = [:]

    private var bettingOutcomesForMarket: [String: Set<String>] = [:]
    private var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]

    private var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]


    init(match: Match, store: AggregatorStore) {

        self.store = store
        self.match = match

        self.homeTeamName = match.homeParticipant.name
        self.awayTeamName = match.awayParticipant.name

        self.countryISOCode = match.venue?.isoCode ?? ""
        self.countryId = match.venue?.id ?? ""

        self.isToday = false
        self.startDateString = ""
        self.startTimeString = ""

        if let startDate = match.date {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                self.startDateString = customFormatter.string(from: startDate)
            }
            else {
                self.startDateString = relativeDateString // Today, Yesterday
            }

            self.isToday = Env.calendar.isDateInToday(startDate)
            self.startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)
        }

        self.competitionName = match.competitionName

        self.requestSportTargetedFirstMarket()
    }

    init(match: Match) {

        self.store = Env.everyMatrixStorage
        
        self.homeTeamName = match.homeParticipant.name
        self.awayTeamName = match.awayParticipant.name

        self.countryISOCode = match.venue?.isoCode ?? ""
        self.countryId = match.venue?.id ?? ""
        
        self.isToday = false
        self.startDateString = ""
        self.startTimeString = ""

        if let startDate = match.date {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                self.startDateString = customFormatter.string(from: startDate)
            }
            else {
                self.startDateString = relativeDateString // Today, Yesterday
            }

            self.isToday = Env.calendar.isDateInToday(startDate)
            self.startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)
        }

        self.competitionName = match.competitionName

        self.requestSportTargetedFirstMarket()
    }

    init(match: EveryMatrix.Match) {

        self.store = Env.everyMatrixStorage

        self.homeTeamName = match.homeParticipantName ?? ""
        self.awayTeamName = match.awayParticipantName ?? ""

        self.countryISOCode = ""
        self.countryId = ""
        if let venueId = match.venueId,
           let location = Env.everyMatrixStorage.location(forId: venueId),
           let code = location.code {
            self.countryISOCode = code
            self.countryId = location.id
        }

        self.isToday = false
        self.startDateString = ""
        self.startTimeString = ""

        if let startDate = match.startDate {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                self.startDateString = customFormatter.string(from: startDate)
            }
            else {
                self.startDateString = relativeDateString // Today, Yesterday
            }

            self.isToday = Env.calendar.isDateInToday(startDate)
            self.startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)
        }

        self.competitionName = match.parentName ?? ""

        self.requestSportTargetedFirstMarket()
    }

    func requestSportTargetedFirstMarket() {

        guard
            let match = self.match
        else {
            self.firstMarketPublisher.send(nil)
            return
        }

        if match.sportType == "3" { // Tennis
            Env.everyMatrixClient.manager
                .getModel(router: TSRouter.getMatchOdds(language: "en",
                                                        matchId: match.id,
                                                        bettingTypeId: "466"), // Tennis - Home Away - Full match
                          decodingType: EveryMatrix.MatchOdds.self)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { [weak self] matchOddsAggregator in
                    self?.processOddAggregator(matchOddsAggregator)
                }
                .store(in: &self.cancellables)
        }
        else if let firstMarket = match.markets.first {
            self.firstMarketPublisher.send(firstMarket)
        }

    }

    static var hourDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }()

    static var dayDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()

    static var normalDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale)
        return dateFormatter
    }()

    static var relativeDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale, hasRelativeDate: true)
        return dateFormatter
    }()

    func processOddAggregator(_ aggregator: EveryMatrix.MatchOdds) {

        for content in aggregator.content ?? [] {
            switch content {
            case .market(let marketContent):
                self.markets[marketContent.id] = marketContent

                if let matchId = marketContent.eventId {
                    if var marketsForIterationMatch = self.marketsForMatch[matchId] {
                        marketsForIterationMatch.insert(marketContent.id)
                        self.marketsForMatch[matchId] = marketsForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(marketContent.id)
                        self.marketsForMatch[matchId] = newSet
                    }
                }
            case .betOutcome(let betOutcomeContent):
                self.betOutcomes[betOutcomeContent.id] = betOutcomeContent

            case .bettingOffer(let bettingOfferContent):
                if let outcomeIdValue = bettingOfferContent.outcomeId {
                    self.bettingOffers[outcomeIdValue] = bettingOfferContent
                }
            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                if let marketId = marketOutcomeRelationContent.marketId,
                   let outcomeId = marketOutcomeRelationContent.outcomeId {

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

        self.convertMarkets()
    }

    func convertMarkets() {

        var matchMarkets: [Market] = []

        guard let rawMatch = self.match.value else {return}

        let marketsIds = self.marketsForMatch[rawMatch.id] ?? []
        let rawMarketsList = marketsIds.map { id in
            return self.markets[id]
        }
        .compactMap({$0})

        for rawMarket in rawMarketsList where rawMarket.eventPartId == "20" { // Home Away - Full match

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

        if let firstMatchingMarket = matchMarkets.first {
            self.firstMarketPublisher.send(firstMatchingMarket)
        }
        else {
            self.firstMarketPublisher.send(nil)
        }

    }

}
