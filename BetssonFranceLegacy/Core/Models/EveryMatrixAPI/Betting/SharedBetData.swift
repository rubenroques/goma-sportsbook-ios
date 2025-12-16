//
//  SharedBetData.swift
//  Sportsbook
//
//  Created by André Lascas on 07/02/2022.
//

import Foundation

struct SharedBetDataResponse: Decodable {

    var success: Bool
    var errorMessage: String?
    var sharedBetData: SharedBetData
    var betBuilder: Bool?

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case errorMessage = "errorMessage"
        case sharedBetData = "sharedBetData"
        case betBuilder = "betBuilder"
    }
}

struct SharedBetData: Decodable {

    var type: String
    var systemBetType: String?
    var placedDate: String
    var status: String
    var currentPossibleWinning: Double
    var totalBetAmount: Double
    var selections: [SharedBet]

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case systemBetType = "systemBetType"
        case placedDate = "placedDate"
        case status = "status"
        case currentPossibleWinning = "currentPossibleWinning"
        case totalBetAmount = "totalBetAmount"
        case selections = "selections"
    }
}

struct SharedBet: Decodable {

    var status: String
    var eventName: String
    var marketName: String
    var betName: String
    var priceValue: Double
    var betBuilderOdds: String?
    var eventId: String
    var bettingTypeId: String
    var bettingTypeEventPartId: String
    var outcomeId: String
    var bettingTypeEventPartName: String

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case eventName = "eventName"
        case marketName = "marketName"
        case betName = "betName"
        case priceValue = "priceValue"
        case betBuilderOdds = "betBuilderOdds"
        case eventId = "eventId"
        case bettingTypeId = "bettingTypeId"
        case bettingTypeEventPartId = "bettingTypeEventPartId"
        case outcomeId = "outcomeId"
        case bettingTypeEventPartName = "bettingTypeEventPartName"
    }
}
