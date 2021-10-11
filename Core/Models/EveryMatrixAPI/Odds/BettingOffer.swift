//
//  BettingOffer.swift
//  Sportsbook
//
//  Created by André Lascas on 08/09/2021.
//

import Foundation

struct BettingOffer: Decodable {

    let type: String
    let id: String
    let providerId: String?
    let outcomeId: String?
    let bettingTypeId: String?
    let statusId: String?
    let isLive: Bool?
    let oddsValue: Double?
    let couponKey: String?
    let lastChangedTime: Int?
    let bettingTypeName: String?
    let shortBettingTypeName: String?
    let isAvailable: Bool?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case providerId = "providerId"
        case outcomeId = "outcomeId"
        case bettingTypeId = "bettingTypeId"
        case statusId = "statusId"
        case isLive = "isLive"
        case oddsValue = "odds"
        case couponKey = "couponKey"
        case lastChangedTime = "lastChangedTime"
        case bettingTypeName = "bettingTypeName"
        case shortBettingTypeName = "shortBettingTypeName"
        case isAvailable = "isAvailable"
    }
}
