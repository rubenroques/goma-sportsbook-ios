//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {
    
    struct SportTypeDetails: Codable {
        var sportType: SportType
        var eventsCount: Int
        var sportName: String
        
        enum CodingKeys: String, CodingKey {
            case sportType = "idfosporttype"
            case eventsCount = "numEvents"
            case sportName = "sporttypename"
        }
        
        init(sportType: SportType, eventsCount: Int, sportName: String) {
            self.sportType = sportType
            self.eventsCount = eventsCount
            self.sportName = sportName
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let sportTypeIdString = try container.decode(String.self, forKey: .sportType)
            let sportTypeName = try container.decode(String.self, forKey: .sportName)
            let eventsCount = try container.decode(Int.self, forKey: .eventsCount)
            self.sportType = try SportType(name: sportTypeName,
                                           numericId: nil,
                                           alphaId: sportTypeIdString,
                                           iconId: nil,
                                           numberEvents: "\(eventsCount)",
                                           numberOutrightEvents: nil,
                                           numberOutrightMarkets: nil)
            self.eventsCount = try container.decode(Int.self, forKey: .eventsCount)
            self.sportName = try container.decode(String.self, forKey: .sportName)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.sportType, forKey: .sportType)
            try container.encode(self.eventsCount, forKey: .eventsCount)
            try container.encode(self.sportName, forKey: .sportName)

        }
        
    }
    
    enum SportTypeInfo: Codable {
        case aussieRules
        case badminton
        case bandy
        case basketball
        case bowls
        case boxing
        case baseball
        case beachFootball
        case beachVolley
        case cricket
        case counterStrike
        case curling
        case cycling
        case darts
        case dota2
        case football
        case fieldHockey
        case floorball
        case futsal
        case gaelicSports
        case golf
        case handball
        case iceHockey
        case leagueOfLegends
        case mma
        case motorsport
        case eSportNba2K
        case pesapallo
        case rugbyLeague
        case rugbyUnion
        case rinkHockey
        case snooker
        case squash
        case starCraft
        case tableTennis
        case tennis
        case americanFootball
        case volleyball
        case alpineSkiing
        case waterpolo
        case biathlon
        case bobsleigh
        case crossCountry
        case luge
        case nordicCombined
        case skiJumping
        case snowboard
        case speedSkating
        case archery
        case athletics
        case canoe
        case diving
        case dogRacing
        case equestrian
        case callOfDuty
        case electronicFootball
        case heartstone
        case heroesOfTheStorm
        case overwatch
        case smite
        case streetFighter
        case worldOfTanks
        case worldOfWarcraft
        case fencing
        case freestyle
        case gymnastic
        case judo
        case lacrosse
        case modernPentathlon
        case numbers
        case olympics
        case pool
        case rowing
        case sailing
        case shooting
        case shortTrackSpeedSkating
        case skeleton
        case specials
        case swimming
        case synchronizedSwimming
        case taekwondo
        case triathlon
        case trotting
        case weightlifting
        case winterSports
        case wrestling
        case formula1
        case basketball3X3
        case formulaE
        case indyRacing
        case motorcycleRacing
        case playerUnknownsBattlegrounds
        case stockCarRacing
        case speedway
        case figureSkating
        case softball
        case canoeSlalom
        case cyclingBmxFreestyle
        case cyclingBmxRacing
        case mountainBike
        case trackCycling
        case sportClimbing
        case trampolineGymnastics
        case rhythmicGymnastics
        case karate
        case marathonSwimming
        case skateboarding
        case surfing
        case touringCarRacing
        case rally
        case gaelicFootball
        case gaelicHurling
        case electronicIceHockey
        case greyhoundRacing
        case horseRacing
        case emptyBets
        case lotteries
        case virtualHorseRacing
        case virtualGreyhoundRacing
        case virtualFootball
        case virtualBasketball
        case virtualTennis
        
        enum CodingKeys: String, CodingKey {
            case sportTypeIdentifier = "idfosporttype"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let sportIdentifier = try container.decode(String.self, forKey: .sportTypeIdentifier)
            self = try Self.init(id: sportIdentifier)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .sportTypeIdentifier)
        }
        
        init(id: String) throws {
            switch id {
            case "AFL": self = .aussieRules
            case "BAD": self = .badminton
            case "BAN": self = .bandy
            case "BKB": self = .basketball
            case "BOW": self = .bowls
            case "BOX": self = .boxing
            case "BSB": self = .baseball
            case "BSC": self = .beachFootball
            case "BVB": self = .beachVolley
            case "CRK": self = .cricket
            case "CST": self = .counterStrike
            case "CUR": self = .curling
            case "CYC": self = .cycling
            case "DAR": self = .darts
            case "DOT": self = .dota2
            case "FBL": self = .football
            case "FKY": self = .fieldHockey
            case "FLR": self = .floorball
            case "FSL": self = .futsal
            case "GAA": self = .gaelicSports
            case "GLF": self = .golf
            case "HBL": self = .handball
            case "HKY": self = .iceHockey
            case "LOL": self = .leagueOfLegends
            case "MMA": self = .mma
            case "MSP": self = .motorsport
            case "N2K": self = .eSportNba2K
            case "PES": self = .pesapallo
            case "RBL": self = .rugbyLeague
            case "RBU": self = .rugbyUnion
            case "RHK": self = .rinkHockey
            case "SNK": self = .snooker
            case "SQU": self = .squash
            case "STC": self = .starCraft
            case "TBT": self = .tableTennis
            case "TNS": self = .tennis
            case "UFB": self = .americanFootball
            case "VBL": self = .volleyball
            case "WAS": self = .alpineSkiing
            case "WAT": self = .waterpolo
            case "WBI": self = .biathlon
            case "WBO": self = .bobsleigh
            case "WCC": self = .crossCountry
            case "WLU": self = .luge
            case "WNC": self = .nordicCombined
            case "WSJ": self = .skiJumping
            case "WSN": self = .snowboard
            case "WSS": self = .speedSkating
            case "ARC": self = .archery
            case "ATL": self = .athletics
            case "CAN": self = .canoe
            case "DIV": self = .diving
            case "DGR": self = .dogRacing
            case "EQU": self = .equestrian
            case "COD": self = .callOfDuty
            case "EFL": self = .electronicFootball
            case "HTS": self = .heartstone
            case "HOS": self = .heroesOfTheStorm
            case "OVW": self = .overwatch
            case "SMT": self = .smite
            case "STF": self = .streetFighter
            case "WOT": self = .worldOfTanks
            case "WOW": self = .worldOfWarcraft
            case "FEN": self = .fencing
            case "WFR": self = .freestyle
            case "GYM": self = .gymnastic
            case "HRR": self = .horseRacing
            case "JUD": self = .judo
            case "LAC": self = .lacrosse
            case "MPT": self = .modernPentathlon
            case "NUM": self = .numbers
            case "OLY": self = .olympics
            case "POL": self = .pool
            case "ROW": self = .rowing
            case "SNG": self = .sailing
            case "SHT": self = .shooting
            case "WST": self = .shortTrackSpeedSkating
            case "WSK": self = .skeleton
            case "SPE": self = .specials
            case "SWM": self = .swimming
            case "SSW": self = .synchronizedSwimming
            case "TAE": self = .taekwondo
            case "TRI": self = .triathlon
            case "TRT": self = .trotting
            case "WLT": self = .weightlifting
            case "WIN": self = .winterSports
            case "WRE": self = .wrestling
            case "FO1": self = .formula1
            case "BK3": self = .basketball3X3
            case "FOE": self = .formulaE
            case "IRC": self = .indyRacing
            case "MCR": self = .motorcycleRacing
            case "PUB": self = .playerUnknownsBattlegrounds
            case "SCR": self = .stockCarRacing
            case "SPW": self = .speedway
            case "WFS": self = .figureSkating
            case "SOF": self = .softball
            case "CSL": self = .canoeSlalom
            case "BMF": self = .cyclingBmxFreestyle
            case "BMR": self = .cyclingBmxRacing
            case "MBK": self = .mountainBike
            case "TCY": self = .trackCycling
            case "SCL": self = .sportClimbing
            case "TGY": self = .trampolineGymnastics
            case "RGY": self = .rhythmicGymnastics
            case "KAR": self = .karate
            case "MSW": self = .marathonSwimming
            case "SKB": self = .skateboarding
            case "SUR": self = .surfing
            case "TCR": self = .touringCarRacing
            case "RLL": self = .rally
            case "GAF": self = .gaelicFootball
            case "GAH": self = .gaelicHurling
            case "EIC": self = .electronicIceHockey
            case "EMPTY": self = .emptyBets
            case "DOGRACING": self = .greyhoundRacing
            case "HORSERACING": self = .horseRacing
            case "NUMBERS": self = .lotteries
            case "BRVIRHRR": self = .virtualHorseRacing
            case "BRVIRDGR": self = .virtualGreyhoundRacing
            case "BRVIRFBL": self = .virtualFootball
            case "BRVIRBKB": self = .virtualBasketball
            case "BRVIRTNS": self = .virtualTennis
            default:
                throw SportRadarError.unkownSportId
            }
        }
        
        var id: String {
            switch self {
            case .aussieRules: return "AFL"
            case .badminton: return "BAD"
            case .bandy: return "BAN"
            case .basketball: return "BKB"
            case .bowls: return "BOW"
            case .boxing: return "BOX"
            case .baseball: return "BSB"
            case .beachFootball: return "BSC"
            case .beachVolley: return "BVB"
            case .cricket: return "CRK"
            case .counterStrike: return "CST"
            case .curling: return "CUR"
            case .cycling: return "CYC"
            case .darts: return "DAR"
            case .dota2: return "DOT"
            case .football: return "FBL"
            case .fieldHockey: return "FKY"
            case .floorball: return "FLR"
            case .futsal: return "FSL"
            case .gaelicSports: return "GAA"
            case .golf: return "GLF"
            case .handball: return "HBL"
            case .iceHockey: return "HKY"
            case .leagueOfLegends: return "LOL"
            case .mma: return "MMA"
            case .motorsport: return "MSP"
            case .eSportNba2K: return "N2K"
            case .pesapallo: return "PES"
            case .rugbyLeague: return "RBL"
            case .rugbyUnion: return "RBU"
            case .rinkHockey: return "RHK"
            case .snooker: return "SNK"
            case .squash: return "SQU"
            case .starCraft: return "STC"
            case .tableTennis: return "TBT"
            case .tennis: return "TNS"
            case .americanFootball: return "UFB"
            case .volleyball: return "VBL"
            case .alpineSkiing: return "WAS"
            case .waterpolo: return "WAT"
            case .biathlon: return "WBI"
            case .bobsleigh: return "WBO"
            case .crossCountry: return "WCC"
            case .luge: return "WLU"
            case .nordicCombined: return "WNC"
            case .skiJumping: return "WSJ"
            case .snowboard: return "WSN"
            case .speedSkating: return "WSS"
            case .archery: return "ARC"
            case .athletics: return "ATL"
            case .canoe: return "CAN"
            case .diving: return "DIV"
            case .dogRacing: return "DGR"
            case .equestrian: return "EQU"
            case .callOfDuty: return "COD"
            case .electronicFootball: return "EFL"
            case .heartstone: return "HTS"
            case .heroesOfTheStorm: return "HOS"
            case .overwatch: return "OVW"
            case .smite: return "SMT"
            case .streetFighter: return "STF"
            case .worldOfTanks: return "WOT"
            case .worldOfWarcraft: return "WOW"
            case .fencing: return "FEN"
            case .freestyle: return "WFR"
            case .gymnastic: return "GYM"
            case .judo: return "JUD"
            case .lacrosse: return "LAC"
            case .modernPentathlon: return "MPT"
            case .numbers: return "NUM"
            case .olympics: return "OLY"
            case .pool: return "POL"
            case .rowing: return "ROW"
            case .sailing: return "SNG"
            case .shooting: return "SHT"
            case .shortTrackSpeedSkating: return "WST"
            case .skeleton: return "WSK"
            case .specials: return "SPE"
            case .swimming: return "SWM"
            case .synchronizedSwimming: return "SSW"
            case .taekwondo: return "TAE"
            case .triathlon: return "TRI"
            case .trotting: return "TRT"
            case .weightlifting: return "WLT"
            case .winterSports: return "WIN"
            case .wrestling: return "WRE"
            case .formula1: return "FO1"
            case .basketball3X3: return "BK3"
            case .formulaE: return "FOE"
            case .indyRacing: return "IRC"
            case .motorcycleRacing: return "MCR"
            case .playerUnknownsBattlegrounds: return "PUB"
            case .stockCarRacing: return "SCR"
            case .speedway: return "SPW"
            case .figureSkating: return "WFS"
            case .softball: return "SOF"
            case .canoeSlalom: return "CSL"
            case .cyclingBmxFreestyle: return "BMF"
            case .cyclingBmxRacing: return "BMR"
            case .mountainBike: return "MBK"
            case .trackCycling: return "TCY"
            case .sportClimbing: return "SCL"
            case .trampolineGymnastics: return "TGY"
            case .rhythmicGymnastics: return "RGY"
            case .karate: return "KAR"
            case .marathonSwimming: return "MSW"
            case .skateboarding: return "SKB"
            case .surfing: return "SUR"
            case .touringCarRacing: return "TCR"
            case .rally: return "RLL"
            case .gaelicFootball: return "GAF"
            case .gaelicHurling: return "GAH"
            case .electronicIceHockey: return "EIC"
            case .greyhoundRacing: return "DOGRACING"
            case .horseRacing: return "HRR"
            case .emptyBets: return "EMPTY"
            case .lotteries: return "NUMBERS"
            case .virtualHorseRacing: return "BRVIRHRR"
            case .virtualGreyhoundRacing: return "BRVIRDGR"
            case .virtualFootball: return "BRVIRFBL"
            case .virtualBasketball: return "BRVIRBKB"
            case .virtualTennis: return "BRVIRTNS"
            }
        }
        
        var name: String {
            switch self {
            case .aussieRules: return "Aussie Rules"
            case .badminton: return "Badminton"
            case .bandy: return "Bandy"
            case .basketball: return "Basketball"
            case .bowls: return "Bowls"
            case .boxing: return "Boxing"
            case .baseball: return "Baseball"
            case .beachFootball: return "Beach Football"
            case .beachVolley: return "Beach Volley"
            case .cricket: return "Cricket"
            case .counterStrike: return "Counter-Strike"
            case .curling: return "Curling"
            case .cycling: return "Cycling"
            case .darts: return "Darts"
            case .dota2: return "Dota 2"
            case .football: return "Football"
            case .fieldHockey: return "Field hockey"
            case .floorball: return "Floorball"
            case .futsal: return "Futsal"
            case .gaelicSports: return "Gaelic Sports"
            case .golf: return "Golf"
            case .handball: return "Handball"
            case .iceHockey: return "Ice Hockey"
            case .leagueOfLegends: return "League of Legends"
            case .mma: return "MMA"
            case .motorsport: return "Motorsport"
            case .eSportNba2K: return "ESport NBA2K"
            case .pesapallo: return "Pesapallo"
            case .rugbyLeague: return "Rugby League"
            case .rugbyUnion: return "Rugby Union"
            case .rinkHockey: return "Rink Hockey"
            case .snooker: return "Snooker"
            case .squash: return "Squash"
            case .starCraft: return "StarCraft"
            case .tableTennis: return "Table Tennis"
            case .tennis: return "Tennis"
            case .americanFootball: return "American Football"
            case .volleyball: return "Volleyball"
            case .alpineSkiing: return "Alpine Skiing"
            case .waterpolo: return "Waterpolo"
            case .biathlon: return "Biathlon"
            case .bobsleigh: return "Bobsleigh"
            case .crossCountry: return "Cross-Country"
            case .luge: return "Luge"
            case .nordicCombined: return "Nordic Combined"
            case .skiJumping: return "Ski Jumping"
            case .snowboard: return "Snowboard"
            case .speedSkating: return "Speed Skating"
            case .archery: return "Archery"
            case .athletics: return "Athletics"
            case .canoe: return "Canoe"
            case .diving: return "Diving"
            case .dogRacing: return "Dog Racing"
            case .equestrian: return "Equestrian"
            case .callOfDuty: return "Call Of Duty"
            case .electronicFootball: return "Electronic Football"
            case .heartstone: return "Heartstone"
            case .heroesOfTheStorm: return "Heroes of the Storm"
            case .overwatch: return "Overwatch"
            case .smite: return "Smite"
            case .streetFighter: return "Street Fighter"
            case .worldOfTanks: return "World of Tanks"
            case .worldOfWarcraft: return "World of Warcraft"
            case .fencing: return "Fencing"
            case .freestyle: return "Freestyle"
            case .gymnastic: return "Gymnastic"
            case .judo: return "Judo"
            case .lacrosse: return "Lacrosse"
            case .modernPentathlon: return "Modern Pentathlon"
            case .numbers: return "Numbers"
            case .olympics: return "Olympics"
            case .pool: return "Pool"
            case .rowing: return "Rowing"
            case .sailing: return "Sailing"
            case .shooting: return "Shooting"
            case .shortTrackSpeedSkating: return "Short Track Speed Skating"
            case .skeleton: return "Skeleton"
            case .specials: return "Specials"
            case .swimming: return "Swimming"
            case .synchronizedSwimming: return "Synchronized Swimming"
            case .taekwondo: return "Taekwondo"
            case .triathlon: return "Triathlon"
            case .trotting: return "Trotting"
            case .weightlifting: return "Weightlifting"
            case .winterSports: return "Winter Sports"
            case .wrestling: return "Wrestling"
            case .formula1: return "Formula 1"
            case .basketball3X3: return "Basketball 3x3"
            case .formulaE: return "Formula E"
            case .indyRacing: return "Indy Racing"
            case .motorcycleRacing: return "Motorcycle Racing"
            case .playerUnknownsBattlegrounds: return "PlayerUnknowns Battlegrounds"
            case .stockCarRacing: return "Stock Car Racing"
            case .speedway: return "Speedway"
            case .figureSkating: return "Figure Skating"
            case .softball: return "Softball"
            case .canoeSlalom: return "Canoe slalom"
            case .cyclingBmxFreestyle: return "Cycling BMX Freestyle"
            case .cyclingBmxRacing: return "Cycling BMX Racing"
            case .mountainBike: return "Mountain Bike"
            case .trackCycling: return "Track cycling"
            case .sportClimbing: return "Sport Climbing"
            case .trampolineGymnastics: return "Trampoline Gymnastics"
            case .rhythmicGymnastics: return "Rhythmic gymnastics"
            case .karate: return "Karate"
            case .marathonSwimming: return "Marathon Swimming"
            case .skateboarding: return "Skateboarding"
            case .surfing: return "Surfing"
            case .touringCarRacing: return "Touring Car Racing"
            case .rally: return "Rally"
            case .gaelicFootball: return "Gaelic Football"
            case .gaelicHurling: return "Gaelic Hurling"
            case .electronicIceHockey: return "Electronic Ice Hockey"
            case .greyhoundRacing: return "Greyhound Racing"
            case .horseRacing: return "Horse Racing"
            case .emptyBets: return "Empty Bets"
            case .lotteries: return "Lotteries"
            case .virtualHorseRacing: return "Virtual Horse Racing"
            case .virtualGreyhoundRacing: return "Virtual Greyhound Racing"
            case .virtualFootball: return "Virtual Football"
            case .virtualBasketball: return "Virtual Basketball"
            case .virtualTennis: return "Virtual Tennis"
            }
        }
        
        var numericCode: String {
        
            return ""
        }
        
    }
    
}
