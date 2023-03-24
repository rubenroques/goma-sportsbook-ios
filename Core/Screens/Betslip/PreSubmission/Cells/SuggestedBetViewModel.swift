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
    var suggestedBet1RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet2RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet3RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBet4RetrievedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var suggestedBetsRetrievedPublishers: [CurrentValueSubject<Bool, Never>] = []
    var isViewModelFinishedLoading: CurrentValueSubject<Bool, Never> = .init(false)

    init(suggestedBetCardSummary: SuggestedBetCardSummary) {

        self.suggestedBetCardSummary = suggestedBetCardSummary

        super.init()

        self.getSuggestedBetsOdds()
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

    func addOutcomeToTicketArray(match: Match, market: Market, outcome: Outcome) {
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        self.betslipTickets.append(bettingTicket)
    }

    func subscribeSuggestedBet(suggestedBetCardSummary: SuggestedBetCardSummary) {
        let betArray = suggestedBetCardSummary.bets
        self.betsArray = []
        self.totalGomaSuggestedBets = betArray.count
    }

}
