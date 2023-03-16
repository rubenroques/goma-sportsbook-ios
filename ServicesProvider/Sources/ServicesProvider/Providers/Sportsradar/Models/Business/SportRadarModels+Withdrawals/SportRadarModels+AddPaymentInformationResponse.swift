//
//  SportRadarModels+AddPaymentInformationResponse.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

extension SportRadarModels {

    struct AddPaymentInformationResponse: Codable {
        var status: String
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
        }
    }
}
