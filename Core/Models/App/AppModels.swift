//
//  Market.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import Foundation
import GameController

struct CompetitionGroup {
    var id: String
    var name: String
    var aggregationType: AggregationType
    var competitions: [Competition]
    
    enum AggregationType {
        case popular
        case region
    }
}

struct Competition {
    var id: String
    var name: String
    var matches: [Match]
    var venue: Location?
    var outrightMarkets: Int

    init(id: String, name: String, matches: [Match] = [], venue: Location? = nil, outrightMarkets: Int) {
        self.id = id
        self.name = name
        self.matches = matches
        self.venue = venue
        self.outrightMarkets = outrightMarkets
    }
}

struct Match {
    var id: String
    var competitionId: String
    var competitionName: String
    var homeParticipant: Participant
    var awayParticipant: Participant
    var date: Date?
    var sportType: String
    var venue: Location?
    var numberTotalOfMarkets: Int
    var markets: [Market]
    var rootPartId: String
    var sportName: String?
}

struct Location {
    var id: String
    var name: String
    var isoCode: String
}

struct Participant {
    var id: String
    var name: String
}

struct Market {
    var id: String
    var typeId: String
    var name: String
    var nameDigit1: Double?
    var nameDigit2: Double?
    var nameDigit3: Double?

    var eventPartId: String?
    var bettingTypeId: String?

    var outcomes: [Outcome]

    init( id: String, typeId: String, name: String,
          nameDigit1: Double?, nameDigit2: Double?, nameDigit3: Double?,
          eventPartId: String?, bettingTypeId: String?, outcomes: [Outcome]) {
        self.id = id
        self.typeId = typeId
        self.name = name
        self.nameDigit1 = nameDigit1
        self.nameDigit2 = nameDigit2
        self.nameDigit3 = nameDigit3
        self.eventPartId = eventPartId
        self.bettingTypeId = bettingTypeId
        self.outcomes = outcomes
    }
}

struct Outcome {
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
        }

        return self.codeName
    }
}

struct BettingOffer {
    var id: String
    var value: Double
    var statusId: String
    var isLive: Bool
    var isAvailable: Bool
}

enum MarketType {
    case homeDrawAway
    case homeDrawAwayHalfTime
    case doubleChance
    case underOver(value: Int)
    case bothTeamsToScore
}

struct BannerInfo {
    var type: String
    var id: String
    var matchId: String?
    var imageURL: String?
    var priorityOrder: Int?
}


struct Country: Codable {
    var name: String
    var capital: String?
    var region: String
    var iso2Code: String
    var iso3Code: String
    var numericCode: String
    var phonePrefix: String
}


struct UserProfile: Codable {
    
    var userIdentifier: String
    var username: String
    var email: String
    var firstName: String?
    var lastName: String?
    var birthDate: Date
    
    var nationality: Country?
    var country: Country?
    
    var gender: String?
    var title: UserTitles?
    
    var personalIdNumber: String?
    var address: String?
    var province: String?
    var city: String?
    var postalCode: String?

    var isEmailVerified: Bool
    var isRegistrationCompleted: Bool
    
}
