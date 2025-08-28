//
//  EveryMatrixOddsMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation

enum EveryMatrixOddsMatrixAPI {
    case placeBet(betData: PlaceBetRequest)
    
    // MyBets API endpoints
    case getOpenBets(limit: Int, placedBefore: String)
    case getSettledBets(limit: Int, placedBefore: String, betStatus: String?)
    case calculateCashout(betId: String, stakeValue: String?)
    case cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?)
}

extension EveryMatrixOddsMatrixAPI: Endpoint {
    var url: String {
        return EveryMatrixOddsMatrixConfiguration.default.environment.baseURL
    }
    
    var endpoint: String {
        let domainId = EveryMatrixOddsMatrixConfiguration.default.environment.domainId
        switch self {
        case .placeBet:
            return "/place-bet/\(domainId)/v2/bets"
        case .getOpenBets:
            return "/bets-api/v1/\(domainId)/open-bets"
        case .getSettledBets:
            return "/bets-api/v1/\(domainId)/settled-bets"
        case .calculateCashout:
            return "/bets-api/v1/\(domainId)/cashout-amount"
        case .cashoutBet:
            return "/bets-api/v1/\(domainId)/cashout"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .placeBet, .cashoutBet:
            return nil
        case .getOpenBets(let limit, let placedBefore):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "placedBefore", value: placedBefore)
            ]
        case .getSettledBets(let limit, let placedBefore, let betStatus):
            var queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "placedBefore", value: placedBefore)
            ]
            if let betStatus = betStatus {
                queryItems.append(URLQueryItem(name: "betStatus", value: betStatus))
            }
            return queryItems
        case .calculateCashout(let betId, let stakeValue):
            var queryItems = [URLQueryItem(name: "betId", value: betId)]
            if let stakeValue = stakeValue {
                queryItems.append(URLQueryItem(name: "stakeValue", value: stakeValue))
            }
            return queryItems
        }
    }
    
    var headers: HTTP.Headers? {
        let domainId = EveryMatrixOddsMatrixConfiguration.default.environment.domainId
        switch self {
        case .placeBet:
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-operatorid": domainId
            ]
            return headers
        case .getOpenBets, .getSettledBets, .calculateCashout, .cashoutBet:
            // MyBets API requires EveryMatrix session headers
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-operator-id": domainId,
                "x-language": "en"
            ]
            return headers
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixOddsMatrixConfiguration.default.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .placeBet, .cashoutBet:
            return .post
        case .getOpenBets, .getSettledBets, .calculateCashout:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .placeBet(let betData):
            return try? JSONEncoder().encode(betData)
        case .cashoutBet(let betId, let cashoutValue, let stakeValue):
            let cashoutRequest = EveryMatrix.CashoutRequest(
                betId: betId,
                cashoutValue: cashoutValue,
                cashoutType: stakeValue != nil ? "PARTIAL" : "FULL",
                partialCashoutStake: stakeValue
            )
            return try? JSONEncoder().encode(cashoutRequest)
        case .getOpenBets, .getSettledBets, .calculateCashout:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixOddsMatrixConfiguration.default.defaultTimeout
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .placeBet, .getOpenBets, .getSettledBets, .calculateCashout, .cashoutBet:
            return true
        }
    }
    
    var comment: String? {
        return nil
    }
    
    func authHeaderKey(for type: AuthHeaderType) -> String? {
        switch self {
        case .placeBet:
            // Place bet uses different header format
            switch type {
            case .sessionId:
                return "x-sessionid"  // No hyphen for place bet
            case .userId:
                return nil  // Place bet doesn't need user ID
            }
        case .getOpenBets, .getSettledBets, .calculateCashout, .cashoutBet:
            // MyBets APIs use standard format
            switch type {
            case .sessionId:
                return "x-session-id"  // With hyphen for MyBets APIs
            case .userId:
                return "x-user-id"     // MyBets APIs need user ID
            }
        }
    }
}

// MARK: - Request Models
public struct PlaceBetRequest: Codable {
    public let ucsOperatorId: Int
    public let userId: String
    public let username: String
    public let currency: String
    public let type: String
    public let selections: [BetSelectionInfo]
    public let amount: Double
    public let oddsValidationType: String
    public let terminalType: String
    public let ubsWalletId: String?
    public let freeBet: String?
    
    public init(ucsOperatorId: Int, userId: String, username: String, currency: String, type: String, selections: [BetSelectionInfo], amount: Double, oddsValidationType: String, terminalType: String, ubsWalletId: String? = nil, freeBet: String? = nil) {
        self.ucsOperatorId = ucsOperatorId
        self.userId = userId
        self.username = username
        self.currency = currency
        self.type = type
        self.selections = selections
        self.amount = amount
        self.oddsValidationType = oddsValidationType
        self.terminalType = terminalType
        self.ubsWalletId = ubsWalletId
        self.freeBet = freeBet
    }
}

public struct BetSelectionInfo: Codable {
    public let bettingOfferId: String
    public let priceValue: Double
    
    public init(bettingOfferId: String, priceValue: Double) {
        self.bettingOfferId = bettingOfferId
        self.priceValue = priceValue
    }
}

 
