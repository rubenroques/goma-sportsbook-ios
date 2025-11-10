//
//  Market.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import SharedModels

public class Market: Codable, Equatable, Hashable, Identifiable {

    public enum OutcomesOrder: Codable, Hashable {
        case none
        case odds // by odd
        case name // by name
        case setup // The original order that the server sends us
    }

    public var id: String
    public var name: String
    public var outcomes: [Outcome]

    public var marketTypeId: String?
    public var marketTypeName: String?

    public var marketFilterId: String?
    public var eventMarketTypeId: String?
    public var eventName: String?
    public var isMainOutright: Bool?
    public var eventMarketCount: Int?
    public var isTradable: Bool
    public var startDate: Date?
    public var homeParticipant: String?
    public var awayParticipant: String?
    public var eventId: String?
    public var marketDigitLine: String?
    public var outcomesOrder: OutcomesOrder
    public var customBetAvailable: Bool?

    public var stats: Stats?

    public var isMainMarket: Bool

    // Event related properties
    public var competitionId: String?
    public var competitionName: String?
    public var sport: SportType?
    public var sportIdCode: String?

    public var venueCountry: Country?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case marketTypeName = "marketTypeName"
        case marketFilterId = "marketFilterId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
        case isMainOutright = "ismainoutright"
        case eventMarketCount = "eventMarketCount"
        case isTradable = "isTradable"
        case startDate = "tsstart"
        case homeParticipant = "participantname_home"
        case awayParticipant = "participantname_away"
        case eventId = "idfoevent"
        case marketDigitLine = "marketDigitLine"
        case outcomesOrder = "outcomesOrder"
        case customBetAvailable = "custombetavailable"
        case sport = "sport"
        case sportIdCode = "sportIdCode"
        case venueCountry = "venueCountry"
        case isMainMarket = "isMainMarket"
        case stats = "stats"
    }

    public init(id: String,
                name: String,
                outcomes: [Outcome],

                marketTypeId: String?,
                marketTypeName: String?,

                marketFilterId: String?,
                eventMarketTypeId: String?,
                eventName: String?,
                isMainOutright: Bool?,
                eventMarketCount: Int?,
                isTradable: Bool,
                startDate: Date?,
                homeParticipant: String?,
                awayParticipant: String?,
                eventId: String?,
                marketDigitLine: String?,
                outcomesOrder: OutcomesOrder = .none,
                competitionId: String? = nil,
                competitionName: String? = nil,
                sport: SportType? = nil,
                sportIdCode: String?,
                venueCountry: Country? = nil,
                customBetAvailable: Bool?,
                isMainMarket: Bool,
                stats: Stats? = nil) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.marketTypeId = marketTypeId
        self.marketTypeName = marketTypeName
        self.marketFilterId = marketFilterId
        self.eventMarketTypeId = eventMarketTypeId
        self.eventName = eventName
        self.isMainOutright = isMainOutright
        self.eventMarketCount = eventMarketCount
        self.isTradable = isTradable
        self.startDate = startDate
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.eventId = eventId
        self.marketDigitLine = marketDigitLine
        self.outcomesOrder = outcomesOrder

        // Event related properties
        self.competitionId = competitionId
        self.competitionName = competitionName

        self.sport = sport
        self.sportIdCode = sportIdCode

        self.venueCountry = venueCountry

        self.customBetAvailable = customBetAvailable
        self.isMainMarket = isMainMarket
        self.stats = stats
    }

    public static func == (lhs: Market, rhs: Market) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.outcomes == rhs.outcomes &&
        lhs.marketTypeId == rhs.marketTypeId &&
        lhs.eventMarketTypeId == rhs.eventMarketTypeId &&
        lhs.eventName == rhs.eventName &&
        lhs.isMainOutright == rhs.isMainOutright &&
        lhs.eventMarketCount == rhs.eventMarketCount &&
        lhs.isTradable == rhs.isTradable &&
        lhs.startDate == rhs.startDate &&
        lhs.homeParticipant == rhs.homeParticipant &&
        lhs.awayParticipant == rhs.awayParticipant &&
        lhs.eventId == rhs.eventId &&
        lhs.outcomesOrder == rhs.outcomesOrder &&
        lhs.customBetAvailable == rhs.customBetAvailable &&
        lhs.isMainMarket == rhs.isMainMarket
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(outcomes)
        hasher.combine(marketTypeId)
        hasher.combine(eventMarketTypeId)
        hasher.combine(eventName)
        hasher.combine(isMainOutright)
        hasher.combine(eventMarketCount)
        hasher.combine(isTradable)
        hasher.combine(startDate)
        hasher.combine(homeParticipant)
        hasher.combine(awayParticipant)
        hasher.combine(eventId)
        hasher.combine(outcomesOrder)
        hasher.combine(customBetAvailable)
        hasher.combine(isMainMarket)
    }
}
