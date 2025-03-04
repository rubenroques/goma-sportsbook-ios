//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation
import SharedModels

extension SportRadarModelMapper {

    static func bettingHistory(fromInternalBettingHistory internalBettingHistory: SportRadarModels.BettingHistory) -> BettingHistory {
        let betGroups = Dictionary.init(grouping: internalBettingHistory.bets, by: \.identifier)
        let bets = betGroups.map { identifier, internalBets in

            let firstBet: SportRadarModels.Bet? = internalBets.first

            let betSelections = internalBets.sorted { $0.order > $1.order }.map(Self.betSelection(fromInternalBet:))

            let firstConvertedBet = betSelections.first

            let potentialReturn: Double = internalBets.first?.potentialReturn ?? 0.0
            let totalReturn: Double = internalBets.first?.totalReturn ?? 0.0

            let uniqueEventIds = Set(betSelections.map(\.eventId))
            var betType = (firstBet?.type ?? "").lowercased()
            if betSelections.count >= 2, betType == "accumulator", uniqueEventIds.count == 1 {
                betType = "mix_match"
            }
            
            return Bet(identifier: identifier,
                       type: betType,
                       state: firstConvertedBet?.state ?? .undefined,
                       result: firstConvertedBet?.result ?? .notSpecified,
                       globalState: firstConvertedBet?.globalState ?? .undefined,
                       stake: firstBet?.totalStake ?? 0.0,
                       totalOdd: firstBet?.totalOdd ?? 0.0,
                       selections: betSelections,
                       potentialReturn: potentialReturn == 0.0 ? totalReturn : potentialReturn,
                       date: firstBet?.attemptedDate ?? Date(),
                       freebet: firstBet?.freeBet ?? false,
                       partialCashoutReturn: firstBet?.partialCashoutReturn,
                       partialCashoutStake: firstBet?.partialCashoutStake,
                       betslipId: firstBet?.betslipId,
                       cashbackReturn: firstBet?.cashbackReturn,
                       freebetReturn: firstBet?.freebetReturn,
                       potentialCashbackReturn: firstBet?.potentialCashbackReturn,
                       potentialFreebetReturn: firstBet?.potentialFreebetReturn)
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
        case .cashedOut: state = .cashedOut
        case .void: state = .void
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
        case .void: globalState = .void
        case .cashedOut: globalState = .cashedOut
        }

        let cleanedEventResult = (internalBet.eventResult ?? "").replacingOccurrences(of: " ", with: "")

        let homeResult: String? = cleanedEventResult.split(separator: ":")[safe: 0].map(String.init)
        let awayResult: String? = cleanedEventResult.split(separator: ":")[safe: 1].map(String.init)

        let eventIdString = String(format: "%.1f", internalBet.eventId)

        let country: Country? = Country.country(withName: internalBet.tournamentCountryName ?? "")

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
                                                    denominator: Int(internalBet.oddDenominator)),
                            homeResult: homeResult,
                            awayResult: awayResult,
                            eventId: eventIdString,
                            eventDate: internalBet.eventDate,
                            country: country,
                            sportType: SportType(name: internalBet.sportTypeName),
                            tournamentName: internalBet.tournamentName ?? "",
                            marketId: nil,
                            outcomeId: nil,
                            homeLogoUrl: nil,
                            awayLogoUrl: nil)
    }

    //  ServiceProvider ----> SportRadar


    //  SportRadar ---> ServiceProvider
    static func placedBetsResponse(fromInternalPlacedBetsResponse placedBetsResponse: SportRadarModels.PlacedBetsResponse) -> PlacedBetsResponse {
        let bets = placedBetsResponse.bets.map(Self.placedBetEntry(fromInternalPlacedBetEntry:))
        return PlacedBetsResponse(identifier: placedBetsResponse.identifier,
                                  bets: bets,
                                  detailedBets: nil,
                                  requiredConfirmation: false,
                                  totalStake: placedBetsResponse.totalStake)
    }

    static func placedBetEntry(fromInternalPlacedBetEntry placedBetEntry: SportRadarModels.PlacedBetEntry) -> PlacedBetEntry {
        let betLegs = placedBetEntry.betLegs.map(Self.placedBetLeg(fromInternalPlacedBetLeg:))
        return PlacedBetEntry(identifier: placedBetEntry.identifier,
                              potentialReturn: placedBetEntry.potentialReturn,
                              totalStake: placedBetEntry.totalAvailableStake,
                              betLegs: betLegs, type: placedBetEntry.type)
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
                                grouping: .system(identifier: betType.typeCode, name: betType.typeName, numberOfBets: betType.numberOfIndividualBets),
                                code: betType.typeCode,
                                numberOfBets: betType.numberOfIndividualBets,
                                potencialReturn: betType.potencialReturn)
        }
    }

    static func cashout(fromInternalCashout cashout: SportRadarModels.Cashout) -> Cashout {
        return Cashout(cashoutValue: cashout.cashoutValue, partialCashoutAvailable: cashout.partialCashoutAvailable)
    }

    static func cashoutResult(fromInternalCashoutResult cashoutResult: SportRadarModels.CashoutResult) -> CashoutResult {

        return CashoutResult(cashoutResult: cashoutResult.cashoutResult, cashoutReoffer: cashoutResult.cashoutReoffer, message: cashoutResult.message)
    }

    static func sharedTicketResponse(fromInternalSharedTicketResponse internalSharedTicketResponse: SportRadarModels.SharedTicketResponse) -> SharedTicketResponse {

        let mappedSharedBets = internalSharedTicketResponse.bets.map(Self.sharedBet(fromInternalSharedBet:))

        return SharedTicketResponse(bets: mappedSharedBets, totalStake: internalSharedTicketResponse.totalStake, betId: internalSharedTicketResponse.betId)

    }

    static func sharedBet(fromInternalSharedBet internalSharedBet: SportRadarModels.SharedBet) -> SharedBet {

        let mappedSharedBetSelections = internalSharedBet.betSelections.map(Self.sharedBetSelection(fromInternalSharedBetSelection:))

        return SharedBet(betSelections: mappedSharedBetSelections, winStake: internalSharedBet.winStake, potentialReturn: internalSharedBet.potentialReturn, totalStake: internalSharedBet.totalStake)
    }

    static func sharedBetSelection(fromInternalSharedBetSelection internalSharedBetSelection: SportRadarModels.SharedBetSelection) -> SharedBetSelection {

        return SharedBetSelection(id: internalSharedBetSelection.id, priceDenominator: internalSharedBetSelection.priceDenominator, priceNumerator: internalSharedBetSelection.priceNumerator, priceType: internalSharedBetSelection.priceType)
    }

    static func ticketSelection(fromInternalTicketSelection internalTicketSelection: SportRadarModels.TicketSelection) -> TicketSelection {

        return TicketSelection(id: internalTicketSelection.id, marketId: internalTicketSelection.marketId, name: internalTicketSelection.name, priceDenominator: internalTicketSelection.priceDenominator, priceNumerator: internalTicketSelection.priceNumerator)
    }

    static func cashbackResult(fromInternalCashbackResult cashbackResult: SportRadarModels.CashbackResult) -> CashbackResult {
        return CashbackResult(id: cashbackResult.id, amount: cashbackResult.amount, amountFree: cashbackResult.amountFree)
    }

}
