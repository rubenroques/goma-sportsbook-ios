//
//  BetPlacedDetails.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import ServicesProvider

enum BetslipErrorType: Error {
    case emptyBetslip
    case betPlacementError
    case potentialReturn
    case betPlacementDetailedError(message: String)
    case betNeedsUserConfirmation(betDetails: PlacedBetsResponse)
    case forbiddenRequest
    case invalidStake
    case invalidBetBuilderSelections
    case insufficientSelections
    case noValidSelectionsFound
    case none
}

struct BetslipError {
    var errorMessage: String
    var errorType: BetslipErrorType
    
    init(errorMessage: String = "", errorType: BetslipErrorType = .none) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }
    
}

struct BetPlacedDetails {
    var response: BetslipPlaceBetResponse
}

struct BetPotencialReturn: Codable {
    var potentialReturn: Double
    var totalStake: Double
    var numberOfBets: Int
    var totalOdd: Double
}

struct BetslipTicketSelection: Decodable {

    var id: String
    var currentOdd: Double

    enum CodingKeys: String, CodingKey {
        case id = "bettingOfferId"
        case currentOdd = "priceValue"
    }
}

struct BetslipPlaceBetResponse: Decodable {

    var betId: String?
    var betSucceed: Bool?

    var errorCode: String?
    var errorMessage: String?

    var totalPriceValue: Double?
    var oddsValidationType: String?
    var maxWinningNetto: Double?
    var totalStakeTax: Double?
    var basePossibleProfit: Double?
    var amount: Double?
    var maxWinningTax: Double?
    var terminalType: String?
    var freeBetAmount: Double?
    var minStake: Double?
    var numberOfSelections: Int?
    var bonusBetAmount: Double?
    var maxStake: Double?
    var type: String?
    var totalStakeNetto: Double?
    var eachWay: Bool?
    var baseWinning: Double?
    var possibleProfit: Double?
    var freeBet: Bool?
    var maxWinning: Double?

    var selections: [BetslipPlaceEntry]?
    
    var betslipId: String?

    enum CodingKeys: String, CodingKey {
        case betId = "betId"
        case betSucceed = "success"
        case errorCode = "errorCode"
        case errorMessage = "errorMessage"

        case totalPriceValue = "totalPriceValue"
        case oddsValidationType = "oddsValidationType"
        case maxWinningNetto = "maxWinningNetto"
        case totalStakeTax = "totalStakeTax"
        case basePossibleProfit = "basePossibleProfit"
        case amount = "amount"
        case maxWinningTax = "maxWinningTax"
        case terminalType = "terminalType"
        case freeBetAmount = "freeBetAmount"
        case minStake = "minStake"
        case numberOfSelections = "numberOfSelections"
        case bonusBetAmount = "bonusBetAmount"
        case maxStake = "maxStake"
        case type = "type"
        case totalStakeNetto = "totalStakeNetto"
        case eachWay = "eachWay"
        case baseWinning = "baseWinning"
        case possibleProfit = "possibleProfit"
        case freeBet = "freeBet"
        case maxWinning = "maxWinning"

        case selections = "selections"
        case betslipId = "betslipId"
    }

    init(betId: String? = nil, betSucceed: Bool? = nil, errorCode: String? = nil, errorMessage: String? = nil, totalPriceValue: Double? = nil,
         oddsValidationType: String? = nil, maxWinningNetto: Double? = nil, totalStakeTax: Double? = nil, basePossibleProfit: Double? = nil,
         amount: Double? = nil, maxWinningTax: Double? = nil, terminalType: String? = nil, freeBetAmount: Double? = nil, minStake: Double? = nil,
         numberOfSelections: Int? = nil, bonusBetAmount: Double? = nil, maxStake: Double? = nil, type: String? = nil, totalStakeNetto: Double? = nil,
         eachWay: Bool? = nil, baseWinning: Double? = nil, possibleProfit: Double? = nil, freeBet: Bool? = nil, maxWinning: Double? = nil,
         selections: [BetslipPlaceEntry]? = nil,
         betslipId: String? = nil) {

        self.betId = betId
        self.betSucceed = betSucceed
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.totalPriceValue = totalPriceValue
        self.oddsValidationType = oddsValidationType
        self.maxWinningNetto = maxWinningNetto
        self.totalStakeTax = totalStakeTax
        self.basePossibleProfit = basePossibleProfit
        self.amount = amount
        self.maxWinningTax = maxWinningTax
        self.terminalType = terminalType
        self.freeBetAmount = freeBetAmount
        self.minStake = minStake
        self.numberOfSelections = numberOfSelections
        self.bonusBetAmount = bonusBetAmount
        self.maxStake = maxStake
        self.type = type
        self.totalStakeNetto = totalStakeNetto
        self.eachWay = eachWay
        self.baseWinning = baseWinning
        self.possibleProfit = possibleProfit
        self.freeBet = freeBet
        self.maxWinning = maxWinning
        self.selections = selections
        self.betslipId = betslipId
    }

    init(betId: String) {
        self.betId = betId
        self.betSucceed = nil
        self.errorCode = nil
        self.errorMessage = nil
        self.totalPriceValue = nil
        self.oddsValidationType = nil
        self.maxWinningNetto = nil
        self.totalStakeTax = nil
        self.basePossibleProfit = nil
        self.amount = nil
        self.maxWinningTax = nil
        self.terminalType = nil
        self.freeBetAmount = nil
        self.minStake = nil
        self.numberOfSelections = nil
        self.bonusBetAmount = nil
        self.maxStake = nil
        self.type = nil
        self.totalStakeNetto = nil
        self.eachWay = nil
        self.baseWinning = nil
        self.possibleProfit = nil
        self.freeBet = nil
        self.maxWinning = nil
        self.selections = nil
        self.betslipId = nil
    }
    
}

struct BetslipPlaceEntry: Codable {
    let id: String
    let outcomeId: String?
    let eventId: String?
    let priceValue: Double?

    enum CodingKeys: String, CodingKey {
        case id = "bettingOfferId"
        case priceValue = "priceValue"
        case eventId = "eventId"
        case outcomeId = "outcomeId"
    }

}
