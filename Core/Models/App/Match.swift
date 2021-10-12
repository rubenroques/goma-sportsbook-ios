//
//  Market.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import Foundation

struct Match {
    var id: String
    var competitionName: String
    var homeParticipant: Participant
    var awayParticipant: Participant
    var date: Date
    var sportType: String
    var venue: Venue
    var markets: [Market]
}

struct Venue {
    var id: String
    var name: String
}

struct Participant {
    var id: String
    var name: String
}

struct Market {
    var id: String
    var typeId: String
    var name: String
    var outcomes: [Outcome]
}

struct Outcome {
    var id: String
    var name: String
    var bettingOffer: BettingOffer
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
