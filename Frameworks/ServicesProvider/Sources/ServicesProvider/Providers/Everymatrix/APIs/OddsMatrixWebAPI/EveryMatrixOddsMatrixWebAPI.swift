
import Foundation

enum EveryMatrixOddsMatrixWebAPI {
    
    case placeBet(betData: EveryMatrix.PlaceBetRequest)
    
    // MyBets API endpoints
    case getOpenBets(limit: Int, placedBefore: String)
    case getSettledBets(limit: Int, placedBefore: String, betStatus: String?)
    case calculateCashout(betId: String, stakeValue: String?)
    
    // New Cashout API (SSE + execution)
    case getCashoutValueSSE(betIds: [String])
    case executeCashoutV2(request: EveryMatrix.CashoutRequest)
    
    // Favorites
    case getFavorites(userId: String)
    case addFavorite(userId: String, eventId: String)
    case removeFavorite(userId: String, eventId: String)
}

extension EveryMatrixOddsMatrixWebAPI: Endpoint {
    var url: String {
        return EveryMatrixUnifiedConfiguration.shared.oddsMatrixBaseURL
    }
    
    var endpoint: String {
        let domainId = EveryMatrixUnifiedConfiguration.shared.operatorId
        switch self {
        case .placeBet:
            return "/place-bet/\(domainId)/v2/bets"
        case .getOpenBets:
            return "/bets-api/v1/\(domainId)/open-bets"
        case .getSettledBets:
            return "/bets-api/v1/\(domainId)/settled-bets"
        case .calculateCashout:
            return "/bets-api/v1/\(domainId)/cashout-amount"
        case .getCashoutValueSSE:
            return "/bets-api/v1/\(domainId)/cashout-value-updates"
        case .executeCashoutV2:
            return "/cashout/v1/cashout"
            
        case .getFavorites(let userId):
            return "/user-data-service/v1/favorite/events/\(domainId)/\(userId)"
        case .addFavorite:
            return "/user-data-service/v1/favorite/events"
        case .removeFavorite:
            return "/user-data-service/v1/favorite/events"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .placeBet, .getCashoutValueSSE, .executeCashoutV2, .getFavorites, .addFavorite, .removeFavorite:
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
        let operatorId = EveryMatrixUnifiedConfiguration.shared.operatorId
        switch self {
        case .placeBet, .getFavorites, .addFavorite, .removeFavorite:
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-operatorid": operatorId
            ]
            return headers
        case .getOpenBets, .getSettledBets, .calculateCashout:
            // MyBets API requires EveryMatrix session headers
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-operator-id": operatorId,
                "x-language": EveryMatrixUnifiedConfiguration.shared.defaultLanguage
            ]
            return headers
        case .getCashoutValueSSE:
            // SSE cashout value requires text/event-stream with POST body
            let headers = [
                "Content-Type": "application/json",
                "Accept": "text/event-stream",
                "x-operator-id": operatorId,
                "x-language": EveryMatrixUnifiedConfiguration.shared.defaultLanguage
            ]
            return headers
        case .executeCashoutV2:
            // New cashout execution API
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-OperatorId": operatorId
            ]
            return headers
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixUnifiedConfiguration.shared.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .placeBet, .executeCashoutV2, .addFavorite, .getCashoutValueSSE:
            return .post
        case .getOpenBets, .getSettledBets, .calculateCashout, .getFavorites:
            return .get
        case .removeFavorite:
            return .delete
        }
    }
    
    var body: Data? {
        switch self {
        case .placeBet(let betData):
            return try? JSONEncoder().encode(betData)
        case .executeCashoutV2(let request):
            return try? JSONEncoder().encode(request)
        case .addFavorite(let userId, let eventId):
            let body = """
                       {
                        "operatorId": "\(EveryMatrixUnifiedConfiguration.shared.operatorId)",
                        "userId": "\(userId)",
                        "favoriteEvents": \([eventId])
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .removeFavorite(let userId, let eventId):
            let body = """
                       {
                        "operatorId": "\(EveryMatrixUnifiedConfiguration.shared.operatorId)",
                        "userId": "\(userId)",
                        "favoriteEvents": \([eventId])
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .getCashoutValueSSE(let betIds):
            struct CashoutValueRequest: Encodable { let betIds: [String] }
            return try? JSONEncoder().encode(CashoutValueRequest(betIds: betIds))
        case .getOpenBets, .getSettledBets, .calculateCashout, .getFavorites:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixUnifiedConfiguration.shared.defaultTimeout
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .placeBet, .getOpenBets, .getSettledBets, .calculateCashout, .getCashoutValueSSE, .executeCashoutV2, .getFavorites, .addFavorite, .removeFavorite:
            return true
        }
    }
    
    var comment: String? {
        return nil
    }
    
    func authHeaderKey(for type: AuthHeaderType) -> String? {
        switch self {
        case .placeBet, .getFavorites, .addFavorite, .removeFavorite:
            // Place bet uses different header format
            switch type {
            case .sessionId:
                return "x-sessionid"  // No hyphen for place bet
            case .userId:
                return "userid"  // User ID header for place bet
            }
        case .getOpenBets, .getSettledBets, .calculateCashout:
            // MyBets APIs use standard format
            switch type {
            case .sessionId:
                return "x-session-id"  // With hyphen for MyBets APIs
            case .userId:
                return "x-user-id"     // MyBets APIs need user ID
            }
        case .getCashoutValueSSE:
            // SSE Cashout API uses lowercase hyphenated headers (same as bets-api)
            switch type {
            case .sessionId:
                return "x-session-id"
            case .userId:
                return "x-user-id"
            }
        case .executeCashoutV2:
            // Cashout execution API uses capitalized headers
            switch type {
            case .sessionId:
                return "X-SessionId"
            case .userId:
                return "userId"
            }
        }
    }
}

