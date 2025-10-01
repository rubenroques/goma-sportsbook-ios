//
//  EveryMatrix+RecommendationResponse.swift
//
//  Shared models for RecSys recommendations response within the EveryMatrix namespace.
//

import Foundation

extension EveryMatrix {
    struct RecommendationResponse: Codable {
        let isLive: Bool
        let userId: Int
        let domainId: Int
        let utmContent: String?
        let terminalType: Int
        let expirationDate: String
        let generationDate: String
        let recommendationsList: [RecommendedEvent]

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

    struct RecommendedEvent: Codable {
        let eventId: String
        let interestScore: Double
        let expirationDate: String
        let betsRecommendationsList: [RecommendedBet]

        enum CodingKeys: String, CodingKey {
            case eventId
            case interestScore
            case expirationDate
            case betsRecommendationsList = "BetsRecommendationsList"
        }
    }

    struct RecommendedBet: Codable {
        let marketId: String
        let bettingTypeId: Int
        let eventPartId: Int
        let interestScore: Double
    }
}


