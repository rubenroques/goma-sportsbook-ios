//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/11/2022.
//

import Foundation

extension SportRadarModels {
    
    enum BetResult: String, CaseIterable, Codable {
        case won = "Won"
        case lost = "Lost"
        case drawn = "Drawn"
        case open = "Open"
        case void = "Void"
        case pending = "Pending"
        case notSpecified = "NotSpecified"
    }
    
    enum BetState: String, CaseIterable, Codable {
        case attempted = "Attempted"
        case opened = "Opened"
        case closed = "Closed"
        case settled = "Settled"
        case cancelled = "Cancelled"
        case allStates = "AllStates"
        case won = "Won"
        case lost = "Lost"
        case cashedOut = "Cashed Out"
        case void = "Void"
        case undefined = "Undefined"

        init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "attempted", "attempt":
                self = .attempted
            case "opened", "open":
                self = .opened
            case "closed":
                self = .closed
            case "settled":
                self = .settled
            case "cancelled":
                self = .cancelled
            case "won":
                self = .won
            case "lost":
                self = .lost
            case "cashed out":
                self = .cashedOut
            case "void":
                self = .void
            default:
                self = .undefined
            }
        }
    }
    
    struct BettingHistory: Codable {
        var bets: [Bet]
    }

    struct Bet: Codable {
        
        var identifier: String
        var eventName: String

        var homeTeamName: String?
        var awayTeamName: String?

        var sportTypeName: String
        var type: String
        var state: BetState
        var result: BetResult
        var globalState: BetState
        var marketName: String
        var outcomeName: String
        var eventResult: String?
        var potentialReturn: Double?
        var totalReturn: Double?
        var totalOdd: Double
        var totalStake: Double
        var attemptedDate: Date

        var oddNumerator: Double
        var oddDenominator: Double

        var order: Int

        var eventId: Double
        var eventDate: Date?

        var tournamentCountryName: String?
        var tournamentName: String?

        var freeBet: Bool

        var partialCashoutReturn: Double?
        var partialCashoutStake: Double?

        var betslipId: Int?

        var cashbackReturn: Double?
        var freebetReturn: Double?

        var potentialCashbackReturn: Double?
        var potentialFreebetReturn: Double?

        enum CodingKeys: String, CodingKey {
            case identifier = "idFOBet"
            case eventName
            case homeTeamName = "participantHome"
            case awayTeamName = "participantAway"
            case sportTypeName = "idFOSportType"
            case type = "betTypeName"
            case state = "betLegStatus"
            case result = "betResult"
            case globalState = "betState"
            case marketName
            case outcomeName = "selectionName"
            case potentialReturn
            case totalReturn = "totalReturn"
            case totalOdd = "totalMultiBetOdds"
            case totalStake = "totalStake"
            case attemptedDate = "tsAttempted"

            case oddDenominator = "ownPriceDown"
            case oddNumerator = "ownPriceUp"

            case order = "legOrder"
            case eventResult = "eventResult"

            case eventId = "idFOEvent"
            case eventDate = "tsEventTime"

            case tournamentCountryName = "tournamentCountryName"
            case tournamentName = "tournamentName"

            case freeBet = "free"

            case partialCashoutReturn = "partialCashoutReturn"
            case partialCashoutStake = "partialCashoutStake"

            case betslipId = "idFOBetslip"

            case cashbackReturn = "soReturn"
            case freebetReturn = "soFreeReturn"

            case potentialCashbackReturn = "soPotentialReturn"
            case potentialFreebetReturn = "soPotentialFreeReturn"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let identifierDouble = try container.decode(Double.self, forKey: .identifier)
            self.identifier = String(format: "%.2f", identifierDouble)

            self.eventName = try container.decode(String.self, forKey: .eventName)

            self.homeTeamName = try container.decodeIfPresent(String.self, forKey: .homeTeamName)
            self.awayTeamName = try container.decodeIfPresent(String.self, forKey: .awayTeamName)

            self.sportTypeName = try container.decode(String.self, forKey: .sportTypeName)
            self.marketName = try container.decode(String.self, forKey: .marketName)
            self.outcomeName = try container.decode(String.self, forKey: .outcomeName)
            self.eventResult = try container.decodeIfPresent(String.self, forKey: .eventResult)
            self.potentialReturn = (try? container.decode(Double.self, forKey: .potentialReturn)) ?? 0.0
            self.totalReturn = (try? container.decode(Double.self, forKey: .totalReturn)) ?? 0.0

            self.type = try container.decode(String.self, forKey: .type)

            let stateString = try container.decode(String.self, forKey: .state)
            self.state = BetState(rawValue: stateString) ?? .undefined

            let resultString = try container.decode(String.self, forKey: .result)
            self.result = BetResult(rawValue: resultString) ?? .notSpecified

            let globalStateString = try container.decode(String.self, forKey: .globalState)
            self.globalState = BetState(rawValue: globalStateString) ?? .undefined

            self.totalOdd = try container.decode(Double.self, forKey: .totalOdd)
            self.totalStake = try container.decode(Double.self, forKey: .totalStake)

            self.oddNumerator = (try? container.decode(Double.self, forKey: .oddNumerator)) ?? 0.0
            self.oddDenominator = (try? container.decode(Double.self, forKey: .oddDenominator)) ?? 0.0

            self.order = (try? container.decode(Int.self, forKey: .order)) ?? 999

            self.eventId = try container.decode(Double.self, forKey: .eventId)

            if let date = try? container.decode(Date.self, forKey: .attemptedDate) {
                self.attemptedDate = date
            }
            else if let startDateString = try container.decodeIfPresent(String.self, forKey: .attemptedDate) {
                if let date = Self.dateFormatter.date(from: startDateString) {
                    self.attemptedDate = date
                }
                else if let date = Self.fallbackDateFormatter.date(from: startDateString) {
                    self.attemptedDate = date
                }
                else {
                    let context = DecodingError.Context(codingPath: [CodingKeys.attemptedDate], debugDescription: "Start date with wrong format.")
                    throw DecodingError.typeMismatch(Self.self, context)
                }
            }
            else {
                let context = DecodingError.Context(codingPath: [CodingKeys.attemptedDate], debugDescription: "Not start date found.")
                throw DecodingError.valueNotFound(Self.self, context)
            }
            
            if let date = try? container.decode(Date.self, forKey: .eventDate) {
                self.eventDate = date
            }
            else if let startDateString = try container.decodeIfPresent(String.self, forKey: .eventDate) {
                if let date = Self.dateFormatter.date(from: startDateString) {
                    self.eventDate = date
                }
                else if let date = Self.fallbackDateFormatter.date(from: startDateString) {
                    self.eventDate = date
                }
            }
            
            self.tournamentCountryName = try container.decodeIfPresent(String.self, forKey: .tournamentCountryName)

            self.tournamentName = try container.decodeIfPresent(String.self, forKey: .tournamentName)

            if let freeBetIntValue = try container.decodeIfPresent(Int.self, forKey: .freeBet) {
                if freeBetIntValue == -1 {
                    self.freeBet = true
                }
                else {
                    self.freeBet = false
                }
            }
            else if let freeBetStringValue = try container.decodeIfPresent(String.self, forKey: .freeBet) {
                if freeBetStringValue == "-1" {
                    self.freeBet = true
                }
                else {
                    self.freeBet = false
                }
            }
            else if let freeBetBoolValue = try container.decodeIfPresent(Bool.self, forKey: .freeBet) {
                self.freeBet = freeBetBoolValue
            }
            else {
                self.freeBet = false
            }

            self.partialCashoutReturn = try container.decodeIfPresent(Double.self, forKey: .partialCashoutReturn)

            self.partialCashoutStake = try container.decodeIfPresent(Double.self, forKey: .partialCashoutStake)

            self.betslipId = try container.decodeIfPresent(Int.self, forKey: .betslipId)

            self.cashbackReturn = try container.decodeIfPresent(Double.self, forKey: .cashbackReturn)

            self.freebetReturn = try container.decodeIfPresent(Double.self, forKey: .freebetReturn)

            self.potentialCashbackReturn = try container.decodeIfPresent(Double.self, forKey: .potentialCashbackReturn)

            self.potentialFreebetReturn = try container.decodeIfPresent(Double.self, forKey: .potentialFreebetReturn)

        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: CodingKeys.identifier)
            try container.encode(self.eventName, forKey: CodingKeys.eventName)
            try container.encodeIfPresent(self.homeTeamName, forKey: CodingKeys.homeTeamName)
            try container.encodeIfPresent(self.awayTeamName, forKey: CodingKeys.awayTeamName)
            try container.encode(self.sportTypeName, forKey: CodingKeys.sportTypeName)
            try container.encode(self.type, forKey: CodingKeys.type)
            try container.encode(self.state, forKey: CodingKeys.state)
            try container.encode(self.result, forKey: CodingKeys.result)
            try container.encode(self.globalState, forKey: CodingKeys.globalState)
            try container.encode(self.marketName, forKey: CodingKeys.marketName)
            try container.encode(self.outcomeName, forKey: CodingKeys.outcomeName)
            try container.encodeIfPresent(self.potentialReturn, forKey: CodingKeys.potentialReturn)
            try container.encodeIfPresent(self.totalReturn, forKey: CodingKeys.totalReturn)
            try container.encode(self.totalOdd, forKey: CodingKeys.totalOdd)
            try container.encode(self.totalStake, forKey: CodingKeys.totalStake)
            try container.encode(self.attemptedDate, forKey: CodingKeys.attemptedDate)
            try container.encode(self.oddDenominator, forKey: CodingKeys.oddDenominator)
            try container.encode(self.oddNumerator, forKey: CodingKeys.oddNumerator)
            try container.encode(self.order, forKey: CodingKeys.order)
            try container.encodeIfPresent(self.eventResult, forKey: CodingKeys.eventResult)
            try container.encode(self.eventId, forKey: CodingKeys.eventId)
            try container.encodeIfPresent(self.tournamentCountryName, forKey: CodingKeys.tournamentCountryName)
            try container.encodeIfPresent(self.tournamentName, forKey: CodingKeys.tournamentName)
            try container.encodeIfPresent(self.freeBet, forKey: CodingKeys.freeBet)

            try container.encodeIfPresent(self.partialCashoutReturn, forKey: CodingKeys.partialCashoutReturn)

            try container.encodeIfPresent(self.partialCashoutStake, forKey: CodingKeys.partialCashoutStake)

            try container.encodeIfPresent(self.betslipId, forKey: CodingKeys.betslipId)
        }
        
        private static var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }
        
        private static var fallbackDateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter
        }

    }

    struct BetSlip: Codable {
        var tickets: [BetTicket]
    }
    
    struct BetTicket: Codable {
        var selections: [BetTicketSelection]
        var betTypeCode: String
        var placeStake: String
        var winStake: String
        var potentialReturn: Double?
        var pool: Bool
        
        enum CodingKeys: String, CodingKey {
            case selections = "betLegs"
            case betTypeCode = "idFOBetType"
            case placeStake = "placeStake"
            case winStake = "winStake"
            case potentialReturn = "potentialReturn"
            case pool = "pool"
        }
    }
    
    struct BetTicketSelection: Codable {
        var identifier: String
        var eachWayReduction: String
        var eachWayPlaceTerms: String
        var idFOPriceType: String
        var isTrap: String
        var priceUp: String
        var priceDown: String
        
        enum CodingKeys: String, CodingKey {
            case identifier = "idFOSelection"
            case eachWayReduction = "eachWayReduction"
            case eachWayPlaceTerms = "eachWayPlaceTerms"
            case idFOPriceType = "idFOPriceType"
            case isTrap = "isTrap"
            case priceUp = "priceUp"
            case priceDown = "priceDown"
        }
    }

    struct BetslipPotentialReturnResponse: Codable {

        var potentialReturn: Double
        var totalStake: Double
        var numberOfBets: Int
        var totalOdd: Double?

        enum CodingKeys: String, CodingKey {
            case numberOfBets = "unitCount"
            case potentialReturn = "potentialReturn"
            case totalStake = "totalStake"
            case totalOdd = "totalOdd"
        }
        
    }
    
    struct BetBuilderPotentialReturn: Codable {

        var potentialReturn: Double
        var calculatedOdds: Double

        enum CodingKeys: String, CodingKey {
            case potentialReturn = "potentialReturn"
            case calculatedOdds = "calculatedOdds"
        }
        
    }
    

    struct BetType: Codable {

        var typeCode: String
        var typeName: String
        var potencialReturn: Double
        var totalStake: Double
        var numberOfIndividualBets: Int

        enum CodingKeys: String, CodingKey {
            case numberOfIndividualBets = "unitCount"
            case typeCode = "idFOBetType"
            case typeName = "name"
            case potencialReturn = "potentialReturn"
            case totalStake = "totalStake"
        }
        
    }

    struct BetSlipStateResponse: Codable {
        var tickets: [BetTicket]
    }

    struct ConfirmBetPlaceResponse: Codable {
        var state: Int
        var detailedState: Int
        var statusCode: String?
        var statusText: String?

        enum CodingKeys: String, CodingKey {
            case state = "state"
            case detailedState = "detailedState"
            case statusCode = "statusCode"
            case statusText = "statusText"
        }
    }

    
    struct PlacedBetsResponse: Codable {
        var identifier: String
        var responseCode: String
        var detailedResponseCode: String?
        var errorMessage: String?
        var totalStake: Double
        var bets: [PlacedBetEntry]

        enum CodingKeys: String, CodingKey {
            case identifier = "idFOBetSlip"
            case bets = "bets"
            
            case status = "status"
            case betStatus = "betStatus"
            
            case responseCode = "state"
            case detailedResponseCode = "detailedState"
            
            case totalStake = "totalStake"
            
            case errorMessage = "statusText"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetsResponse.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

                let identifierInt = try container.decode(Int.self, forKey: .identifier)
                self.identifier = "\(identifierInt)"
                self.bets = try container.decode([SportRadarModels.PlacedBetEntry].self, forKey: .bets)

                let statusContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .status)
                let statusCodeInt = (try? statusContainer?.decodeIfPresent(Int.self, forKey: .responseCode)) ?? 0
                self.responseCode = "\(statusCodeInt)"
                
                let detailedResponseCodeInt = (try? statusContainer?.decodeIfPresent(Int.self, forKey: .detailedResponseCode)) ?? 0
                self.detailedResponseCode = "\(detailedResponseCodeInt)"
                
                self.errorMessage = try statusContainer?.decodeIfPresent(String.self, forKey: .errorMessage)
            
                self.totalStake = try container.decodeIfPresent(Double.self, forKey: .totalStake) ?? 0.0
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: CodingKeys.identifier)
            try container.encode(self.bets, forKey: CodingKeys.bets)
            try container.encode(self.responseCode, forKey: CodingKeys.responseCode)
        }
        
    }

    struct PlacedBetEntry: Codable {
        var identifier: String
        var potentialReturn: Double
        var placeStake: Double
        var totalAvailableStake: Double
        var betLegs: [PlacedBetLeg]
        var type: String?

        enum CodingKeys: String, CodingKey {
            case identifier = "idFoBet"
            case betLegs = "betLegs"
            case potentialReturn = "potentialReturn"
            case placeStake = "placeStake"
            case totalAvailableStake = "totalStake"
            case type = "idfoBetType"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetEntry.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PlacedBetEntry.CodingKeys.self)
            let identifierDouble = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.identifier)
            self.identifier = String(format: "%.2f", identifierDouble)

            self.betLegs = try container.decode([SportRadarModels.PlacedBetLeg].self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.betLegs)
            self.potentialReturn = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.potentialReturn)
            
            self.totalAvailableStake = try container.decodeIfPresent(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.totalAvailableStake) ?? 0.0
            
            if let placeStake = try? container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.placeStake) {
                self.placeStake = placeStake
            }
            else {
                self.placeStake = self.totalAvailableStake
            }
            
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
        }
    }

    struct PlacedBetLeg: Codable {
        var identifier: String
        var priceType: String

        var odd: Double {
            let priceNumerator = Double(self.priceNumerator)
            let priceDenominator = Double(self.priceDenominator)
            return (priceNumerator/priceDenominator) + 1.0
        }

        var priceNumerator: Int
        var priceDenominator: Int

        enum CodingKeys: String, CodingKey {
            case identifier = "idFOSelection"
            case priceNumerator = "priceUp"
            case priceDenominator = "priceDown"
            case priceType = "idFOPriceType"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetLeg.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PlacedBetLeg.CodingKeys.self)

            let identifierDouble = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.identifier)
            self.identifier = String(format: "%.1f", identifierDouble)

            self.priceNumerator = (try? container.decode(Int.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceNumerator)) ?? 0
            self.priceDenominator = (try? container.decode(Int.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceDenominator)) ?? 0
            self.priceType = try container.decode(String.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceType)
        }

    }


    struct BetslipSettings: Codable {
        
        var oddChangeLegacy: BetslipOddChangeSetting?
        var oddChangeRunningOrPreMatch: BetslipOddChangeSetting?
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case value = "value"
            case acceptingReofferLegacy = "acceptingReofferLegacy"
            case acceptingReofferBoth = "acceptingReofferBoth"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let settings = try container.decode([Settings].self)
            
            if let acceptingReofferRunSetting = settings.first(where: { $0.id ?? 0 == 667 }),
               let acceptingReofferPreSetting = settings.first(where: { $0.id ?? 0 == 668 }),
               let runningValue = acceptingReofferRunSetting.value,
               acceptingReofferPreSetting.value != nil {
                
                switch runningValue {
                case "none":
                    self.oddChangeRunningOrPreMatch = BetslipOddChangeSetting.none
                case "higher":
                    self.oddChangeRunningOrPreMatch = BetslipOddChangeSetting.higher
                default:
                    self.oddChangeRunningOrPreMatch = BetslipOddChangeSetting.none
                }
                
                //
                self.oddChangeLegacy = nil
            }
            else if 
                let acceptingReofferSetting = settings.first(where: { $0.name == "OddsChange" }),
                let value = acceptingReofferSetting.value
            {
                switch value {
                case "none":
                    self.oddChangeLegacy = BetslipOddChangeSetting.none
                case "higher":
                    self.oddChangeLegacy = BetslipOddChangeSetting.higher
                default:
                    self.oddChangeLegacy = BetslipOddChangeSetting.none
                }
                
                //
                self.oddChangeRunningOrPreMatch = nil
            }
            else {
                self.oddChangeRunningOrPreMatch = BetslipOddChangeSetting.none
                self.oddChangeLegacy = nil
            }
        }

        private struct Settings: Codable {
            var name: String?
            var value: String?
            var id: Int?
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: SportRadarModels.BetslipSettings.CodingKeys.self)
            try container.encode(self.oddChangeLegacy, forKey: .acceptingReofferLegacy)
            try container.encode(self.oddChangeRunningOrPreMatch, forKey: .acceptingReofferBoth)
        }

    }


}
