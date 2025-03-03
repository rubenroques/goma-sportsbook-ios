//
//  PreviewModelsHelper.swift
//  Sportsbook
//
//  Created by
//

import Foundation
import ServicesProvider
import UIKit

/// Helper struct containing mock models for SwiftUI previews
struct PreviewModelsHelper {

    // MARK: - Participants

    /// Creates a mock home participant
    static func createHomeParticipant() -> Participant {
        return Participant(
            id: "1",
            name: "Team A"
        )
    }

    /// Creates a mock away participant
    static func createAwayParticipant() -> Participant {
        return Participant(
            id: "2",
            name: "Team B"
        )
    }

    // MARK: - Betting Offers

    /// Creates a mock betting offer for the home team
    static func createHomeBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo1",
            decimalOdd: 1.5,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a mock betting offer for a draw
    static func createDrawBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo2",
            decimalOdd: 3.5,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a mock betting offer for the away team
    static func createAwayBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo3",
            decimalOdd: 5.0,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a custom betting offer with specified odd
    static func createCustomBettingOffer(id: String = UUID().uuidString, odd: Double, isLive: Bool = false) -> BettingOffer {
        return BettingOffer(
            id: id,
            decimalOdd: odd,
            statusId: "ACTIVE",
            isLive: isLive,
            isAvailable: true
        )
    }

    /// Creates a suspended betting offer
    static func createSuspendedBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "suspended",
            decimalOdd: 0.0,
            statusId: "SUSPENDED",
            isLive: false,
            isAvailable: false
        )
    }

    // MARK: - Outcomes

    /// Creates a mock home win outcome
    static func createHomeOutcome() -> Outcome {
        return Outcome(
            id: "1",
            codeName: "1",
            typeName: "1",
            translatedName: "Home",
            bettingOffer: createHomeBettingOffer()
        )
    }

    /// Creates a mock draw outcome
    static func createDrawOutcome() -> Outcome {
        return Outcome(
            id: "2",
            codeName: "X",
            typeName: "X",
            translatedName: "Draw",
            bettingOffer: createDrawBettingOffer()
        )
    }

    /// Creates a mock away win outcome
    static func createAwayOutcome() -> Outcome {
        return Outcome(
            id: "3",
            codeName: "2",
            typeName: "2",
            translatedName: "Away",
            bettingOffer: createAwayBettingOffer()
        )
    }

    /// Creates a custom outcome with specified parameters
    static func createCustomOutcome(id: String, codeName: String, typeName: String, translatedName: String, odd: Double) -> Outcome {
        return Outcome(
            id: id,
            codeName: codeName,
            typeName: typeName,
            translatedName: translatedName,
            bettingOffer: createCustomBettingOffer(odd: odd)
        )
    }

    // MARK: - Markets

    /// Creates a mock 1X2 market
    static func create1X2Market() -> Market {
        return Market(
            id: "1",
            typeId: "1X2",
            name: "1X2",
            isMainMarket: true,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [createHomeOutcome(), createDrawOutcome(), createAwayOutcome()],
            outcomesOrder: .setup
        )
    }

    /// Creates a mock Over/Under market
    static func createOverUnderMarket(value: Double = 2.5) -> Market {
        let over = createCustomOutcome(id: "ou1", codeName: "Over", typeName: "Over", translatedName: "Over \(value)", odd: 1.85)
        let under = createCustomOutcome(id: "ou2", codeName: "Under", typeName: "Under", translatedName: "Under \(value)", odd: 1.95)

        return Market(
            id: "2",
            typeId: "OVER_UNDER",
            name: "Total Goals",
            isMainMarket: false,
            nameDigit1: value,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [over, under],
            outcomesOrder: .setup
        )
    }

    /// Creates a mock Double Chance market
    static func createDoubleChanceMarket() -> Market {
        let homeDraw = createCustomOutcome(id: "dc1", codeName: "1X", typeName: "1X", translatedName: "Home or Draw", odd: 1.25)
        let homeAway = createCustomOutcome(id: "dc2", codeName: "12", typeName: "12", translatedName: "Home or Away", odd: 1.30)
        let drawAway = createCustomOutcome(id: "dc3", codeName: "X2", typeName: "X2", translatedName: "Draw or Away", odd: 1.40)

        return Market(
            id: "3",
            typeId: "DOUBLE_CHANCE",
            name: "Double Chance",
            isMainMarket: false,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [homeDraw, homeAway, drawAway],
            outcomesOrder: .setup
        )
    }

    /// Creates a list of multiple markets for a comprehensive match view
    static func createMultipleMarkets() -> [Market] {
        return [
            create1X2Market(),
            createOverUnderMarket(),
            createDoubleChanceMarket()
        ]
    }

    // MARK: - Location/Venue

    /// Creates a mock venue
    static func createVenue() -> Location {
        return Location(id: "venue1", name: "Stadium", isoCode: "GB")
    }

    // MARK: - Sport

    /// Creates a mock Football sport
    static func createFootballSport() -> Sport {
        return Sport(
            id: "1",
            name: "Football",
            alphaId: "FB",
            numericId: "01",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    /// Creates a mock Basketball sport
    static func createBasketballSport() -> Sport {
        return Sport(
            id: "2",
            name: "Basketball",
            alphaId: "BB",
            numericId: "02",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    /// Creates a mock Tennis sport
    static func createTennisSport() -> Sport {
        return Sport(
            id: "3",
            name: "Tennis",
            alphaId: "TN",
            numericId: "03",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    // MARK: - Match

    /// Creates a mock football match with complete data
    static func createFootballMatch() -> Match {
        return Match(
            id: "123",
            competitionId: "comp1",
            competitionName: "Premier League",
            homeParticipant: createHomeParticipant(),
            awayParticipant: createAwayParticipant(),
            homeParticipantScore: 0,
            awayParticipantScore: 0,
            date: Date(),
            sport: createFootballSport(),
            sportIdCode: "football",
            venue: createVenue(),
            numberTotalOfMarkets: 10,
            markets: [create1X2Market()],
            rootPartId: "root1",
            status: .notStarted,
            trackableReference: nil,
            matchTime: nil,
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: nil
        )
    }

    /// Creates a mock football match that is currently live
    static func createLiveFootballMatch() -> Match {
        var match = createFootballMatch()
        // Set the match to live status and add scores
        match.status = .inProgress("21")
        match.homeParticipantScore = 1
        match.awayParticipantScore = 0
        match.matchTime = "21:06"
        return match
    }

    /// Creates a mock football match that is completed
    static func createCompletedFootballMatch() -> Match {
        var match = createFootballMatch()
        // Set the match to completed status with final score
        match.status = .ended
        match.homeParticipantScore = 2
        match.awayParticipantScore = 1
        return match
    }

    /// Creates a football match with multiple markets
    static func createFootballMatchWithMultipleMarkets() -> Match {
        var match = createFootballMatch()
        match.markets = createMultipleMarkets()
        match.numberTotalOfMarkets = match.markets.count
        return match
    }

    // MARK: - UIKit Helpers

    /// Creates a preview container for table view cells
    static func createPreviewContainer<T: UITableViewCell>(for cell: T, height: CGFloat = 176) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        container.addSubview(cell)
        container.backgroundColor = .systemBackground

        cell.frame = container.bounds

        // Proper display settings
        container.layer.masksToBounds = true

        return container
    }
}
