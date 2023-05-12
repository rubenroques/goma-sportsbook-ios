//
//  SportRadarModels+UserConsentsResponse.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

extension SportRadarModels {

    struct UserConsentsResponse: Codable {
        var status: String
        var message: String?
        var userConsents: [UserConsent]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
            case userConsents = "userConsents"
        }

    }

}
