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

            let firstBet: SportRadarModels.Bet? = internalBets.first

            let betSelections = internalBets.sorted { $0.order > $1.order }.map(Self.betSelection(fromInternalBet:))

            let firstConvertedBet = betSelections.first

            let potentialReturn: Double = internalBets.first?.potentialReturn ?? 0.0
            let totalReturn: Double = internalBets.first?.totalReturn ?? 0.0

            return Bet(identifier: identifier,
                       type: firstBet?.type ?? "",
                       state: firstConvertedBet?.state ?? .undefined,
                       result: firstConvertedBet?.result ?? .notSpecified,
                       globalState: firstConvertedBet?.globalState ?? .undefined,
                       stake: firstBet?.totalStake ?? 0.0,
                       totalOdd: firstBet?.totalOdd ?? 0.0,
                       selections: betSelections,
                       potentialReturn: potentialReturn == 0.0 ? totalReturn : potentialReturn,
                       date: firstBet?.attemptedDate ?? Date())
        }
        return BettingHistory(bets: bets.sorted(by: { $0.date > $1.date }))
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
        case .won: state = .won
        case .lost: state = .lost
        }

        let result: BetResult
        switch internalBet.result {
        case .open: result = .open
        case .won: result = .won
        case .lost: result = .lost
        case .drawn: result = .drawn
        case .pending: result = .pending
        case .notSpecified: result = .notSpecified
        case .void: result = .void
        }

        let globalState: BetState
        switch internalBet.globalState {
        case .opened: globalState = .opened
        case .closed: globalState = .closed
        case .settled: globalState = .settled
        case .cancelled: globalState = .cancelled
        case .undefined: globalState = .undefined
        case .attempted: globalState = .attempted
        case .allStates: globalState = .undefined
        case .won: globalState = .won
        case .lost: globalState = .lost
        }

        return BetSelection(identifier: internalBet.identifier,
                            state: state,
                            result: result,
                            globalState: globalState,
                            eventName: internalBet.eventName,
                            homeTeamName: internalBet.homeTeamName,
                            awayTeamName: internalBet.awayTeamName,
                            marketName: internalBet.marketName,
                            outcomeName: internalBet.outcomeName,
                            odd: OddFormat.fraction(numerator: Int(internalBet.oddNumerator),
                                                    denominator: Int(internalBet.oddDenominator)))
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
