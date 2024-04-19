//
//  SportRadarModels+UserConsentsResponse.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

extension SportRadarModels {

    // MARK: - ConsentsResponse
    struct ConsentsResponse: Codable {
        let status: String
        let consents: [Consent]
    }

    // MARK: - Consent
    struct Consent: Codable {
        let id: Int
        let key: String
        let name: String
        let consentVersionId: Int
        
        let status: String?
        let isMandatory: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case key = "key"
            case name = "name"
            case consentVersionId = "consentVersionId"
            case status = "consentStatus"
            case isMandatory = "isMandatory"
        }
    }

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
