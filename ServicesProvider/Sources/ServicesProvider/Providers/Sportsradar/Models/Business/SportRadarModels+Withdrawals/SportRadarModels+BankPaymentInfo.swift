//
//  SportRadarModels+BankPaymentInfo.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

extension SportRadarModels {
    struct BankPaymentInfo: Codable {

        var id: Int
        var partyId: Int
        var type: String
        var description: String?
        var details: [BankPaymentDetail]

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case partyId = "partyId"
            case type = "type"
            case description = "description"
            case details = "details"
        }
    }
}
