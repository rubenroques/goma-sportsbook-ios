//
//  BettingAPIClient.swift
//  
//
//  Created by Ruben Roques on 11/11/2022.
//

import Foundation

enum BettingAPIClient {
    case betHistory(page: Int, startDate: Date?, endDate: Date?, betState: [SportRadarModels.BetState]?, betResult: [SportRadarModels.BetResult]?, pageSize: Int)
    case betDetails(identifier: String)
    case calculateReturns(betTicket: BetTicket)
    case getAllowedBetTypes(betTicketSelections: [BetTicketSelection])
    case placeBets(betTickets: [BetTicket])
    case calculateCashout(betId: String)
    case cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double)
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
        case .calculateCashout(let betId):
            return "/api/cashout/fo/cashout/\(betId)/calculate"
        case .cashoutBet(let betId, _, _):
            return "/api/cashout/fo/cashout/\(betId)"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .betHistory(let page, let startDate, let endDate, let betStates, let betOutcomes, let pageSize):
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS"
            
            var query: [URLQueryItem] = []
            
            if let startDate = startDate {
                query.append(URLQueryItem(name: "from", value: dateFormatter.string(from: startDate)))
            }
            if let endDate = endDate {
                query.append(URLQueryItem(name: "to", value: dateFormatter.string(from: endDate)))
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
        case .calculateCashout:
            return nil
        case .cashoutBet:
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
                case .european:
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
                         "placeStake": "",
                         "winStake": 0,
                         "isPool": false
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

        case .placeBets(let betTickets):

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
                    case .european:
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
                        "placeStake": 0,
                        "showStake": 0,
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

        case .calculateCashout:
            return nil

        case .cashoutBet( _, let cashoutValue, let stakeValue):
            let body = """
                       {
                         "expectedValue": \(cashoutValue),
                         "stakeValue": \(stakeValue)
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        }
        
    }
    
    var method: HTTP.Method {
        switch self {
        case .betHistory: return .get
        case .betDetails: return .get
        case .calculateReturns: return .post
        case .getAllowedBetTypes: return .post
        case .placeBets: return .post
        case .calculateCashout: return .post
        case .cashoutBet: return .post
        }
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .betHistory: return true
        case .betDetails: return true
        case .calculateReturns: return false
        case .getAllowedBetTypes: return false
        case .placeBets: return true
        case .calculateCashout: return true
        case .cashoutBet: return true
        }
    }
    
    var url: String {
        return SportRadarConstants.apiRestHostname
    }
    
    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json",
            "X-MGS-BusinessUnit": "3",
            "X-MGS-Location": "UK",
        ]
        return defaultHeaders
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        switch self {
        case .betHistory: return TimeInterval(5)
        case .betDetails: return TimeInterval(5)
        case .calculateReturns: return TimeInterval(5)
        case .getAllowedBetTypes: return TimeInterval(5)
        case .placeBets: return TimeInterval(60)
        case .calculateCashout: return TimeInterval(60)
        case .cashoutBet: return TimeInterval(5)
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
                case .european:
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
                    "placeStake": 0,
                    "showStake": 0,
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
            case .european:
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
                    "placeStake": 0,
                    "showStake": 0,
                    "winStake": \(betTicket.globalStake ?? 0.0)
                }
                """

        let data = body.data(using: String.Encoding.utf8)!
        return data
    }

}


