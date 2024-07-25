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

    var suggestedBetCardSummary: SuggestedBetCardSummary
    
    var betslipTickets: [BettingTicket] = []
    var gameSuggestedViewsArray: [GameSuggestedView] = []

    var totalOdd: Double = 0
    var numberOfSelection: Int = 0
    var suggestedBetsArray: [Int: [Match]] = [:]
    var totalGomaSuggestedBets: Int = 0

    var isViewModelFinishedLoading: CurrentValueSubject<Bool, Never> = .init(false)

    init(suggestedBetCardSummary: SuggestedBetCardSummary) {

        self.suggestedBetCardSummary = suggestedBetCardSummary

        super.init()

        self.setupBets()
    }

    func getSuggestedBetsOdds() {

    }

    func setupBets() {
        var totalOdd = 1.0
        var firstOdd = true

        var validMarkets = 0

        for suggestedBet in self.suggestedBetCardSummary.bets {
            
            totalOdd *= suggestedBet.odd.decimalValue
            
            let gameTitle = "\(suggestedBet.homeParticipantName) x \(suggestedBet.awayParticipantName)"
            
            let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: suggestedBet.marketName)
            
            gameSuggestedView.setMatchFlag(isoCode: suggestedBet.venueId, countryId: "")
            
            validMarkets += 1
            
            self.gameSuggestedViewsArray.append(gameSuggestedView)
                        
            self.betslipTickets.append(BettingTicket(id: suggestedBet.outcomeId,
                                                     outcomeId: suggestedBet.outcomeId,
                                                     marketId: suggestedBet.marketId,
                                                     matchId: suggestedBet.matchId,
                                                     decimalOdd: suggestedBet.odd.decimalValue,
                                                     isAvailable: true,
                                                     matchDescription: gameTitle,
                                                     marketDescription: suggestedBet.marketName,
                                                     outcomeDescription: suggestedBet.outcomeName,
                                                     homeParticipantName: suggestedBet.homeParticipantName,
                                                     awayParticipantName: suggestedBet.awayParticipantName,
                                                     sport: nil,
                                                     sportIdCode: nil,
                                                     venue: Location(id: suggestedBet.venueId, name: "", isoCode: ""),
                                                     competition: nil,
                                                     date: nil))
        }

        self.totalOdd = totalOdd
        self.numberOfSelection = validMarkets

        self.isViewModelFinishedLoading.send(true)
    }

}
