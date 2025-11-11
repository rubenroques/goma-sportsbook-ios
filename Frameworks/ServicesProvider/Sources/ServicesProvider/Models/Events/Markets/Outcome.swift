//
//  Outcome.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public class Outcome: Codable, Equatable, Hashable {

    public var id: String
    public var name: String
    public var shortName: String?
    public var typeName: String?
    public var odd: OddFormat
    public var marketId: String?
    public var bettingOfferId: String?
    public var orderValue: String?
    public var externalReference: String?

    public var isTradable: Bool
    public var isTerminated: Bool

    public var customBetAvailableMarket: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case odd = "odd"
        case marketId = "marketId"
        case bettingOfferId = "bettingOfferId"
        case orderValue = "orderValue"
        case externalReference = "externalReference"
        case isTradable = "isTradable"
        case isTerminated = "isTerminated"
        case customBetAvailableMarket = "customBetAvailableMarket"
    }

    public init(id: String,
                name: String,
                shortName: String? = nil,
                typeName: String? = nil,
                odd: OddFormat,
                marketId: String? = nil,
                bettingOfferId: String? = nil,
                orderValue: String? = nil,
                externalReference: String? = nil,
                isTradable: Bool = true,
                isTerminated: Bool = false,
                customBetAvailableMarket: Bool?) {

        self.id = id
        self.name = name
        self.shortName = shortName
        self.typeName = typeName
        self.odd = odd
        self.marketId = marketId
        self.bettingOfferId = bettingOfferId
        self.orderValue = orderValue
        self.externalReference = externalReference
        self.isTradable = isTradable
        self.isTerminated = isTerminated
        self.customBetAvailableMarket = customBetAvailableMarket
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.odd = try container.decode(OddFormat.self, forKey: .odd)
        self.marketId = try container.decodeIfPresent(String.self, forKey: .marketId)
        self.bettingOfferId = try container.decodeIfPresent(String.self, forKey: .bettingOfferId)
        self.orderValue = try container.decodeIfPresent(String.self, forKey: .orderValue)
        self.externalReference = try container.decodeIfPresent(String.self, forKey: .externalReference)
        self.isTradable = (try? container.decode(Bool.self, forKey: .isTradable)) ?? false
        self.isTerminated = (try? container.decode(Bool.self, forKey: .isTerminated)) ?? false
        self.customBetAvailableMarket = try container.decodeIfPresent(Bool.self, forKey: .customBetAvailableMarket)
    }

    public static func == (lhs: Outcome, rhs: Outcome) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.odd == rhs.odd &&
        lhs.marketId == rhs.marketId &&
        lhs.bettingOfferId == rhs.bettingOfferId &&
        lhs.orderValue == rhs.orderValue &&
        lhs.externalReference == rhs.externalReference &&
        lhs.isTradable == rhs.isTradable &&
        lhs.isTerminated == rhs.isTerminated &&
        lhs.customBetAvailableMarket == rhs.customBetAvailableMarket
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(odd)
        hasher.combine(marketId)
        hasher.combine(bettingOfferId)
        hasher.combine(orderValue)
        hasher.combine(externalReference)
        hasher.combine(isTradable)
        hasher.combine(isTerminated)
        hasher.combine(customBetAvailableMarket)
    }
}
