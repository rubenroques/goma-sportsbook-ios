//
//  SuggestedBetSummary.swift
//  Sportsbook
//
//  Created by André Lascas on 09/12/2021.
//

import Foundation

struct SuggestedBetCardSummary: Codable, Hashable {
    var bets: [SuggestedBetSummary]
    var type: String?
    var totalOdd: Double?
}

struct SuggestedBetSummary: Codable, Hashable {

    let matchId: String
    let matchName: String?
    
    let marketId: String
    let outcomeId: String
    
    let homeParticipantName: String
    let awayParticipantName: String

    let venueId: String
    let sportName: String
    
    let marketName: String
    let outcomeName: String
    
    let paramFloat: String?
    let odd: OddFormat

    let competitionName: String?
    let extraSelectionInfo: ExtraSelectionInfo?

}

extension SuggestedBetCardSummary {
    static var mockSuggestedBetCardSummaries: [SuggestedBetCardSummary] {
        
        return  [
            
                SuggestedBetCardSummary(bets: [
                    SuggestedBetSummary(
                        matchId: "1",
                        matchName: nil,
                        marketId: "market1",
                        outcomeId: "outcome1",
                        homeParticipantName: "Team A",
                        awayParticipantName: "Team B",
                        venueId: "100",
                        sportName: "Football",
                        marketName: "Full Time Result",
                        outcomeName: "Team A to Win",
                        paramFloat: nil,
                        odd: .decimal(odd: 1.5),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    ),
                    SuggestedBetSummary(
                        matchId: "2",
                        matchName: nil,
                        marketId: "market2",
                        outcomeId: "outcome2",
                        homeParticipantName: "Team C",
                        awayParticipantName: "Team D",
                        venueId: "200",
                        sportName: "Football",
                        marketName: "Over/Under",
                        outcomeName: "Over 2.5 Goals",
                        paramFloat: "2.5",
                        odd: .decimal(odd: 2.0),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    )
                ]),
                SuggestedBetCardSummary(bets: [
                    SuggestedBetSummary(
                        matchId: "3",
                        matchName: nil,
                        marketId: "market3",
                        outcomeId: "outcome3",
                        homeParticipantName: "Team E",
                        awayParticipantName: "Team F",
                        venueId: "300",
                        sportName: "Football",
                        marketName: "Both Teams to Score",
                        outcomeName: "Yes",
                        paramFloat: nil,
                        odd: .decimal(odd: 1.8),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    )
                ]),
                SuggestedBetCardSummary(bets: [
                    SuggestedBetSummary(
                        matchId: "4",
                        matchName: nil,
                        marketId: "market4",
                        outcomeId: "outcome4",
                        homeParticipantName: "Team G",
                        awayParticipantName: "Team H",
                        venueId: "400",
                        sportName: "Football",
                        marketName: "Correct Score",
                        outcomeName: "2-1",
                        paramFloat: nil,
                        odd: .decimal(odd: 9.0),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    ),
                    SuggestedBetSummary(
                        matchId: "5",
                        matchName: nil,
                        marketId: "market5",
                        outcomeId: "outcome5",
                        homeParticipantName: "Team I",
                        awayParticipantName: "Team J",
                        venueId: "500",
                        sportName: "Football",
                        marketName: "Half Time/Full Time",
                        outcomeName: "Draw/Team I",
                        paramFloat: nil,
                        odd: .decimal(odd: 4.5),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    ),
                    SuggestedBetSummary(
                        matchId: "6",
                        matchName: nil,
                        marketId: "market6",
                        outcomeId: "outcome6",
                        homeParticipantName: "Team K",
                        awayParticipantName: "Team L",
                        venueId: "600",
                        sportName: "Football",
                        marketName: "Double Chance",
                        outcomeName: "Team K or Draw",
                        paramFloat: nil,
                        odd: .decimal(odd: 1.25),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    )
                ]),
                SuggestedBetCardSummary(bets: [
                    SuggestedBetSummary(
                        matchId: "7",
                        matchName: nil,
                        marketId: "market7",
                        outcomeId: "outcome7",
                        homeParticipantName: "Team M",
                        awayParticipantName: "Team N",
                        venueId: "700",
                        sportName: "Football",
                        marketName: "Asian Handicap",
                        outcomeName: "Team M -1.5",
                        paramFloat: "-1.5",
                        odd: .decimal(odd: 2.1),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    ),
                    SuggestedBetSummary(
                        matchId: "8",
                        matchName: nil,
                        marketId: "market8",
                        outcomeId: "outcome8",
                        homeParticipantName: "Team O",
                        awayParticipantName: "Team P",
                        venueId: "800",
                        sportName: "Football",
                        marketName: "First Goal Scorer",
                        outcomeName: "Player X",
                        paramFloat: nil,
                        odd: .decimal(odd: 5.0),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    )
                ]),
                SuggestedBetCardSummary(bets: [
                    SuggestedBetSummary(
                        matchId: "9",
                        matchName: nil,
                        marketId: "market9",
                        outcomeId: "outcome9",
                        homeParticipantName: "Team Q",
                        awayParticipantName: "Team R",
                        venueId: "900",
                        sportName: "Football",
                        marketName: "Full Time Result",
                        outcomeName: "Team Q to Win",
                        paramFloat: nil,
                        odd: .decimal(odd: 1.75),
                        competitionName: nil,
                        extraSelectionInfo: nil
                    )
                ])
            
        ]
        
    }
}
