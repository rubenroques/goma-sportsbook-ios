//
//  RecommendationResponse.swift
//  ServicesProvider
//
//  Created for handling recommendation API responses
//

import Foundation

/// Response model for the recommendation API endpoint
public struct RecommendationResponse: Codable {
    public let isLive: Bool
    public let userId: Int
    public let domainId: Int
    public let utmContent: String
    public let terminalType: Int
    public let expirationDate: String
    public let generationDate: String
    public let recommendationsList: [MatchRecommendation]
    
    enum CodingKeys: String, CodingKey {
        case isLive = "is_live"
        case userId = "user_id"
        case domainId = "domain_id"
        case utmContent = "utm_content"
        case terminalType = "terminal_type"
        case expirationDate = "expiration_date"
        case generationDate = "generation_date"
        case recommendationsList = "recommendations_list"
    }
}

/// Individual match recommendation with betting suggestions
public struct MatchRecommendation: Codable {
    public let eventId: String
    public let interestScore: Double
    public let expirationDate: String
    public let betsRecommendationsList: [BetRecommendation]
    
    enum CodingKeys: String, CodingKey {
        case eventId = "eventId"
        case interestScore = "interestScore"
        case expirationDate = "expirationDate"
        case betsRecommendationsList = "BetsRecommendationsList"
    }
}

/// Individual bet recommendation for a specific market
public struct BetRecommendation: Codable {
    public let marketId: String
    public let bettingTypeId: Int
    public let eventPartId: Int
    public let interestScore: Double
    
    enum CodingKeys: String, CodingKey {
        case marketId = "marketId"
        case bettingTypeId = "bettingTypeId"
        case eventPartId = "eventPartId"
        case interestScore = "interestScore"
    }
}
