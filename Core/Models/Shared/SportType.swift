//
//  SportType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

enum SportType: String, Identifiable, Hashable {

    case football = "1"
    case golf = "2"
    case tennis = "3"
    case americanFootball = "5"
    case iceHockey = "6"
    case handball = "7"
    case basketball = "8"
    case baseball = "9"
    case fieldHockey = "10"
    case softball = "11"
    case weightlifting = "12"
    case athletics = "13"
    case badminton = "14"
    case gymnastics = "15"
    case rowing = "16"
    case sailing = "17"
    case swimming = "18"
    case triathlon = "19"
    case volleyball = "20"
    case wintersports = "21"
    case waterPolo = "22"
    case motorRacing = "23"
    case horseRacing = "24"
    case fighting = "25"
    case cricket = "26"
    case greyhounds = "27"
    case rugbyLeague = "28"
    case specials = "34"
    case snooker = "36"
    case cycling = "37"
    case afl = "38"
    case rugbyUnion = "39"
    case bandy = "40"
    case floorball = "41"
    case darts = "45"
    case hurling = "46"
    case gaelicFootball = "47"
    case pool = "48"
    case futsal = "49"
    case surfing = "50"
    case poker = "51"
    case chess = "52"
    case alpineSkiing = "53"
    case crossCountrySkiing = "54"
    case freestyleSkiing = "55"
    case nordicCombined = "56"
    case skiJumping = "57"
    case snowboard = "58"
    case biathlon = "59"
    case curling = "60"
    case bobsleigh = "61"
    case lacrosse = "62"
    case tableTennis = "63"
    case beachVolleyball = "64"
    case canoeing = "65"
    case beachFootball = "66"
    case bowls = "67"
    case luge = "68"
    case figureSkating = "69"
    case skeleton = "70"
    case speedSkating = "71"
    case shortTrackSpeedSkating = "72"
    case netball = "73"
    case harnessRacing = "74"
    case fencing = "75"
    case squash = "76"
    case horseball = "77"
    case judo = "78"
    case petanque = "79"
    case basquePelota = "80"
    case diving = "81"
    case equestrianSports = "82"
    case virtualSports = "83"
    case sepakTakraw = "84"
    case archery = "85"
    case pesapallo = "89"
    case fantasyDuels = "93"
    case eSports = "96"
    case bowling = "102"
    case virtualESports = "113"
    case footballSimulated = "140"
    case tennisSimulated = "141"
    case boatRacing = "146"
    case sumo = "147"
    case modernPentathlon = "151"
    case shooting = "152"
    case skateboarding = "153"
    case sportClimbing = "154"
    case kabaddi = "155"
    case unknown = "-1"

    init?(id: String) {
        switch id {
        case "1": self = .football
        case "2": self = .golf
        case "3": self = .tennis
        case "5": self = .americanFootball
        case "6": self = .iceHockey
        case "7": self = .handball
        case "8": self = .basketball
        case "9": self = .baseball
        case "10": self = .fieldHockey
        case "11": self = .softball
        case "12": self = .weightlifting
        case "13": self = .athletics
        case "14": self = .badminton
        case "15": self = .gymnastics
        case "16": self = .rowing
        case "17": self = .sailing
        case "18": self = .swimming
        case "19": self = .triathlon
        case "20": self = .volleyball
        case "21": self = .wintersports
        case "22": self = .waterPolo
        case "23": self = .motorRacing
        case "24": self = .horseRacing
        case "25": self = .fighting
        case "26": self = .cricket
        case "27": self = .greyhounds
        case "28": self = .rugbyLeague
        case "34": self = .specials
        case "36": self = .snooker
        case "37": self = .cycling
        case "38": self = .afl
        case "39": self = .rugbyUnion
        case "40": self = .bandy
        case "41": self = .floorball
        case "45": self = .darts
        case "46": self = .hurling
        case "47": self = .gaelicFootball
        case "48": self = .pool
        case "49": self = .futsal
        case "50": self = .surfing
        case "51": self = .poker
        case "52": self = .chess
        case "53": self = .alpineSkiing
        case "54": self = .crossCountrySkiing
        case "55": self = .freestyleSkiing
        case "56": self = .nordicCombined
        case "57": self = .skiJumping
        case "58": self = .snowboard
        case "59": self = .biathlon
        case "60": self = .curling
        case "61": self = .bobsleigh
        case "62": self = .lacrosse
        case "63": self = .tableTennis
        case "64": self = .beachVolleyball
        case "65": self = .canoeing
        case "66": self = .beachFootball
        case "67": self = .bowls
        case "68": self = .luge
        case "69": self = .figureSkating
        case "70": self = .skeleton
        case "71": self = .speedSkating
        case "72": self = .shortTrackSpeedSkating
        case "73": self = .netball
        case "74": self = .harnessRacing
        case "75": self = .fencing
        case "76": self = .squash
        case "77": self = .horseball
        case "78": self = .judo
        case "79": self = .petanque
        case "80": self = .basquePelota
        case "81": self = .diving
        case "82": self = .equestrianSports
        case "83": self = .virtualSports
        case "84": self = .sepakTakraw
        case "85": self = .archery
        case "89": self = .pesapallo
        case "93": self = .fantasyDuels
        case "96": self = .eSports
        case "102": self = .bowling
        case "113": self = .virtualESports
        case "140": self = .footballSimulated
        case "141": self = .tennisSimulated
        case "146": self = .boatRacing
        case "147": self = .sumo
        case "151": self = .modernPentathlon
        case "152": self = .shooting
        case "153": self = .skateboarding
        case "154": self = .sportClimbing
        case "155": self = .kabaddi
        default: self = .unknown
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
