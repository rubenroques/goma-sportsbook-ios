//
//  BettingAPIClient.swift
//  
//
//  Created by Ruben Roques on 11/11/2022.
//

import Foundation

enum BettingAPIClient {
    case betHistory(page: Int, startDate: Date?, endDate: Date?, betState: [SportRadarModels.BetState]?, betResult: [SportRadarModels.BetResult]?)
    case calculateReturns(betTicket: BetTicket)
    case getAllowedBetTypes(betTicketSelections: [BetTicketSelection])
    case placeBet(betTicketSelection: BetTicketSelection, stake: Double)
}

extension BettingAPIClient: Endpoint {
    
    var endpoint: String {
        switch self {
        case .betHistory:
            return "/api/betting/fo/bets"
        case .calculateReturns:
            return "/api/betting/fo/bet/calculate"
        case .getAllowedBetTypes:
            return "/api/betting/fo/allowedBetTypesWithCalculation"
        case .placeBet:
            return "/api/betting/fo/betslip"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .betHistory(let page, let startDate, let endDate, let betStates, let betOutcomes):
            
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
                query.append(URLQueryItem(name: "betStateTypes", value: betOutcomes))
            }
            query.append(URLQueryItem(name: "pageSize", value: "10"))
            query.append(URLQueryItem(name: "pageNumber", value: "\(page)"))
            return query
        case .calculateReturns:
            return nil
        case .getAllowedBetTypes:
            return nil
        case .placeBet:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .betHistory:
            return nil
        case .calculateReturns(let betTicket):
            let jsonData = (try? JSONEncoder().encode(betTicket)) ?? Data()
            // let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonData

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

        // ===================================================
        case .placeBet(let betTicketSelection, let stake):

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

            let body = """
                       {
                         "bets": [
                           {
                             "betLegs": [
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
                             ],
                             "idFOBetType": "S",
                             "pool": false,
                             "placeStake": \(stake),
                             "showStake": 0,
                             "winStake": 0
                           }
                         ],
                         "useAutoAcceptance": true
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        // ===================================================
        }
        
    }
    
    var method: HTTP.Method {
        switch self {
        case .betHistory: return .get
        case .calculateReturns: return .post
        case .getAllowedBetTypes: return .post
        case .placeBet: return .post
        }
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .betHistory:
            return true
        case .calculateReturns:
            return false
        case .getAllowedBetTypes:
            return false
        case .placeBet:
            return true
        }
    }
    
    var url: String {
        return SportRadarConstants.bettingHostname
    }
    
    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json",
            "X-MGS-BusinessUnit": "10013",
            "X-MGS-Location": "UK",
        ]
        return defaultHeaders
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        return TimeInterval(20)
    }
    
    
}
