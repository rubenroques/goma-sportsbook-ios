//
//  EveryMatrixOddsMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation

enum EveryMatrixOddsMatrixAPI {
    case placeBet(betData: EveryMatrix.PlaceBetRequest)

    // MyBets API endpoints
    case getOpenBets(limit: Int, placedBefore: String)
    case getSettledBets(limit: Int, placedBefore: String, betStatus: String?)
    case calculateCashout(betId: String, stakeValue: String?)
    case cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?)

    // New Cashout API (SSE + execution)
    case getCashoutValueSSE(betId: String)
    case executeCashoutV2(request: EveryMatrix.NewCashoutRequest)
}

extension EveryMatrixOddsMatrixAPI: Endpoint {
    var url: String {
        return EveryMatrixUnifiedConfiguration.shared.oddsMatrixBaseURL
    }
    
    var endpoint: String {
        let domainId = EveryMatrixUnifiedConfiguration.shared.domainId
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
        case .getCashoutValueSSE(let betId):
            return "/cashout/v1/cashout-value/\(betId)"
        case .executeCashoutV2:
            return "/cashout/v1/cashout"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .placeBet, .cashoutBet, .getCashoutValueSSE, .executeCashoutV2:
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
        let domainId = EveryMatrixUnifiedConfiguration.shared.domainId
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
        case .getCashoutValueSSE:
            // SSE cashout value requires text/event-stream
            let headers = [
                "Accept": "text/event-stream",
                "X-OperatorId": domainId
            ]
            return headers
        case .executeCashoutV2:
            // New cashout execution API
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-OperatorId": domainId
            ]
            return headers
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixUnifiedConfiguration.shared.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .placeBet, .cashoutBet, .executeCashoutV2:
            return .post
        case .getOpenBets, .getSettledBets, .calculateCashout, .getCashoutValueSSE:
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
        case .executeCashoutV2(let request):
            return try? JSONEncoder().encode(request)
        case .getOpenBets, .getSettledBets, .calculateCashout, .getCashoutValueSSE:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixUnifiedConfiguration.shared.defaultTimeout
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .placeBet, .getOpenBets, .getSettledBets, .calculateCashout, .cashoutBet, .getCashoutValueSSE, .executeCashoutV2:
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
        case .getCashoutValueSSE, .executeCashoutV2:
            // New Cashout API uses capitalized headers
            switch type {
            case .sessionId:
                return "X-SessionId"   // Capitalized for new cashout API
            case .userId:
                return "userId"        // No x- prefix for new cashout API
            }
        }
    }
}

