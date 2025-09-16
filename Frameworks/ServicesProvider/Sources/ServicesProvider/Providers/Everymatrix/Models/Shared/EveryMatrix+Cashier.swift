//
//  EveryMatrix+Cashier.swift
//  ServicesProvider
//
//  Created by Banking Implementation on 10/09/2025.
//

import Foundation

extension EveryMatrix {
    
    /// EveryMatrix GetPaymentSession API response (matches actual API structure)
    struct GetPaymentSessionResponse: Codable {
        let cashierInfo: CashierInfo
        let responseCode: String
        let requestId: String
        
        enum CodingKeys: String, CodingKey {
            case cashierInfo = "CashierInfo"
            case responseCode = "ResponseCode"
            case requestId = "RequestId"
        }
    }
    
    /// Nested cashier information (matches tested API response)
    struct CashierInfo: Codable {
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case url = "Url"
        }
    }
    
    /// EveryMatrix GetPaymentSession API request
    struct GetPaymentSessionRequest: Codable {
        let channel: String
        let type: String
        let successUrl: String
        let cancelUrl: String
        let failUrl: String
        let language: String
        let productType: String
        let currency: String
        let isShortCashier: Bool
        let bonusCode: String?
        let showBonusSelectionInput: Bool
        
        enum CodingKeys: String, CodingKey {
            case channel = "Channel"
            case type = "Type"
            case successUrl = "SuccessUrl"
            case cancelUrl = "CancelUrl"
            case failUrl = "FailUrl"
            case language = "Language"
            case productType
            case currency
            case isShortCashier
            case bonusCode
            case showBonusSelectionInput
        }
    }
}