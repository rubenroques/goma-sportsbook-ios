//
//  BettingOffer.swift
//  Sportsbook
//
//  Created by André Lascas on 08/09/2021.
//

import Foundation

extension EveryMatrix {

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

        func bettingOfferUpdated(withOdd odd: Double?,
                                 isLive: Bool?,
                                 isAvailable: Bool?) -> BettingOffer {
            return BettingOffer(
                type: self.type,
                id: self.id,
                providerId: self.providerId,
                outcomeId: self.outcomeId,
                bettingTypeId: self.bettingTypeId,
                statusId: self.statusId,
                isLive: isLive ?? self.isLive,
                oddsValue: odd ?? self.oddsValue,
                couponKey: self.couponKey,
                lastChangedTime: self.lastChangedTime,
                bettingTypeName: self.bettingTypeName,
                shortBettingTypeName: self.shortBettingTypeName,
                isAvailable: isAvailable ?? self.isAvailable
            )
        }
    }


}
