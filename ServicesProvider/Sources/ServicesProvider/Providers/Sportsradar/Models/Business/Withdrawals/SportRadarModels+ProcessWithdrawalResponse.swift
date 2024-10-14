//
//  SportRadarModels+ProcessWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 27/02/2023.
//

import Foundation

extension SportRadarModels {

    struct ProcessWithdrawalResponse: Codable {

        var status: String
        var paymentId: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case paymentId = "paymentId"
            case message = "message"
        }
    }
    
    struct PrepareWithdrawalResponse: Codable {

        var status: String
        var conversionId: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case conversionId = "conversionId"
            case message = "message"
        }
    }

}
