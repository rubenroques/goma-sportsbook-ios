//
//  Outcome.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//

import Foundation

struct Outcome: Hashable {
    var id: String
    var codeName: String
    var typeName: String
    var translatedName: String
    var nameDigit1: Double?
    var nameDigit2: Double?
    var nameDigit3: Double?
    var paramBoolean1: Bool?
    var marketName: String?
    var marketId: String?
    var marketDigit1: Double?
    var bettingOffer: BettingOffer
    var orderValue: String?
    var externalReference: String?
    var customBetAvailableMarket: Bool?
    var isTerminated: Bool?

    init(id: String,
         codeName: String,
         typeName: String,
         translatedName: String,
         nameDigit1: Double? = nil,
         nameDigit2: Double? = nil,
         nameDigit3: Double? = nil,
         paramBoolean1: Bool? = nil,
         marketName: String? = nil,
         marketId: String? = nil,
         marketDigit1: Double? = nil,
         bettingOffer: BettingOffer,
         orderValue: String? = nil,
         externalReference: String? = nil,
         customBetAvailableMarket: Bool? = nil,
         isTerminated: Bool? = nil)
    {
        self.id = id
        self.codeName = codeName
        self.typeName = typeName
        self.translatedName = translatedName
        self.nameDigit1 = nameDigit1
        self.nameDigit2 = nameDigit2
        self.nameDigit3 = nameDigit3
        self.paramBoolean1 = paramBoolean1
        self.marketName = marketName
        self.marketId = marketId
        self.marketDigit1 = marketDigit1
        self.bettingOffer = bettingOffer
        self.orderValue = orderValue
        self.externalReference = externalReference
        self.customBetAvailableMarket = customBetAvailableMarket
        self.isTerminated = isTerminated
    }
}

extension Outcome {
    var headerCodeName: String {

        if self.nameDigit1 == nil && self.nameDigit2 == nil && self.nameDigit3 == nil {
            if self.codeName.isNotEmpty, let paramBoolean1 = self.paramBoolean1 {
                return "\(self.codeName)-\(paramBoolean1)"
            }
            else if let paramBoolean1 = self.paramBoolean1 {
                return "\(paramBoolean1)"
            }
            else if self.marketId != nil {
                if let orderValue = self.orderValue {
                    return orderValue
                }
                if self.orderValue == nil && (self.codeName == "other" || self.codeName == "autre") {
                    return "D"
                }
                return self.codeName
            }
        }

        return self.codeName
    }
}
