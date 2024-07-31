//
//  BettingAPIClient.swift
//  
//
//  Created by Ruben Roques on 11/11/2022.
//

import Foundation

enum BettingAPIClient {
    case betHistory(page: Int, startDate: String?, endDate: String?, betState: [SportRadarModels.BetState]?, betResult: [SportRadarModels.BetResult]?, pageSize: Int)
    case betDetails(identifier: String)
    case calculateReturns(betTicket: BetTicket)
    case getAllowedBetTypes(betTicketSelections: [BetTicketSelection])
    case placeBets(betTickets: [BetTicket], useFreebetBalance: Bool)
    
    case confirmBoostedBet(identifier: String)
    case rejectBoostedBet(identifier: String)
    
    case calculateCashout(betId: String, stakeValue: String?)
    case cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?)
    case getBetslipSettings
    
    case updateBetslipSettings(oddChange: BetslipOddChangeSetting)
    case updateBetslipSettingsPreMatch(oddChange: BetslipOddChangeSetting)
    case updateBetslipSettingsRunning(oddChange: BetslipOddChangeSetting)
    
    case getFreebetBalance
    case getSharedTicket(betslipId: String)
    case getTicketSelection(ticketSelectionId: String)
    case calculateCashback(betTicket: BetTicket)
}

extension BettingAPIClient: Endpoint {
    
    var endpoint: String {
        switch self {
        case .betHistory:
            return "/api/betting/fo/bets"
        case .betDetails(let identifier):
            return "/api/betting/fo/bets/\(identifier)"
        case .calculateReturns:
            return "/api/betting/fo/bet/calculate"
        case .getAllowedBetTypes:
            return "/api/betting/fo/allowedBetTypesWithCalculation"
        case .placeBets:
            return "/api/betting/fo/betslip"
            
        case .confirmBoostedBet(let identifier):
            return "/api/betting/fo/betslip/\(identifier)/confirm"
        case .rejectBoostedBet(let identifier):
            return "/api/betting/fo/betslip/\(identifier)/reject"
            
        case .calculateCashout(let betId, _):
            return "/api/cashout/fo/cashout/\(betId)/calculate"
        case .cashoutBet(let betId, _, _):
            return "/api/cashout/fo/cashout/\(betId)"
        case .getBetslipSettings:
            return "/api/betting/fo/attribute/getAll"
        case .updateBetslipSettings:
            return "/api/betting/fo/attribute/update"
        case .updateBetslipSettingsRunning:
            return "/api/betting/fo/attribute/update"
        case .updateBetslipSettingsPreMatch:
            return "/api/betting/fo/attribute/update"
            
        case .getFreebetBalance:
            return "/api/betting/fo/freeBalance"
        case .getSharedTicket(let betslipId):
            return "/api/betting/fo/bookbetslip/\(betslipId)"
        case .getTicketSelection:
            return "/services/content/get"
        case .calculateCashback:
            return "/api/special-offer-calculator/v1/calculateSpecialOffers"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .betHistory(let page, let startDate, let endDate, let betStates, let betOutcomes, let pageSize):
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS"
//
            var query: [URLQueryItem] = []
//
//            if let startDate = startDate {
//                query.append(URLQueryItem(name: "from", value: dateFormatter.string(from: startDate)))
//            }
//            if let endDate = endDate {
//                query.append(URLQueryItem(name: "to", value: dateFormatter.string(from: endDate)))
//            }

            if let startDate = startDate {
                query.append(URLQueryItem(name: "from", value: startDate))
            }

            if let endDate = endDate {
                query.append(URLQueryItem(name: "to", value: endDate))
            }
            
            if let betStates = betStates?.map(\.rawValue).joined(separator: ",") {
                query.append(URLQueryItem(name: "betStateTypes", value: betStates))
            }

            if let betOutcomes = betOutcomes?.map(\.rawValue).joined(separator: ",") {
                query.append(URLQueryItem(name: "betOutcomes", value: betOutcomes))
            }
            else {
                query.append(URLQueryItem(name: "betOutcomes", value: "NotSpecified"))
            }

            query.append(URLQueryItem(name: "orderBy", value: "0"))
            query.append(URLQueryItem(name: "orderDesc", value: "true"))
            
            query.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))

            query.append(URLQueryItem(name: "pageNumber", value: "\(page)"))

            return query
        case .betDetails:
            return nil
        case .calculateReturns:
            return nil
        case .getAllowedBetTypes:
            return nil
        case .placeBets:
            return nil
        
        case .confirmBoostedBet:
            return nil
        case .rejectBoostedBet:
            return nil
            
        case .calculateCashout:
            return nil
        case .cashoutBet:
            return nil
        case .getBetslipSettings:
            return nil
        case .updateBetslipSettings:
            return nil
        
        case .updateBetslipSettingsRunning:
            return nil
        case .updateBetslipSettingsPreMatch:
            return nil
            
        case .getFreebetBalance:
            return nil
        case .getSharedTicket:
            return nil
        case .getTicketSelection:
            return nil
        case .calculateCashback:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .betHistory:
            return nil
        case .betDetails:
            return nil
        case .calculateReturns(let betTicket):
            return Self.createBetLegsJSONBody(fromBetTicket: betTicket)

            // ===================================================
        case .getAllowedBetTypes(let betTicketSelections):

            var betLegs: [String] = []

            for betTicketSelection in betTicketSelections {
                let priceDown: String
                let priceUp: String

                switch betTicketSelection.odd {
                case .fraction(let numerator, let denominator):
                    priceUp = "\(numerator)"
                    priceDown = "\(denominator)"
                case .decimal:
                    priceUp = ""
                    priceDown = ""
                }

                let leg  =
                """
                   {
                     "eachWayPlaceTerms": "",
                     "eachWayReduction": "",
                     "handicap": "",
                     "idFOPriceType": "CP",
                     "idFOSelection": "\(betTicketSelection.identifier)",
                     "isTrap": "",
                     "lowerBand": "",
                     "priceDown": "\(priceDown)",
                     "priceUp": "\(priceUp)",
                     "systemTag": "",
                     "upperBand": ""
                   }
                """
                betLegs.append(leg)
            }
            let body = """
                       {
                         "betLegs": [
                            \(betLegs.joined(separator: ","))
                         ],
                         "idFOBetType": "",
                         "winStake": 0,
                         "isPool": false
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        case .placeBets(let betTickets, let useFreebetBalance):

            var betsArray: [String] = []
            for ticket in betTickets {
                var legsStringArray: [String] = []
                for selection in ticket.tickets {
                    let priceDown: String
                    let priceUp: String

                    switch selection.odd {
                    case .fraction(let numerator, let denominator):
                        priceUp = "\(numerator)"
                        priceDown = "\(denominator)"
                    case .decimal:
                        priceUp = ""
                        priceDown = ""
                    }

                    legsStringArray.append(
                    """
                    {
                      "eachWayPlaceTerms": "",
                      "eachWayReduction": "",
                      "handicap": "",
                      "idFOPriceType": "CP",
                      "idFOSelection": "\(selection.identifier)",
                      "isTrap": "",
                      "lowerBand": "",
                      "priceDown": "\(priceDown)",
                      "priceUp": "\(priceUp)",
                      "systemTag": "",
                      "upperBand": ""
                    }
                    """)
                }

                let legsString = legsStringArray.joined(separator: ",")
                betsArray.append(
                    """
                    {
                        "betLegs": [ \(legsString) ],
                        "idFOBetType": "\(ticket.betGroupingType.identifier)",
                        "pool": false,
                        "winStake": \(ticket.globalStake ?? 0.0)
                    }
                    """)
            }

            let betsString = betsArray.joined(separator: ",")

            let body = """
                       {
                         "bets": [\(betsString)],
                         "useAutoAcceptance": true,
                         "free": \(useFreebetBalance)
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        //
        case .confirmBoostedBet:
            let body = """
                        {
                            "betStatus": {
                                "state": 1,
                                "detailedState": 66,
                                "statusCode": null,
                                "statusText": null
                            },
                            "securityCode": ""
                        }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .rejectBoostedBet:
            let data = "{}".data(using: String.Encoding.utf8)!
            return data
            
        //
        case .calculateCashout(_, let stakeValue):

            if let stakeValue {
                let body = """
                           {
                             "stakeValue": \(stakeValue)
                           }
                           """
                let data = body.data(using: String.Encoding.utf8)!
                return data
            }
            else {
                return nil
            }

        case .cashoutBet( _, let cashoutValue, let stakeValue):
            if let stakeValue {
                let body = """
                       {
                         "expectedValue": \(cashoutValue),
                         "stakeValue": \(stakeValue)
                       }
                       """
                let data = body.data(using: String.Encoding.utf8)!
                return data
            }

            let body = """
                   {
                     "expectedValue": \(cashoutValue)
                   }
                   """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        case .getBetslipSettings:
            return nil
        case .updateBetslipSettings(let oddChange):

            var acceptingReofferStringValue = "none"
            switch oddChange {
            case .none:
                acceptingReofferStringValue = "none"
            case .higher:
                acceptingReofferStringValue = "higher"
            }
            
            let body = """
                       {
                       "id": 648,
                       "name": "OddsChange",
                       "value": "\(acceptingReofferStringValue)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        case .updateBetslipSettingsRunning(let oddChange):

            var acceptingReofferStringValue = "none"
            switch oddChange {
            case .none:
                acceptingReofferStringValue = "none"
            case .higher:
                acceptingReofferStringValue = "higher"
            }
            
            let body = """
                       {
                       "id": 668,
                       "name": "oddsChangePreMatch",
                       "value": "\(acceptingReofferStringValue)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .updateBetslipSettingsPreMatch(let oddChange):

            var acceptingReofferStringValue = "none"
            switch oddChange {
            case .none:
                acceptingReofferStringValue = "none"
            case .higher:
                acceptingReofferStringValue = "higher"
            }
            
            let body = """
                       {
                       "id": 667,
                       "name": "oddsChangeInRunning",
                       "value": "\(acceptingReofferStringValue)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .getFreebetBalance:
            return nil
        case .getSharedTicket:
            return nil
        case .getTicketSelection(let ticketSelectionId):
            let body = """
                       {
                        "clientContext": {
                            "ipAddress": "127.0.0.1",
                            "language": "\(SportRadarConfiguration.shared.socketLanguageCode)"
                        },
                        "contentId": {
                            "id": "\(ticketSelectionId)",
                            "type": "selection"
                        }
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        case .calculateCashback(let betTicket):
            return Self.createCashbackBetLegsJSONBody(fromBetTicket: betTicket)
        }
        
    }
    
    var method: HTTP.Method {
        switch self {
        case .betHistory: return .get
        case .betDetails: return .get
        case .calculateReturns: return .post
        case .getAllowedBetTypes: return .post
        case .placeBets: return .post
            
        case .confirmBoostedBet: return .put
        case .rejectBoostedBet: return .post
            
        case .calculateCashout: return .post
        case .cashoutBet: return .post
        case .getBetslipSettings: return .get
        case .updateBetslipSettings: return .post
        case .updateBetslipSettingsRunning: return .post
        case .updateBetslipSettingsPreMatch: return .post
        case .getFreebetBalance: return .get
        case .getSharedTicket: return .get
        case .getTicketSelection: return .post
        case .calculateCashback: return .post
        }
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .betHistory: return true
        case .betDetails: return true
        case .calculateReturns: return false
        case .getAllowedBetTypes: return false
        case .placeBets: return true
            
        case .confirmBoostedBet: return true
        case .rejectBoostedBet: return true
            
        case .calculateCashout: return true
        case .cashoutBet: return true
        
        case .getBetslipSettings: return true
        case .updateBetslipSettings: return true
        case .updateBetslipSettingsRunning: return true
        case .updateBetslipSettingsPreMatch: return true
            
        case .getFreebetBalance: return true
        case .getSharedTicket: return false
        case .getTicketSelection: return false
        case .calculateCashback: return true
        }
    }
    
    var url: String {
        switch self {
        case .getTicketSelection:
            return SportRadarConfiguration.shared.servicesRestHostname
        default:
            return SportRadarConfiguration.shared.apiRestHostname
        }
    }
    
    var headers: HTTP.Headers? {
        switch self {
        case .confirmBoostedBet, .rejectBoostedBet:
            return [
                "Content-Type": "application/json",
                "X-MGS-BusinessUnit": "3",
                "X-MGS-Location": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                "Accept-Language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
            ]
        default:
            return [
                "Accept-Encoding": "gzip, deflate",
                "Content-Type": "application/json; charset=UTF-8",
                "Accept": "application/json",
                "X-MGS-BusinessUnit": "3",
                "app-origin": "ios",
                "Accept-Languag": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                "X-MGS-Location": "\(SportRadarConfiguration.shared.socketLanguageCode)",
            ]
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        switch self {
        case .betHistory: return TimeInterval(180)
        case .betDetails: return TimeInterval(180)
        case .calculateReturns: return TimeInterval(180)
        case .getAllowedBetTypes: return TimeInterval(180)
        case .placeBets: return TimeInterval(180)
            
        case .confirmBoostedBet: return TimeInterval(180)
        case .rejectBoostedBet: return TimeInterval(180)
            
        case .calculateCashout: return TimeInterval(180)
        case .cashoutBet: return TimeInterval(180)
            
        case .getBetslipSettings: return TimeInterval(180)
        case .updateBetslipSettings: return TimeInterval(180)
        case .updateBetslipSettingsRunning: return TimeInterval(180)
        case .updateBetslipSettingsPreMatch: return TimeInterval(180)
            
        case .getFreebetBalance: return TimeInterval(180)
        case .getSharedTicket: return TimeInterval(180)
        case .getTicketSelection: return TimeInterval(180)
        case .calculateCashback: return TimeInterval(180)
        }
    }
    
    var comment: String? {
        switch self {
        case .betHistory: return "betHistory"
        case .betDetails: return "betDetails"
        case .calculateReturns: return "calculateReturns"
        case .getAllowedBetTypes: return "getAllowedBetTypes"
        case .placeBets: return "placeBets"
        case .confirmBoostedBet: return "confirmBoostedBet"
        case .rejectBoostedBet: return "rejectBoostedBet"
        case .calculateCashout: return "calculateCashout"
        case .cashoutBet: return "cashoutBet"
        
        case .getBetslipSettings: return "getBetslipSettings"
        case .updateBetslipSettings: return "updateBetslipSettings"
        case .updateBetslipSettingsRunning: return "updateBetslipSettingsRunning"
        case .updateBetslipSettingsPreMatch: return "updateBetslipSettingsPreMatch"
            
        case .getFreebetBalance: return "getFreebetBalance"
        case .getSharedTicket: return "getSharedTicket"
        case .getTicketSelection: return "getTicketSelection"
        case .calculateCashback: return "calculateCashback"
        }
    }
    
    // TODO: Check if we can use this in every endpoint
    private static func createBetJSONBody(fromBetTickets betTickets: [BetTicket]) -> Data {
        var betsArray: [String] = []
        for ticket in betTickets {
            var legsStringArray: [String] = []
            for selection in ticket.tickets {
                let priceDown: String
                let priceUp: String

                switch selection.odd {
                case .fraction(let numerator, let denominator):
                    priceUp = "\(numerator)"
                    priceDown = "\(denominator)"
                case .decimal:
                    priceUp = ""
                    priceDown = ""
                }

                legsStringArray.append(
                """
                {
                  "eachWayPlaceTerms": "",
                  "eachWayReduction": "",
                  "handicap": "",
                  "idFOPriceType": "CP",
                  "idFOSelection": "\(selection.identifier)",
                  "isTrap": "",
                  "lowerBand": "",
                  "priceDown": "\(priceDown)",
                  "priceUp": "\(priceUp)",
                  "systemTag": "",
                  "upperBand": ""
                }
                """)
            }

            let legsString = legsStringArray.joined(separator: ",")
            betsArray.append(
                """
                {
                    "betLegs": [ \(legsString) ],
                    "idFOBetType": "\(ticket.betGroupingType.identifier)",
                    "pool": false,
                    "winStake": \(ticket.globalStake ?? 0.0)
                }
                """)
        }

        let betsString = betsArray.joined(separator: ",")
        let body = """
                   {
                     "bets": [\(betsString)],
                     "useAutoAcceptance": true
                   }
                   """

        let data = body.data(using: String.Encoding.utf8)!
        return data
    }

    private static func createBetLegsJSONBody(fromBetTicket betTicket: BetTicket) -> Data {

        var legsStringArray: [String] = []
        for selection in betTicket.tickets {
            let priceDown: String
            let priceUp: String

            switch selection.odd {
            case .fraction(let numerator, let denominator):
                priceUp = "\(numerator)"
                priceDown = "\(denominator)"
            case .decimal:
                priceUp = ""
                priceDown = ""
            }

            legsStringArray.append(
                """
                {
                  "eachWayPlaceTerms": "",
                  "eachWayReduction": "",
                  "handicap": "",
                  "idFOPriceType": "CP",
                  "idFOSelection": "\(selection.identifier)",
                  "isTrap": "",
                  "lowerBand": "",
                  "priceDown": "\(priceDown)",
                  "priceUp": "\(priceUp)",
                  "systemTag": "",
                  "upperBand": ""
                }
                """)
        }

        let legsString = legsStringArray.joined(separator: ",")
        let body =
                """
                {
                    "betLegs": [ \(legsString) ],
                    "idFOBetType": "\(betTicket.betGroupingType.identifier)",
                    "pool": false,
                    "winStake": \(betTicket.globalStake ?? 0.0)
                }
                """

        let data = body.data(using: String.Encoding.utf8)!
        return data
    }

    private static func createCashbackBetLegsJSONBody(fromBetTicket betTicket: BetTicket) -> Data {

        var legsStringArray: [String] = []
        for selection in betTicket.tickets {
            let sport = selection
            let priceDown: String
            let priceUp: String

            switch selection.odd {
            case .fraction(let numerator, let denominator):
                priceUp = "\(numerator)"
                priceDown = "\(denominator)"
            case .decimal:
                priceUp = ""
                priceDown = ""
            }

            legsStringArray.append(
                """
                {
                "idFOPriceType": "CP",
                "idFOSelection": "\(selection.identifier)",
                "priceDown": "\(priceDown)",
                "priceUp": "\(priceUp)",
                "idFOSport": "\(selection.sportIdCode ?? "SPORT")",
                "idFOMarket": "\(selection.marketName)",
                "idFOEvent": "\(selection.eventName)"
                }
                """)
        }

        let legsString = legsStringArray.joined(separator: ",")
        let body =
                """
                {
                    "betLegs": [ \(legsString) ],
                    "idFOBetType": "\(betTicket.betGroupingType.identifier)",
                    "wunitstake": \(betTicket.globalStake ?? 0.0)
                }
                """

        let data = body.data(using: String.Encoding.utf8)!
        return data
    }

}
//
//{
//    "betLegs": [
//        {
//            "priceType": "CP",
//            "idFOSelection": "251663186.1",
//            "priceDown": "100",
//            "priceUp": "79",
//            "idFOSport": "SPORT",
//            "idFOMarket": "50930219.1",
//            "idFOEvent": "3234242.1"
//        },
//        {
//            "priceType": "CP",
//            "idFOSelection": "251663184.1",
//            "priceDown": "100",
//            "priceUp": "61",
//            "idFOSport": "SPORT",
//            "idFOMarket": "50930218.1",
//            "idFOEvent": "3234243.1"
//        },
//        {
//            "priceType": "CP",
//            "idFOSelection": "251260968.1",
//            "priceDown": "100",
//            "priceUp": "187",
//            "idFOSport": "SPORT",
//            "idFOMarket": "50844314.1",
//            "idFOEvent": "3233037.1"
//        }
//    ],
//    "betType": "T",
//    "wunitstake": 10
//}

