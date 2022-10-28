//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {
    
    struct LoginResponse: Codable {
        let status: String
        let partyId: String?
        let username: String?
        let language: String?
        let currency: String?
        let email: String?
        let sessionKey: String?
        let parentId: String?
        let level: String?
        let userType: String?
        let isFirstLogin: String?
        let registrationStatus: String?
        let pendingLimitConfirmation: String?
        let country: String?
        let kycStatus: String?
        let lockStatus: String?
        let securityVerificationRequiredFields: [String]?
    }

    struct PlayerInfoResponse: Codable {
        let status: String
        
        let partyId: String
        let userId: String
        let email: String
        
        let firstName: String?
        let lastName: String?
        let nickname: String?
        let language: String?
        let phone: String?
        let phoneCountryCode: String?
        let phoneLocalNumber: String?
        let phoneNeedsReview: Bool?
        let birthDate: String?
        let birthDateFormatted: Date
        let regDate: String?
        let regDateFormatted: Date?
        let mobilePhone: String?
        let mobileCountryCode: String?
        let mobileLocalNumber: String?
        let mobileNeedsReview: Bool?
        let currency: String?
        let lastLogin: String?
        let lastLoginFormatted: Date?
        let level: Int?
        let parentID: String?
        let userType: Int?
        let isAutopay: Bool?
        let registrationStatus: String?
        let sessionKey: String?

        let vipStatus: String?
        let kycStatus: String?
        let emailVerificationStatus: String
        let verificationStatus: String?
        let lockedStatus: String?
        
        let gender: String?
        let contactPreference: String?
        let verificationMethod: String?
        let docNumber: String?
        let readonlyFields: String?
        
        let accountNumber: String?
        let idCardNumber: String?
        let madeDeposit: Bool?
        let testPlayer: Bool?
        
        let address: String?
        let city: String?
        let province: String?
        let postalCode: String?
        let country: String?
        let nationality: String?
        let municipality: String?
        let streetNumber: String?
        let building: String?
        let unit: String?
        let floorNumber: String?

    }
    
    public struct CheckCredentialResponse: Codable {
        public let status: String
        public let exists: String
        public let fieldExist: Bool

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case exists = "exists"
            case fieldExist = "fieldExist"
        }

        public init(status: String, exists: String, fieldExist: Bool) {
            self.status = status
            self.exists = exists
            self.fieldExist = fieldExist
        }
    }

    struct GetCountriesResponse: Codable {
        let status: String
        let countries: [String]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case countries = "countries"
        }
    }
    
    struct GetCountryInfoResponse: Codable {
        let status: String
        let countryInfo: CountryInfo

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case countryInfo = "countryInfo"
        }
    }

    // MARK: - CountryInfo
    struct CountryInfo: Codable {
        let name: String
        let iso2Code: String
        let phonePrefix: String

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case iso2Code = "iso2Code"
            case phonePrefix = "phonePrefix"
        }
    }

}

extension SportRadarModels {
    
    struct StatusResponse: Codable {
        let status: String
        let errors: [FieldError]?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case errors = "errors"
        }
    }

    struct FieldError: Codable {
        let field: String
        let error: String

        enum CodingKeys: String, CodingKey {
            case field = "field"
            case error = "error"
        }
    }
}
