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

    var id: RawValue {
        rawValue
    }
    var typeId: String {
        rawValue
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
