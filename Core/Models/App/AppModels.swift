//
//  Market.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import Foundation

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

    init(id: String, name: String, matches: [Match] = [], venue: Location? = nil) {
        self.id = id
        self.name = name
        self.matches = matches
        self.venue = venue
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
    var outcomes: [Outcome]
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
}

enum MarketType {
    case homeDrawAway
    case homeDrawAwayHalfTime
    case doubleChance
    case underOver(value: Int)
    case bothTeamsToScore
}

struct BannerInfo {
    let type: String
    let id: String
    let matchID: String?
    let imageURL: String?
    let priorityOrder: Int?
}
