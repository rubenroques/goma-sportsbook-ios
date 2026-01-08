//
//  BetslipSelectionState.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import Foundation

struct BetslipForbiddenCombinationSelection: Decodable {

    var bettingTypeId: String
    var priceValue: Double
    var outcomeId: String
    var bettingOfferId: String

    enum CodingKeys: String, CodingKey {
        case bettingTypeId = "bettingTypeId"
        case priceValue = "priceValue"
        case outcomeId = "outcomeId"
        case bettingOfferId = "bettingOfferId"
    }
}

struct BetslipForbiddenCombination: Decodable {

    var selections: [BetslipForbiddenCombinationSelection]

    enum CodingKeys: String, CodingKey {
        case selections = "selections"
    }
}

struct BetslipWinningsInfo: Decodable {

    var maxWinningNetto: Double?
    var totalBetAmountNetto: Double?

    enum CodingKeys: String, CodingKey {
        case maxWinningNetto = "maxWinningNetto"
        case totalBetAmountNetto = "totalBetAmountNetto"
    }
}

struct BetslipFreebet: Decodable {
    var walletId: String
    var freeBetAmount: Double
    var currency: String
    var validForSelectionOdds: Bool

    enum CodingKeys: String, CodingKey {
        case walletId = "walletId"
        case freeBetAmount = "freeBetAmount"
        case currency = "currency"
        case validForSelectionOdds = "validForSelectionOdds"
    }
}

struct BetslipOddsBoost: Decodable {
    var walletId: String
    var oddsBoostPercent: Double
    var capAmount: Double
    var validForSelectionOdds: Bool
    var expiryTime: String

    enum CodingKeys: String, CodingKey {
        case walletId = "walletId"
        case oddsBoostPercent = "oddsBoostPercent"
        case capAmount = "capAmount"
        case validForSelectionOdds = "validForSelectionOdds"
        case expiryTime = "expiryTime"
    }
}

struct BetslipSelectionState: Decodable {

    var minStake: Double?
    var maxStake: Double?
    var priceValueFactor: Double?
    var availableForManualBetRequest: Bool?
    var winnings: BetslipWinningsInfo?
    var forbiddenCombinations: [BetslipForbiddenCombination]
    var freeBets: [BetslipFreebet]
    var oddsBoosts: [BetslipOddsBoost]
    var betBuilder: [BetBuilder]?

    enum CodingKeys: String, CodingKey {
        case minStake = "minStake"
        case maxStake = "maxStake"
        case priceValueFactor = "priceValueFactor"
        case availableForManualBetRequest = "availableForManualBetRequest"
        case forbiddenCombinations = "forbiddenCombinations"
        case winnings = "maxWinningAndTaxes"
        case freeBets = "freeBets"
        case oddsBoosts = "oddsBoosts"
        case betBuilder = "betBuilder"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.minStake = try? container.decode(Double.self, forKey: .minStake)
        self.maxStake = try? container.decode(Double.self, forKey: .maxStake)
        self.priceValueFactor = try? container.decode(Double.self, forKey: .priceValueFactor)
        self.availableForManualBetRequest = try? container.decode(Bool.self, forKey: .availableForManualBetRequest)
        self.forbiddenCombinations = (try? container.decode([BetslipForbiddenCombination].self, forKey: .forbiddenCombinations)) ?? []
        self.winnings = try? container.decode(BetslipWinningsInfo.self, forKey: .winnings)
        self.freeBets = (try? container.decode([BetslipFreebet].self, forKey: .freeBets)) ?? []
        self.oddsBoosts = (try? container.decode([BetslipOddsBoost].self, forKey: .oddsBoosts)) ?? []
//        let betBuilderItems = try container.decode([FailableDecodable<BetBuilder>].self, forKey: .betBuilder)
//        self.betBuilder = betBuilderItems.compactMap({ $0.base })
        self.betBuilder = (try? container.decode([BetBuilder].self, forKey: .betBuilder)) ?? []
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

struct BetBuilder: Decodable {
    var betBuilderOdds: Double
    var selections: [BetBuilderSelection]

    enum CodingKeys: String, CodingKey {
        case betBuilderOdds = "betBuilderOdds"
        case selections = "selections"
    }
}

struct BetBuilderSelection: Decodable {
    var priceValue: Double
    var bettingOfferId: String
    var outcomeId: String
    var bettingTypeId: String

    enum CodingKeys: String, CodingKey {
        case priceValue = "priceValue"
        case bettingOfferId = "bettingOfferId"
        case outcomeId = "outcomeId"
        case bettingTypeId = "bettingTypeId"
    }
}
