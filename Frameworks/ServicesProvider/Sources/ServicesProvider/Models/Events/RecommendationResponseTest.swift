//
//  RecommendationResponseTest.swift
//  ServicesProvider
//
//  Test file to verify recommendation response models work correctly
//

import Foundation

#if DEBUG
/// Test helper to verify recommendation response models
struct RecommendationResponseTest {
    
    /// Test JSON string matching the API response format
    static let testJSON = """
    {
        "is_live": false,
        "user_id": 7005274,
        "domain_id": 4093,
        "utm_content": "om_recsys_stage_2_test",
        "terminal_type": 1,
        "expiration_date": "2025-09-23 15:42:57.821360",
        "generation_date": "2025-09-23 15:35:57.821360",
        "recommendations_list": [
            {
                "eventId": "281345496272998400",
                "interestScore": 1.0,
                "expirationDate": "2025-09-23 15:42:57.821360",
                "BetsRecommendationsList": [
                    {
                        "marketId": "281345496452231168",
                        "bettingTypeId": 69,
                        "eventPartId": 3,
                        "interestScore": 1.0
                    },
                    {
                        "marketId": "281346043427221504",
                        "bettingTypeId": 693,
                        "eventPartId": 3,
                        "interestScore": 0.9636
                    }
                ]
            }
        ]
    }
    """
    
    /// Test that the models can decode the JSON response correctly
    static func testDecoding() -> Bool {
        guard let jsonData = testJSON.data(using: .utf8) else {
            print("❌ Failed to convert test JSON to data")
            return false
        }
        
        do {
            let response = try JSONDecoder().decode(RecommendationResponse.self, from: jsonData)
            
            // Verify main response properties
            guard response.isLive == false else {
                print("❌ isLive property not decoded correctly")
                return false
            }
            
            guard response.userId == 7005274 else {
                print("❌ userId property not decoded correctly")
                return false
            }
            
            guard response.domainId == 4093 else {
                print("❌ domainId property not decoded correctly")
                return false
            }
            
            guard response.recommendationsList.count == 1 else {
                print("❌ recommendationsList count not decoded correctly")
                return false
            }
            
            // Verify first recommendation
            let firstRecommendation = response.recommendationsList[0]
            guard firstRecommendation.eventId == "281345496272998400" else {
                print("❌ eventId not decoded correctly")
                return false
            }
            
            guard firstRecommendation.interestScore == 1.0 else {
                print("❌ interestScore not decoded correctly")
                return false
            }
            
            guard firstRecommendation.betsRecommendationsList.count == 2 else {
                print("❌ betsRecommendationsList count not decoded correctly")
                return false
            }
            
            // Verify first bet recommendation
            let firstBet = firstRecommendation.betsRecommendationsList[0]
            guard firstBet.marketId == "281345496452231168" else {
                print("❌ marketId not decoded correctly")
                return false
            }
            
            guard firstBet.bettingTypeId == 69 else {
                print("❌ bettingTypeId not decoded correctly")
                return false
            }
            
            print("✅ RecommendationResponse models decode correctly!")
            return true
            
        } catch {
            print("❌ Failed to decode RecommendationResponse: \(error)")
            return false
        }
    }
}
#endif
