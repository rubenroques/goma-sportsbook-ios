//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

extension SportRadarModelMapper {


    static func bettingHistory(fromInternalBettingHistory internalBettingHistory: SportRadarModels.BettingHistory) -> BettingHistory {
        let betGroups = Dictionary.init(grouping: internalBettingHistory.bets, by: \.identifier)
        let bets = betGroups.map { identifier, internalBets in
            let betSelections = internalBets.map(Self.betSelection(fromInternalBet:))
            let potentialReturn: Double = internalBets.first?.potentialReturn ?? 0.0
            return Bet(identifier: identifier, selections: betSelections, potentialReturn: potentialReturn)
        }
        return BettingHistory(bets: bets)
    }

    static func betSelection(fromInternalBet internalBet: SportRadarModels.Bet) -> BetSelection {

        let state: BetState
        switch internalBet.state {
        case .opened: state = .opened
        case .closed: state = .closed
        case .settled: state = .settled
        case .cancelled: state = .cancelled
        case .undefined: state = .undefined
        case .attempted: state = .attempted
        case .allStates: state = .undefined
        }

        let result: BetResult
        switch internalBet.result {
        case .open: result = .open
        case .won: result = .won
        case .lost: result = .lost
        case .drawn: result = .drawn
        case .notSpecified: result = .notSpecified
        case .void: result = .void
        }

        return BetSelection(identifier: internalBet.identifier,
                            state: state,
                            result: result,
                            eventName: internalBet.eventName,
                            homeTeamName: internalBet.homeTeamName,
                            awayTeamName: internalBet.awayTeamName,
                            marketName: internalBet.marketName,
                            outcomeName: internalBet.outcomeName)
    }

    //  ServiceProvider ----> SportRadar


    //  SportRadar ---> ServiceProvider
    static func placedBetsResponse(fromInternalPlacedBetsResponse placedBetsResponse: SportRadarModels.PlacedBetsResponse) -> PlacedBetsResponse {
        let bets = placedBetsResponse.bets.map(Self.placedBetEntry(fromInternalPlacedBetEntry:))

        let betSucceed = placedBetsResponse.responseCode == "2" && placedBetsResponse.identifier != "0"
        return PlacedBetsResponse(identifier: placedBetsResponse.identifier,
                                 responseCode: placedBetsResponse.responseCode,
                                 succeed: betSucceed,
                                 bets: bets)
    }

    static func placedBetEntry(fromInternalPlacedBetEntry placedBetEntry: SportRadarModels.PlacedBetEntry) -> PlacedBetEntry {
        let betLegs = placedBetEntry.betLegs.map(Self.placedBetLeg(fromInternalPlacedBetLeg:))
        return PlacedBetEntry(identifier: placedBetEntry.identifier,
                              potentialReturn: placedBetEntry.potentialReturn,
                              placeStake: placedBetEntry.placeStake,
                              betLegs: betLegs)
    }

    static func placedBetLeg(fromInternalPlacedBetLeg placedBetLeg: SportRadarModels.PlacedBetLeg) -> PlacedBetLeg {
        return PlacedBetLeg(identifier: placedBetLeg.identifier,
                            priceType: placedBetLeg.priceType,
                            priceNumerator: placedBetLeg.priceNumerator,
                            priceDenominator: placedBetLeg.priceDenominator)
    }


    static func betType(fromInternalBetType betType: SportRadarModels.BetType) -> BetType {
        switch (betType.typeCode, betType.numberOfIndividualBets) {
        case ("S", _):
            return BetType.init(name: betType.typeName,
                                grouping: .single(identifier: betType.typeCode),
                                code: betType.typeCode,
                                numberOfBets: betType.numberOfIndividualBets,
                                potencialReturn: betType.potencialReturn)
        case ("C1", _):
            return BetType.init(name: betType.typeName,
                                grouping: .single(identifier: betType.typeCode),
                                code: betType.typeCode,
                                numberOfBets: betType.numberOfIndividualBets,
                                potencialReturn: betType.potencialReturn)
        case (_ , 1):
            return BetType.init(name: betType.typeName,
                                grouping: .multiple(identifier: betType.typeCode),
                                code: betType.typeCode,
                                numberOfBets: betType.numberOfIndividualBets,
                                potencialReturn: betType.potencialReturn)
        default:
            return BetType.init(name: betType.typeName,
                                grouping: .system(identifier: betType.typeCode, name: betType.typeName),
                                code: betType.typeCode,
                                numberOfBets: betType.numberOfIndividualBets,
                                potencialReturn: betType.potencialReturn)
        }
    }

}
