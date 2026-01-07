//
//  MyBetTestFixtures.swift
//  BetssonCameroonAppTests
//
//  Test fixtures for MyBet and related models.
//  Provides static factory methods for creating test data.
//

import Foundation
@testable import BetssonCameroonApp

// MARK: - MyBet Fixtures

extension MyBet {

    /// Active bet eligible for cashout
    static func activeBetWithCashout(
        identifier: String = "bet-123",
        stake: Double = 10.0,
        cashoutValue: Double = 50.0,
        remainingStake: Double? = nil,
        currency: String = "XAF"
    ) -> MyBet {
        MyBet(
            identifier: identifier,
            type: "single",
            state: .opened,
            result: .open,
            globalState: .opened,
            stake: stake,
            totalOdd: 5.0,
            potentialReturn: stake * 5.0,
            totalReturn: nil,
            currency: currency,
            selections: [.fixture()],
            date: Date(),
            freebet: false,
            partialCashoutReturn: cashoutValue,
            partialCashoutStake: remainingStake ?? stake,
            ticketCode: "TICKET-\(identifier)"
        )
    }

    /// Active bet without cashout value (SSE will provide it)
    static func activeBetNoCashout(identifier: String = "bet-no-cashout") -> MyBet {
        MyBet(
            identifier: identifier,
            type: "single",
            state: .opened,
            result: .open,
            globalState: .opened,
            stake: 10.0,
            totalOdd: 2.5,
            potentialReturn: 25.0,
            totalReturn: nil,
            currency: "XAF",
            selections: [.fixture()],
            date: Date(),
            freebet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            ticketCode: "TICKET-\(identifier)"
        )
    }

    /// Settled bet (won)
    static var settledWon: MyBet {
        MyBet(
            identifier: "bet-settled-won",
            type: "single",
            state: .won,
            result: .won,
            globalState: .won,
            stake: 10.0,
            totalOdd: 2.5,
            potentialReturn: 25.0,
            totalReturn: 25.0,
            currency: "XAF",
            selections: [.fixture(state: .won, result: .won)],
            date: Date(),
            freebet: false
        )
    }

    /// Settled bet (lost)
    static var settledLost: MyBet {
        MyBet(
            identifier: "bet-settled-lost",
            type: "single",
            state: .lost,
            result: .lost,
            globalState: .lost,
            stake: 10.0,
            totalOdd: 2.5,
            potentialReturn: 25.0,
            totalReturn: 0.0,
            currency: "XAF",
            selections: [.fixture(state: .lost, result: .lost)],
            date: Date(),
            freebet: false
        )
    }

    /// Fully cashed out bet
    static var cashedOut: MyBet {
        MyBet(
            identifier: "bet-cashed-out",
            type: "single",
            state: .cashedOut,
            result: .open,
            globalState: .cashedOut,
            stake: 10.0,
            totalOdd: 3.0,
            potentialReturn: 30.0,
            totalReturn: 20.0,
            currency: "XAF",
            selections: [.fixture()],
            date: Date(),
            freebet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            partialCashOuts: [
                PartialCashOut(
                    requestId: "req-cashout",
                    usedStake: 10.0,
                    cashOutAmount: 20.0,
                    status: "SUCCESS",
                    cashOutDate: Date()
                )
            ]
        )
    }

    /// Bet with previous partial cashouts
    static func betWithPreviousCashouts(
        totalCashedOut: Double = 15.0,
        remainingStake: Double = 5.0,
        remainingCashoutValue: Double = 20.0
    ) -> MyBet {
        MyBet(
            identifier: "bet-partial-history",
            type: "single",
            state: .opened,
            result: .open,
            globalState: .opened,
            stake: 10.0,
            totalOdd: 5.0,
            potentialReturn: 50.0,
            totalReturn: nil,
            currency: "XAF",
            selections: [.fixture()],
            date: Date(),
            freebet: false,
            partialCashoutReturn: remainingCashoutValue,
            partialCashoutStake: remainingStake,
            ticketCode: "TICKET-PARTIAL",
            partialCashOuts: [
                PartialCashOut(
                    requestId: "req-1",
                    usedStake: 5.0,
                    cashOutAmount: totalCashedOut,
                    status: "SUCCESS",
                    cashOutDate: Date().addingTimeInterval(-3600)
                )
            ]
        )
    }

    /// Multiple bet (combo)
    static var multipleBet: MyBet {
        MyBet(
            identifier: "bet-multiple",
            type: "multiple",
            state: .opened,
            result: .open,
            globalState: .opened,
            stake: 10.0,
            totalOdd: 15.0,
            potentialReturn: 150.0,
            totalReturn: nil,
            currency: "XAF",
            selections: [
                .fixture(identifier: "sel-1", eventName: "Team A vs Team B"),
                .fixture(identifier: "sel-2", eventName: "Team C vs Team D"),
                .fixture(identifier: "sel-3", eventName: "Team E vs Team F")
            ],
            date: Date(),
            freebet: false,
            partialCashoutReturn: 80.0,
            partialCashoutStake: 10.0
        )
    }
}

// MARK: - MyBetSelection Fixtures

extension MyBetSelection {

    /// Basic selection fixture
    static func fixture(
        identifier: String = "sel-1",
        state: MyBetState = .opened,
        result: MyBetResult = .open,
        eventName: String = "Team A vs Team B",
        homeTeamName: String = "Team A",
        awayTeamName: String = "Team B"
    ) -> MyBetSelection {
        MyBetSelection(
            identifier: identifier,
            state: state,
            result: result,
            globalState: state,
            eventName: eventName,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            eventDate: Date().addingTimeInterval(3600),
            tournamentName: "Premier League",
            sport: nil,
            marketName: "Match Result",
            outcomeName: "Team A",
            odd: .decimal(odd: 2.5),
            marketId: "market-\(identifier)",
            marketTypeId: "1X2",
            outcomeId: "outcome-\(identifier)",
            homeResult: nil,
            awayResult: nil,
            eventId: "event-\(identifier)",
            country: nil
        )
    }

    /// Live selection with score
    static func liveSelection(
        homeScore: String = "1",
        awayScore: String = "0"
    ) -> MyBetSelection {
        MyBetSelection(
            identifier: "sel-live",
            state: .opened,
            result: .open,
            globalState: .opened,
            eventName: "Live Team vs Opponent",
            homeTeamName: "Live Team",
            awayTeamName: "Opponent",
            eventDate: Date(),
            tournamentName: "Champions League",
            sport: nil,
            marketName: "Match Result",
            outcomeName: "Live Team",
            odd: .decimal(odd: 1.8),
            marketId: "market-live",
            marketTypeId: "1X2",
            outcomeId: "outcome-live",
            homeResult: homeScore,
            awayResult: awayScore,
            eventId: "event-live",
            country: nil
        )
    }
}

// MARK: - PartialCashOut Fixtures

extension PartialCashOut {

    /// Successful partial cashout
    static func fixture(
        requestId: String = "req-123",
        usedStake: Double = 5.0,
        cashOutAmount: Double = 15.0,
        status: String = "SUCCESS"
    ) -> PartialCashOut {
        PartialCashOut(
            requestId: requestId,
            usedStake: usedStake,
            cashOutAmount: cashOutAmount,
            status: status,
            cashOutDate: Date()
        )
    }
}
