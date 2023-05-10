//
//  SportRadarModels+UserConsentInfo.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

extension SportRadarModels {

    struct UserConsentInfo: Codable {

        var id: Int
        var key: String
        var name: String
        var consentVersionId: Int

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case key = "key"
            case name = "name"
            case consentVersionId = "consentVersionId"
        }
    }

}
