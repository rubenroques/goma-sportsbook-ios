//
//  SportType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

typealias SportTypes = [SportType]
enum SportType: String, Identifiable, Hashable, CaseIterable {

    case football = "1"
    case basketball = "8"
    case tennis = "3"
    case futsal = "49"
    case footballSimulated = "140"
    case tennisSimulated = "141"
    case americanFootball = "5"
    case baseball = "9"
    case chess = "52"
    case cricket = "26"
    case cycling = "37"
    case darts = "45"
    case fighting = "25"
    case golf = "2"
    case greyhounds = "27"
    case handball = "7"
    case harnessRacing = "74"
    case horseRacing = "24"
    case iceHockey = "6"
    case kabaddi = "155"
    case motorRacing = "23"
    case rugbyLeague = "28"
    case rugbyUnion = "39"
    case snooker = "36"
    case specials = "34"
    case tableTennis = "63"
    case volleyball = "20"
    case eSports = "96"

    init?(id: String) {
        switch id {
        case "1": self = .football
        case "8": self = .basketball
        case "3": self = .tennis
        case "49": self = .futsal
        case "140": self = .footballSimulated
        case "141": self = .tennisSimulated
        case "5": self = .americanFootball
        case "9": self = .baseball
        case "52": self = .chess
        case "26": self = .cricket
        case "37": self = .cycling
        case "45": self = .darts
        case "25": self = .fighting
        case "2": self = .golf
        case "27": self = .greyhounds
        case "7": self = .handball
        case "74": self = .harnessRacing
        case "24": self = .horseRacing
        case "6": self = .iceHockey
        case "155": self = .kabaddi
        case "23": self = .motorRacing
        case "28": self = .rugbyLeague
        case "39": self = .rugbyUnion
        case "36": self = .snooker
        case "34": self = .specials
        case "63": self = .tableTennis
        case "20": self = .volleyball
        case "96": self = .eSports
        default: return nil
        }
    }

    var id: RawValue {
        rawValue
    }
    var typeId: String {
        rawValue
    }

    var intValue: Int {
        Int(rawValue)!
    }

    var iconName: String {
        switch typeId {
        case "0":
            return "football_sport_icon"
        case "1":
            return "basketball_sport_icon"
        case "2":
            return "ice_hockey_sport_icon"
        case "3":
            return "tenis_sport_icon"
        default:
            return ""
        }
    }
}
