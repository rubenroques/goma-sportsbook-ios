//
//  Market.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//

import Foundation

struct Market: Hashable {

    enum OutcomesOrder: Codable, Hashable {
        case none
        case odds // by odd
        case name // by name
        case setup // The original order that the server sends us
    }

    var id: String
    var typeId: String
    var name: String
    var isMainMarket: Bool

    var nameDigit1: Double?
    var nameDigit2: Double?
    var nameDigit3: Double?

    var eventPartId: String?
    var bettingTypeId: String?

    var outcomes: [Outcome]

    var marketTypeId: String?
    var marketTypeName: String?
    
    var eventName: String?
    var isMainOutright: Bool?
    var eventMarketCount: Int?
    var isAvailable: Bool

    var startDate: Date?
    var homeParticipant: String?
    var awayParticipant: String?

    var eventId: String?

    var competitionName: String?

    var statsTypeId: String?

    var outcomesOrder: OutcomesOrder

    var customBetAvailable: Bool?

    var sport: Sport?
    var sportIdCode: String?

    var venueCountry: Country?

    init(id: String,
         typeId: String,
         name: String,
         isMainMarket: Bool = false,
         nameDigit1: Double?,
         nameDigit2: Double?,
         nameDigit3: Double?,
         eventPartId: String?,
         bettingTypeId: String?,
         outcomes: [Outcome],
         marketTypeId: String? = nil,
         marketTypeName: String? = nil,
         eventName: String? = nil,
         isMainOutright: Bool? = nil,
         eventMarketCount: Int? = nil,
         isAvailable: Bool = true,
         startDate: Date? = nil,
         homeParticipant: String? = nil,
         awayParticipant: String? = nil,
         eventId: String? = nil,
         statsTypeId: String? = nil,
         outcomesOrder: OutcomesOrder,
         customBetAvailable: Bool? = nil,
         competitionName: String? = nil,
         sport: Sport? = nil,
         sportIdCode: String? = nil,
         venueCountry: Country? = nil
    ) {

        self.id = id
        self.typeId = typeId
        self.name = name
        self.isMainMarket = isMainMarket
        self.nameDigit1 = nameDigit1
        self.nameDigit2 = nameDigit2
        self.nameDigit3 = nameDigit3
        self.eventPartId = eventPartId
        self.bettingTypeId = bettingTypeId
        self.outcomes = outcomes
        self.marketTypeId = marketTypeId
        self.marketTypeName = marketTypeName
        self.eventName = eventName
        self.isMainOutright = isMainOutright
        self.eventMarketCount = eventMarketCount
        self.isAvailable = isAvailable
        self.startDate = startDate
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.eventId = eventId
        self.statsTypeId = statsTypeId
        self.outcomesOrder = outcomesOrder
        self.customBetAvailable = customBetAvailable
        self.competitionName = competitionName
        self.sport = sport
        self.sportIdCode = sportIdCode
        self.venueCountry = venueCountry
    }
}
