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

struct BetslipSelectionState: Decodable {

    var minStake: Double?
    var maxStake: Double?
    var priceValueFactor: Double?
    var availableForManualBetRequest: Bool?
    var winnings: BetslipWinningsInfo?
    var forbiddenCombinations: [BetslipForbiddenCombination]

    enum CodingKeys: String, CodingKey {
        case minStake = "minStake"
        case maxStake = "maxStake"
        case priceValueFactor = "priceValueFactor"
        case availableForManualBetRequest = "availableForManualBetRequest"
        case forbiddenCombinations = "forbiddenCombinations"
        case winnings = "maxWinningAndTaxes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.minStake = try? container.decode(Double.self, forKey: .minStake)
        self.maxStake = try? container.decode(Double.self, forKey: .maxStake)
        self.priceValueFactor = try? container.decode(Double.self, forKey: .priceValueFactor)
        self.availableForManualBetRequest = try? container.decode(Bool.self, forKey: .availableForManualBetRequest)
        self.forbiddenCombinations = (try? container.decode([BetslipForbiddenCombination].self, forKey: .forbiddenCombinations)) ?? []
        self.winnings = try? container.decode(BetslipWinningsInfo.self, forKey: .winnings)
    }
}

struct BetslipPlaceBetResponse: Decodable {

    var betSucceed: Bool?
    var betId: String?

    var errorCode: String?
    var errorMessage: String?

    var selections: [EveryMatrix.BetslipTicketSelection]?

    enum CodingKeys: String, CodingKey {
        case betSucceed = "success"
        case betId = "betId"
        case errorCode = "errorCode"
        case errorMessage = "errorMessage"
        case selections
    }
}

