//
//  BettingAPIClient.swift
//  
//
//  Created by Ruben Roques on 11/11/2022.
//

import Foundation

enum BettingAPIClient {
    case betHistory(page: Int, startDate: Date?, endDate: Date?, betState: [SportRadarModels.BetState]?, betOutcome: [SportRadarModels.BetOutcome]?)
    case calculateReturns(betTicket: SportRadarModels.BetTicket)
}

extension BettingAPIClient: Endpoint {
    
    var endpoint: String {
        switch self {
        case .betHistory:
            return "/fo/bets"
        case .calculateReturns:
            return "/fo/bet/calculate"
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
        }
        
    }
    
    var method: HTTP.Method {
        switch self {
        case .betHistory: return .get
        case .calculateReturns: return .post
        }
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .betHistory:
            return true
        case .calculateReturns:
            return false
        }
    }
    
    var url: String {
        return SportRadarConstants.bettingURL
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
