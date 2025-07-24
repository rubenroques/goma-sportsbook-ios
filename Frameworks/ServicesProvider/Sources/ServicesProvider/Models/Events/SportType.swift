//
//  SportType.swift
//  
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

public struct SportType: Codable, Equatable, Hashable {

    public var name: String
    public var numericId: String?
    public var alphaId: String?
    public var iconId: String?
    public var showEventCategory: Bool
    public var numberEvents: Int
    public var numberOutrightEvents: Int
    public var numberOutrightMarkets: Int
    public var numberLiveEvents: Int

    public init(name: String,
                numericId: String?,
                alphaId: String?,
                iconId: String?,
                showEventCategory: Bool,
                numberEvents: Int,
                numberOutrightEvents: Int,
                numberOutrightMarkets: Int,
                numberLiveEvents: Int) {
        self.name = name
        self.numericId = numericId
        self.alphaId = alphaId
        self.iconId = iconId
        self.showEventCategory = showEventCategory
        self.numberEvents = numberEvents
        self.numberOutrightEvents = numberOutrightEvents
        self.numberOutrightMarkets = numberOutrightMarkets
        self.numberLiveEvents = numberLiveEvents
    }
    
    public init(name: String) {
        self.name = name
        self.numericId = nil
        self.alphaId = nil
        self.iconId = nil
        self.showEventCategory = false
        self.numberEvents = 0
        self.numberOutrightEvents = 0
        self.numberOutrightMarkets = 0
        self.numberLiveEvents = 0
    }
    
    public static var defaultFootball: SportType {
        return .init(
            name: "Football",
            numericId: "1",
            alphaId: "FBL",
            iconId: "1",
            showEventCategory: false,
            numberEvents: 0,
            numberOutrightEvents: 0,
            numberOutrightMarkets: 0,
            numberLiveEvents: 0)
    }
}

// TODO: Este devia ser o unico modelo publico

enum SportTypeInfo: CaseIterable {

    case football
    case golf
    case tennis
    case americanFootball
    case iceHockey
    case handball
    case basketball
    case baseball
    case fieldHockey
    case softball
    case weightlifting
    case athletics
    case badminton
    case gymnastics
    case rowing
    case sailing
    case swimming
    case triathlon
    case volleyball
    case wintersports
    case waterPolo
    case motorRacing
    case horseRacing
    case fighting
    case cricket
    case greyhounds
    case rugbyLeague
    case specials
    case snooker
    case cycling
    case afl
    case rugbyUnion
    case bandy
    case floorball
    case darts
    case hurling
    case gaelicFootball
    case pool
    case futsal
    case surfing
    case poker
    case chess
    case alpineSkiing
    case crossCountrySkiing
    case freestyleSkiing
    case nordicCombined
    case skiJumping
    case snowboard
    case biathlon
    case curling
    case bobsleigh
    case lacrosse
    case tableTennis
    case beachVolleyball
    case canoeing
    case beachFootball
    case bowls
    case luge
    case figureSkating
    case skeleton
    case speedSkating
    case shortTrackSpeedSkating
    case netball
    case harnessRacing
    case fencing
    case squash
    case horseball
    case judo
    case petanque
    case basquePelota
    case diving
    case equestrianSports
    case virtualSports
    case sepakTakraw
    case archery
    case virtualFootball
    case virtualHorseRacing
    case virtualGreyhounds
    case pesapallo
    case eSportsOld
    case virtualTennis
    case virtualBasketball
    case fantasyDuels
    case eSports
    case csGo
    case dota2
    case leagueOfLegends
    case priceBoost
    case bowling
    case hearthstone
    case heroesOfTheStorm
    case kingOfGlory
    case nba2K
    case overwatch
    case rocketLeague
    case starcraftBroodwar
    case starcraft2
    case newSignUp1StBetBoost
    case rainbowSix
    case virtualESports
    case artifact
    case accas
    case warcraft3
    case smash
    case fifa
    case callOfDuty
    case smite
    case magicTheGathering
    case fortnite
    case pubg
    case financials
    case eTennis
    case eIceHockey
    case eFighting
    case eMotorSports
    case eVolleyball
    case valorant
    case virtualMortalKombat
    case virtualCsGo
    case virtualRocketLeague
    case virtualStreetFighter
    case virtualNba2K
    case footballSimulated
    case tennisSimulated
    case virtualCallOfDuty
    case virtualUfc
    case virtualPubg
    case virtualInjustice
    case boatRacing
    case sumo
    case competitiveEating
    case droneRacing
    case japaneseHandicap
    case modernPentathlon
    case shooting
    case skateboarding
    case sportClimbing
    case kabaddi
    case virtualBasketballSuperHoops
    case virtualBasketballFinalHoops
    case virtualIceHockey
    case virtualDashingDerby
    case virtualHarnessRacing
    case virtualHorsesEqual
    case virtualSteepleChaseRacing
    case virtualPlatinumHounds
    case virtualMotorRacing
    case virtualTableTennis
    case virtualBadminton
    case virtualArchery
    case virtualCycling
    case virtualSpeedSkating
    case virtualHockeyShots
    //
    case gaelicHurling
    case gaelicSports
    case rinkHockey
    case dogRacing
    case basketball3X3
    case worldOfTanks
    case olympics
    case synchronizedSwimming
    case trotting
    //
    case canoeSlalom
    case cyclingBmxFreestyle
    case cyclingBmxRacing
    case mountainBike
    case trackCycling
    case trampolineGymnastics
    case rhythmicGymnastics
    case marathonSwimming
    //
    case boxing
    case taekwondo
    case karate
    case wrestling
    case mma
    //
    case stockCarRacing
    case touringCarRacing
    case rally
    case speedway
    case formulaE
    case indyRacing
    case motorcycleRacing
    case formula1
    //
    case numbers
    case emptyBets
    case lotteries

    //
    case esportscounterstrikego
    case mmaFighting
    case counterStrike
    case aussieRules

    public init?(id: String) {
        switch id {
        // Initial list from EveryMatrix
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
        case "86": self = .virtualFootball
        case "87": self = .virtualHorseRacing
        case "88": self = .virtualGreyhounds
        case "89": self = .pesapallo
        case "90": self = .eSportsOld
        case "91": self = .virtualTennis
        case "92": self = .virtualBasketball
        case "93": self = .fantasyDuels
        case "96": self = .eSports
        case "98": self = .csGo
        case "99": self = .dota2
        case "100": self = .leagueOfLegends
        case "101": self = .priceBoost
        case "102": self = .bowling
        case "103": self = .hearthstone
        case "104": self = .heroesOfTheStorm
        case "105": self = .kingOfGlory
        case "106": self = .nba2K
        case "107": self = .overwatch
        case "108": self = .rocketLeague
        case "109": self = .starcraftBroodwar
        case "110": self = .starcraft2
        case "111": self = .newSignUp1StBetBoost
        case "112": self = .rainbowSix
        case "113": self = .virtualESports
        case "115": self = .artifact
        case "116": self = .accas
        case "117": self = .warcraft3
        case "120": self = .smash
        case "121": self = .fifa
        case "122": self = .callOfDuty
        case "123": self = .smite
        case "124": self = .magicTheGathering
        case "125": self = .fortnite
        case "126": self = .pubg
        case "127": self = .financials
        case "128": self = .eTennis
        case "129": self = .eIceHockey
        case "130": self = .eFighting
        case "131": self = .eMotorSports
        case "133": self = .eVolleyball
        case "134": self = .valorant
        case "135": self = .virtualMortalKombat
        case "136": self = .virtualCsGo
        case "137": self = .virtualRocketLeague
        case "138": self = .virtualStreetFighter
        case "139": self = .virtualNba2K
        case "140": self = .footballSimulated
        case "141": self = .tennisSimulated
        case "142": self = .virtualCallOfDuty
        case "143": self = .virtualUfc
        case "144": self = .virtualPubg
        case "145": self = .virtualInjustice
        case "146": self = .boatRacing
        case "147": self = .sumo
        case "148": self = .competitiveEating
        case "149": self = .droneRacing
        case "150": self = .japaneseHandicap
        case "151": self = .modernPentathlon
        case "152": self = .shooting
        case "153": self = .skateboarding
        case "154": self = .sportClimbing
        case "155": self = .kabaddi
        case "156": self = .virtualBasketballSuperHoops
        case "157": self = .virtualBasketballFinalHoops
        case "158": self = .virtualIceHockey
        case "159": self = .virtualDashingDerby
        case "160": self = .virtualHarnessRacing
        case "161": self = .virtualHorsesEqual
        case "162": self = .virtualSteepleChaseRacing
        case "163": self = .virtualPlatinumHounds
        case "164": self = .virtualMotorRacing
        case "165": self = .virtualTableTennis
        case "166": self = .virtualBadminton
        case "167": self = .virtualArchery
        case "168": self = .virtualCycling
        case "169": self = .virtualSpeedSkating
        case "170": self = .virtualHockeyShots
        //
        // Aditional sports from SportRadar
        case "900": self = .gaelicHurling
        case "901": self = .gaelicSports
        case "902": self = .rinkHockey
        case "903": self = .dogRacing
        case "904": self = .basketball3X3
        case "905": self = .worldOfTanks
        case "906": self = .olympics
        case "907": self = .synchronizedSwimming
        case "908": self = .trotting
        case "909": self = .canoeSlalom
        case "910": self = .cyclingBmxFreestyle
        case "911": self = .cyclingBmxRacing
        case "912": self = .mountainBike
        case "913": self = .trackCycling
        case "914": self = .trampolineGymnastics
        case "915": self = .rhythmicGymnastics
        case "916": self = .marathonSwimming
        case "917": self = .boxing
        case "918": self = .taekwondo
        case "919": self = .karate
        case "920": self = .wrestling
        case "921": self = .mma
        case "922": self = .stockCarRacing
        case "923": self = .touringCarRacing
        case "924": self = .rally
        case "925": self = .speedway
        case "926": self = .formulaE
        case "927": self = .indyRacing
        case "928": self = .motorcycleRacing
        case "929": self = .formula1
        case "930": self = .numbers
        case "931": self = .emptyBets
        case "932": self = .lotteries
        case "982": self = .counterStrike
        case "983": self = .aussieRules
        default: return nil
        }
    }

    public init?(alphaCode: String) {
        switch alphaCode {
        // Initial list from EveryMatrix
        case "FBL": self = .football
        case "GLF": self = .golf
        case "TNS": self = .tennis
        case "UFB": self = .americanFootball
        case "HKY": self = .iceHockey
        case "HBL": self = .handball
        case "BKB": self = .basketball
        case "BSB": self = .baseball
        case "10": self = .fieldHockey
        case "11": self = .softball
        case "12": self = .weightlifting
        case "ATL": self = .athletics
        case "BAD": self = .badminton
        case "15": self = .gymnastics
        case "16": self = .rowing
        case "17": self = .sailing
        case "18": self = .swimming
        case "19": self = .triathlon
        case "VBL": self = .volleyball
        case "21": self = .wintersports
        case "WAT": self = .waterPolo
        case "23": self = .motorRacing
        case "HRR": self = .horseRacing
        case "25": self = .fighting
        case "CRK": self = .cricket
        case "DGR": self = .greyhounds
        case "RBL": self = .rugbyLeague
        case "34": self = .specials
        case "SNK": self = .snooker
        case "CYC": self = .cycling
        case "38": self = .afl
        case "RBU": self = .rugbyUnion
        case "40": self = .bandy
        case "FLR": self = .floorball
        case "DAR": self = .darts
        case "46": self = .hurling
        case "GAF": self = .gaelicFootball
        case "48": self = .pool
        case "FSL": self = .futsal
        case "50": self = .surfing
        case "51": self = .poker
        case "52": self = .chess
        case "WAS": self = .alpineSkiing
        case "54": self = .crossCountrySkiing
        case "55": self = .freestyleSkiing
        case "56": self = .nordicCombined
        case "WSJ": self = .skiJumping
        case "58": self = .snowboard
        case "WBI": self = .biathlon
        case "60": self = .curling
        case "61": self = .bobsleigh
        case "LAC": self = .lacrosse
        case "TBT": self = .tableTennis
        case "BVB": self = .beachVolleyball
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
        case "86": self = .virtualFootball
        case "87": self = .virtualHorseRacing
        case "88": self = .virtualGreyhounds
        case "89": self = .pesapallo
        case "90": self = .eSportsOld
        case "91": self = .virtualTennis
        case "92": self = .virtualBasketball
        case "93": self = .fantasyDuels
        case "96": self = .eSports
        case "98": self = .csGo
        case "99": self = .dota2
        case "LOL": self = .leagueOfLegends
        case "101": self = .priceBoost
        case "102": self = .bowling
        case "103": self = .hearthstone
        case "104": self = .heroesOfTheStorm
        case "105": self = .kingOfGlory
        case "106": self = .nba2K
        case "107": self = .overwatch
        case "108": self = .rocketLeague
        case "109": self = .starcraftBroodwar
        case "110": self = .starcraft2
        case "111": self = .newSignUp1StBetBoost
        case "112": self = .rainbowSix
        case "113": self = .virtualESports
        case "115": self = .artifact
        case "116": self = .accas
        case "117": self = .warcraft3
        case "120": self = .smash
        case "121": self = .fifa
        case "122": self = .callOfDuty
        case "123": self = .smite
        case "124": self = .magicTheGathering
        case "125": self = .fortnite
        case "126": self = .pubg
        case "127": self = .financials
        case "128": self = .eTennis
        case "129": self = .eIceHockey
        case "130": self = .eFighting
        case "131": self = .eMotorSports
        case "133": self = .eVolleyball
        case "134": self = .valorant
        case "135": self = .virtualMortalKombat
        case "136": self = .virtualCsGo
        case "137": self = .virtualRocketLeague
        case "138": self = .virtualStreetFighter
        case "139": self = .virtualNba2K
        case "140": self = .footballSimulated
        case "141": self = .tennisSimulated
        case "142": self = .virtualCallOfDuty
        case "143": self = .virtualUfc
        case "144": self = .virtualPubg
        case "145": self = .virtualInjustice
        case "146": self = .boatRacing
        case "147": self = .sumo
        case "148": self = .competitiveEating
        case "149": self = .droneRacing
        case "150": self = .japaneseHandicap
        case "151": self = .modernPentathlon
        case "152": self = .shooting
        case "153": self = .skateboarding
        case "154": self = .sportClimbing
        case "155": self = .kabaddi
        case "156": self = .virtualBasketballSuperHoops
        case "157": self = .virtualBasketballFinalHoops
        case "158": self = .virtualIceHockey
        case "159": self = .virtualDashingDerby
        case "160": self = .virtualHarnessRacing
        case "161": self = .virtualHorsesEqual
        case "162": self = .virtualSteepleChaseRacing
        case "163": self = .virtualPlatinumHounds
        case "164": self = .virtualMotorRacing
        case "165": self = .virtualTableTennis
        case "166": self = .virtualBadminton
        case "167": self = .virtualArchery
        case "168": self = .virtualCycling
        case "169": self = .virtualSpeedSkating
        case "170": self = .virtualHockeyShots
        //
        // Aditional sports from SportRadar
        case "GAH": self = .gaelicHurling
        case "901": self = .gaelicSports
        case "902": self = .rinkHockey
        case "903": self = .dogRacing
        case "904": self = .basketball3X3
        case "905": self = .worldOfTanks
        case "906": self = .olympics
        case "907": self = .synchronizedSwimming
        case "908": self = .trotting
        case "909": self = .canoeSlalom
        case "910": self = .cyclingBmxFreestyle
        case "911": self = .cyclingBmxRacing
        case "912": self = .mountainBike
        case "913": self = .trackCycling
        case "914": self = .trampolineGymnastics
        case "915": self = .rhythmicGymnastics
        case "916": self = .marathonSwimming
        case "BOX": self = .boxing
        case "918": self = .taekwondo
        case "919": self = .karate
        case "920": self = .wrestling
        case "MMA": self = .mma
        case "SCR": self = .stockCarRacing
        case "923": self = .touringCarRacing
        case "RLL": self = .rally
        case "SPW": self = .speedway
        case "FOE": self = .formulaE
        case "IRC": self = .indyRacing
        case "MCR": self = .motorcycleRacing
        case "FO1": self = .formula1
        case "930": self = .numbers
        case "931": self = .emptyBets
        case "932": self = .lotteries
        case "AFL": self = .aussieRules
        case "CST": self = .counterStrike
        default: return nil
        }
    }
    
    public var id: String {
        switch self {
        case .football: return "1"
        case .golf: return "2"
        case .tennis: return "3"
        case .americanFootball: return "5"
        case .iceHockey: return "6"
        case .handball: return "7"
        case .basketball: return "8"
        case .baseball: return "9"
        case .fieldHockey: return "10"
        case .softball: return "11"
        case .weightlifting: return "12"
        case .athletics: return "13"
        case .badminton: return "14"
        case .gymnastics: return "15"
        case .rowing: return "16"
        case .sailing: return "17"
        case .swimming: return "18"
        case .triathlon: return "19"
        case .volleyball: return "20"
        case .wintersports: return "21"
        case .waterPolo: return "22"
        case .motorRacing: return "23"
        case .horseRacing: return "24"
        case .fighting: return "25"
        case .cricket: return "26"
        case .greyhounds: return "27"
        case .rugbyLeague: return "28"
        case .specials: return "34"
        case .snooker: return "36"
        case .cycling: return "37"
        case .afl: return "38"
        case .rugbyUnion: return "39"
        case .bandy: return "40"
        case .floorball: return "41"
        case .darts: return "45"
        case .hurling: return "46"
        case .gaelicFootball: return "47"
        case .pool: return "48"
        case .futsal: return "49"
        case .surfing: return "50"
        case .poker: return "51"
        case .chess: return "52"
        case .alpineSkiing: return "53"
        case .crossCountrySkiing: return "54"
        case .freestyleSkiing: return "55"
        case .nordicCombined: return "56"
        case .skiJumping: return "57"
        case .snowboard: return "58"
        case .biathlon: return "59"
        case .curling: return "60"
        case .bobsleigh: return "61"
        case .lacrosse: return "62"
        case .tableTennis: return "63"
        case .beachVolleyball: return "64"
        case .canoeing: return "65"
        case .beachFootball: return "66"
        case .bowls: return "67"
        case .luge: return "68"
        case .figureSkating: return "69"
        case .skeleton: return "70"
        case .speedSkating: return "71"
        case .shortTrackSpeedSkating: return "72"
        case .netball: return "73"
        case .harnessRacing: return "74"
        case .fencing: return "75"
        case .squash: return "76"
        case .horseball: return "77"
        case .judo: return "78"
        case .petanque: return "79"
        case .basquePelota: return "80"
        case .diving: return "81"
        case .equestrianSports: return "82"
        case .virtualSports: return "83"
        case .sepakTakraw: return "84"
        case .archery: return "85"
        case .virtualFootball: return "86"
        case .virtualHorseRacing: return "87"
        case .virtualGreyhounds: return "88"
        case .pesapallo: return "89"
        case .eSportsOld: return "90"
        case .virtualTennis: return "91"
        case .virtualBasketball: return "92"
        case .fantasyDuels: return "93"
        case .eSports: return "96"
        case .csGo: return "98"
        case .dota2: return "99"
        case .leagueOfLegends: return "100"
        case .priceBoost: return "101"
        case .bowling: return "102"
        case .hearthstone: return "103"
        case .heroesOfTheStorm: return "104"
        case .kingOfGlory: return "105"
        case .nba2K: return "106"
        case .overwatch: return "107"
        case .rocketLeague: return "108"
        case .starcraftBroodwar: return "109"
        case .starcraft2: return "110"
        case .newSignUp1StBetBoost: return "111"
        case .rainbowSix: return "112"
        case .virtualESports: return "113"
        case .artifact: return "115"
        case .accas: return "116"
        case .warcraft3: return "117"
        case .smash: return "120"
        case .fifa: return "121"
        case .callOfDuty: return "122"
        case .smite: return "123"
        case .magicTheGathering: return "124"
        case .fortnite: return "125"
        case .pubg: return "126"
        case .financials: return "127"
        case .eTennis: return "128"
        case .eIceHockey: return "129"
        case .eFighting: return "130"
        case .eMotorSports: return "131"
        case .eVolleyball: return "133"
        case .valorant: return "134"
        case .virtualMortalKombat: return "135"
        case .virtualCsGo: return "136"
        case .virtualRocketLeague: return "137"
        case .virtualStreetFighter: return "138"
        case .virtualNba2K: return "139"
        case .footballSimulated: return "140"
        case .tennisSimulated: return "141"
        case .virtualCallOfDuty: return "142"
        case .virtualUfc: return "143"
        case .virtualPubg: return "144"
        case .virtualInjustice: return "145"
        case .boatRacing: return "146"
        case .sumo: return "147"
        case .competitiveEating: return "148"
        case .droneRacing: return "149"
        case .japaneseHandicap: return "150"
        case .modernPentathlon: return "151"
        case .shooting: return "152"
        case .skateboarding: return "153"
        case .sportClimbing: return "154"
        case .kabaddi: return "155"
        case .virtualBasketballSuperHoops: return "156"
        case .virtualBasketballFinalHoops: return "157"
        case .virtualIceHockey: return "158"
        case .virtualDashingDerby: return "159"
        case .virtualHarnessRacing: return "160"
        case .virtualHorsesEqual: return "161"
        case .virtualSteepleChaseRacing: return "162"
        case .virtualPlatinumHounds: return "163"
        case .virtualMotorRacing: return "164"
        case .virtualTableTennis: return "165"
        case .virtualBadminton: return "166"
        case .virtualArchery: return "167"
        case .virtualCycling: return "168"
        case .virtualSpeedSkating: return "169"
        case .virtualHockeyShots: return "170"
            //
        case .gaelicHurling: return "900"
        case .gaelicSports: return "901"
        case .rinkHockey: return "902"
        case .dogRacing: return "903"
        case .basketball3X3: return "904"
        case .worldOfTanks: return "905"
        case .olympics: return "906"
        case .synchronizedSwimming: return "907"
        case .trotting: return "908"
        case .canoeSlalom: return "909"
        case .cyclingBmxFreestyle: return "910"
        case .cyclingBmxRacing: return "911"
        case .mountainBike: return "912"
        case .trackCycling: return "913"
        case .trampolineGymnastics: return "914"
        case .rhythmicGymnastics: return "915"
        case .marathonSwimming: return "916"
        case .boxing: return "917"
        case .taekwondo: return "918"
        case .karate: return "919"
        case .wrestling: return "920"
        case .mma: return "921"
        case .stockCarRacing: return "922"
        case .touringCarRacing: return "923"
        case .rally: return "924"
        case .speedway: return "925"
        case .formulaE: return "926"
        case .indyRacing: return "927"
        case .motorcycleRacing: return "928"
        case .formula1: return "929"
        case .numbers: return "930"
        case .emptyBets: return "931"
        case .lotteries: return "932"

        case .esportscounterstrikego: return "980"
        case .mmaFighting: return "981"
        case .counterStrike: return "982"
        case .aussieRules: return "983"
        }
    }
    
    public var name: String {
        switch self {
        case .football: return "Football"
        case .golf: return "Golf"
        case .tennis: return "Tennis"
        case .americanFootball: return "American Football"
        case .iceHockey: return "Ice Hockey"
        case .handball: return "Handball"
        case .basketball: return "Basketball"
        case .baseball: return "Baseball"
        case .fieldHockey: return "Field Hockey"
        case .softball: return "Softball"
        case .weightlifting: return "Weightlifting"
        case .athletics: return "Athletics"
        case .badminton: return "Badminton"
        case .gymnastics: return "Gymnastics"
        case .rowing: return "Rowing"
        case .sailing: return "Sailing"
        case .swimming: return "Swimming"
        case .triathlon: return "Triathlon"
        case .volleyball: return "Volleyball"
        case .wintersports: return "Wintersports"
        case .waterPolo: return "Water Polo"
        case .motorRacing: return "Motor Racing"
        case .horseRacing: return "Horse Racing"
        case .fighting: return "Fighting"
        case .cricket: return "Cricket"
        case .greyhounds: return "Greyhounds"
        case .rugbyLeague: return "Rugby League"
        case .specials: return "Specials"
        case .snooker: return "Snooker"
        case .cycling: return "Cycling"
        case .afl: return "AFL"
        case .rugbyUnion: return "Rugby Union"
        case .bandy: return "Bandy"
        case .floorball: return "Floorball"
        case .darts: return "Darts"
        case .hurling: return "Hurling"
        case .gaelicFootball: return "Gaelic Football"
        case .pool: return "Pool"
        case .futsal: return "Futsal"
        case .surfing: return "Surfing"
        case .poker: return "Poker"
        case .chess: return "Chess"
        case .alpineSkiing: return "Alpine Skiing"
        case .crossCountrySkiing: return "Cross Country Skiing"
        case .freestyleSkiing: return "Freestyle Skiing"
        case .nordicCombined: return "Nordic Combined"
        case .skiJumping: return "Ski Jumping"
        case .snowboard: return "Snowboard"
        case .biathlon: return "Biathlon"
        case .curling: return "Curling"
        case .bobsleigh: return "Bobsleigh"
        case .lacrosse: return "Lacrosse"
        case .tableTennis: return "Table Tennis"
        case .beachVolleyball: return "Beach Volleyball"
        case .canoeing: return "Canoeing"
        case .beachFootball: return "Beach Football"
        case .bowls: return "Bowls"
        case .luge: return "Luge"
        case .figureSkating: return "Figure Skating"
        case .skeleton: return "Skeleton"
        case .speedSkating: return "Speed Skating"
        case .shortTrackSpeedSkating: return "Short Track Speed Skating"
        case .netball: return "Netball"
        case .harnessRacing: return "Harness Racing"
        case .fencing: return "Fencing"
        case .squash: return "Squash"
        case .horseball: return "Horseball"
        case .judo: return "Judo"
        case .petanque: return "Petanque"
        case .basquePelota: return "Basque Pelota"
        case .diving: return "Diving"
        case .equestrianSports: return "Equestrian Sports"
        case .virtualSports: return "Virtual Sports"
        case .sepakTakraw: return "Sepak takraw"
        case .archery: return "Archery"
        case .virtualFootball: return "Virtual Football"
        case .virtualHorseRacing: return "Virtual Horse Racing"
        case .virtualGreyhounds: return "Virtual Greyhounds"
        case .pesapallo: return "Pesapallo"
        case .eSportsOld: return "E-Sports (old)"
        case .virtualTennis: return "Virtual Tennis"
        case .virtualBasketball: return "Virtual Basketball"
        case .fantasyDuels: return "Fantasy Duels"
        case .eSports: return "eSports"
        case .csGo: return "CS:GO"
        case .dota2: return "DOTA 2"
        case .leagueOfLegends: return "League of Legends"
        case .priceBoost: return "Price boost"
        case .bowling: return "Bowling"
        case .hearthstone: return "Hearthstone"
        case .heroesOfTheStorm: return "Heroes Of The Storm"
        case .kingOfGlory: return "King Of Glory"
        case .nba2K: return "NBA2k"
        case .overwatch: return "Overwatch"
        case .rocketLeague: return "Rocket League"
        case .starcraftBroodwar: return "Starcraft Broodwar"
        case .starcraft2: return "Starcraft 2"
        case .newSignUp1StBetBoost: return "New Sign-up 1st Bet Boost"
        case .rainbowSix: return "Rainbow Six"
        case .virtualESports: return "Virtual eSports"
        case .artifact: return "Artifact"
        case .accas: return "Accas"
        case .warcraft3: return "Warcraft III"
        case .smash: return "Smash"
        case .fifa: return "FIFA"
        case .callOfDuty: return "Call of Duty"
        case .smite: return "Smite"
        case .magicTheGathering: return "Magic The Gathering"
        case .fortnite: return "Fortnite"
        case .pubg: return "PUBG"
        case .financials: return "Financials"
        case .eTennis: return "e-Tennis"
        case .eIceHockey: return "e-Ice Hockey"
        case .eFighting: return "e-Fighting"
        case .eMotorSports: return "e-Motor Sports"
        case .eVolleyball: return "e-Volleyball"
        case .valorant: return "Valorant"
        case .virtualMortalKombat: return "Virtual Mortal Kombat"
        case .virtualCsGo: return "Virtual CS:GO"
        case .virtualRocketLeague: return "Virtual Rocket League"
        case .virtualStreetFighter: return "Virtual Street Fighter"
        case .virtualNba2K: return "Virtual NBA2k"
        case .footballSimulated: return "Football – Simulated"
        case .tennisSimulated: return "Tennis – Simulated"
        case .virtualCallOfDuty: return "Virtual Call of Duty"
        case .virtualUfc: return "Virtual UFC"
        case .virtualPubg: return "Virtual PUBG"
        case .virtualInjustice: return "Virtual Injustice"
        case .boatRacing: return "Boat Racing"
        case .sumo: return "Sumo"
        case .competitiveEating: return "Competitive Eating"
        case .droneRacing: return "Drone Racing"
        case .japaneseHandicap: return "Japanese Handicap"
        case .modernPentathlon: return "Modern Pentathlon"
        case .shooting: return "Shooting"
        case .skateboarding: return "Skateboarding"
        case .sportClimbing: return "Sport Climbing"
        case .kabaddi: return "Kabaddi"
        case .virtualBasketballSuperHoops: return "Virtual Basketball - Super Hoops"
        case .virtualBasketballFinalHoops: return "Virtual Basketball - Final Hoops"
        case .virtualIceHockey: return "Virtual Ice Hockey"
        case .virtualDashingDerby: return "Virtual Dashing Derby"
        case .virtualHarnessRacing: return "Virtual Harness Racing"
        case .virtualHorsesEqual: return "Virtual Horses Equal"
        case .virtualSteepleChaseRacing: return "Virtual Steeple Chase Racing"
        case .virtualPlatinumHounds: return "Virtual Platinum Hounds"
        case .virtualMotorRacing: return "Virtual Motor Racing"
        case .virtualTableTennis: return "Virtual Table Tennis"
        case .virtualBadminton: return "Virtual Badminton"
        case .virtualArchery: return "Virtual Archery"
        case .virtualCycling: return "Virtual Cycling"
        case .virtualSpeedSkating: return "Virtual Speed Skating"
        case .virtualHockeyShots: return "Virtual Hockey Shots"
        //
        case .gaelicHurling: return "Gaelic Hurling"
        case .gaelicSports: return "Gaelic Sports"
        case .rinkHockey: return "Rink Hockey"
        case .dogRacing: return "Dog Racing"
        case .basketball3X3: return "Basketball 3X3"
        case .worldOfTanks: return "World Of Tanks"
        case .olympics: return "Olympics"
        case .synchronizedSwimming: return "SynchronizedSwimming"
        case .trotting: return "Trotting"
        case .canoeSlalom: return "CanoeSlalom"
        case .cyclingBmxFreestyle: return "Cycling BMX Freestyle"
        case .cyclingBmxRacing: return "Cycling BMX Racing"
        case .mountainBike: return "Mountain Bike"
        case .trackCycling: return "Track Cycling"
        case .trampolineGymnastics: return "Trampoline Gymnastics"
        case .rhythmicGymnastics: return "Rhythmic Gymnastics"
        case .marathonSwimming: return "Marathon Swimming"
        case .boxing: return "Boxing"
        case .taekwondo: return "Taekwondo"
        case .karate: return "Karate"
        case .wrestling: return "Wrestling"
        case .mma: return "MMA"
        case .stockCarRacing: return "Stock Car Racing"
        case .touringCarRacing: return "Touring Car Racing"
        case .rally: return "Rally"
        case .speedway: return "Speedway"
        case .formulaE: return "Formula E"
        case .indyRacing: return "Indy Racing"
        case .motorcycleRacing: return "Motorcycle Racing"
        case .formula1: return "Formula 1"
        case .numbers: return "Numbers"
        case .emptyBets: return "Empty Bets"
        case .lotteries: return "Lotteries"
        case .esportscounterstrikego: return "eSports - Counter Strike GO"
        case .mmaFighting: return "MMA Fighting"
        case .counterStrike: return "Counter-Strike"
        case .aussieRules: return "Aussie Rules"
        }
    }
}
