//
//  EveryMatrixOddsMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation

enum EveryMatrixOddsMatrixAPI {
    case placeBet(betData: PlaceBetRequest)
}

extension EveryMatrixOddsMatrixAPI: Endpoint {
    var url: String {
        switch self {
        default:
            return EveryMatrixOddsMatrixConfiguration.default.environment.baseURL
        }
    }
    
    var endpoint: String {
        switch self {
        case .placeBet:
            return "/place-bet/\(EveryMatrixOddsMatrixAPIEnvironment.staging.domainId)/v2/bets"
        }
    }
    
    var query: [URLQueryItem]? {
        return nil
    }
    
    var headers: HTTP.Headers? {
        switch self {
        case .placeBet:
            let headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
//                "User-Agent": "GOMA/native-app/iOS",
                "X-OperatorId": "\(EveryMatrixOddsMatrixAPIEnvironment.staging.domainId)"
            ]
            return headers
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixOddsMatrixConfiguration.default.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .placeBet:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .placeBet(let betData):
            return try? JSONEncoder().encode(betData)
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixOddsMatrixConfiguration.default.defaultTimeout
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .placeBet:
            return true
        }
    }
    
    var comment: String? {
        return nil
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
