//
//  EveryMatrix+EveryMatrixAPIError.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/07/2025.
//

import Foundation

extension EveryMatrix {
    
    struct EveryMatrixAPIError: Decodable {
        let error: String?
        let success: Bool?
        let errorCode: Int?
        let errorSourceName: String?
        let thirdPartyResponse: ThirdPartyResponse?
        let nwaTraceId: String?
        let response: BetslipErrorResponse?
        
        struct ThirdPartyResponse: Decodable {
            let errorCode: String?
            let message: String?
            let correlationId: String?
            let errors: [String: String]?
        }
        
        struct BetslipErrorResponse: Decodable {
            let errorCode: String?
            let errorMessage: String?
            
            var message: String? {
                switch errorCode {
                case "106":
                    "no_funds"
                case "121":
                    "bet_error_wager_limit"
                default:
                    errorMessage
                }
            }
        }
    }
}
