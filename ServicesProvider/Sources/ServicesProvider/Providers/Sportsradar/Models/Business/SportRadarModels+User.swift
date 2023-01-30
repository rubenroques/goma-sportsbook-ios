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

    struct OpenSessionResponse: Codable {
        let status: String
        let launchToken: String
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
    
    struct BalanceResponse: Codable {
        let status: String
        let message: String?
        let currency: String?
        let loyaltyPoint: Int?
        let vipStatus: String?
        
        let totalBalance: String?
        let totalBalanceNumber: Double?
        let withdrawableBalance: String?
        let withdrawableBalanceNumber: Double?
        let bonusBalance: String?
        let bonusBalanceNumber: Double?
        let pendingBonusBalance: String?
        let pendingBonusBalanceNumber: Double?
        let casinoPlayableBonusBalance: String?
        let casinoPlayableBonusBalanceNumber: Double?
        let sportsbookPlayableBonusBalance: String?
        let sportsbookPlayableBonusBalanceNumber: Double?
        let withdrawableEscrowBalance: String?
        let withdrawableEscrowBalanceNumber: Double?
        let totalWithdrawableBalance: String?
        let totalWithdrawableBalanceNumber: Double?
        let withdrawRestrictionAmount: String?
        let withdrawRestrictionAmountNumber: Double?
        let totalEscrowBalance: String?
        let totalEscrowBalanceNumber: Double?
    }

}

extension SportRadarModels {
    
    struct StatusResponse: Codable {
        let status: String
        let errors: [FieldError]?
        let message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case errors = "errors"
            case message = "message"
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

extension SportRadarModels {

    struct DocumentTypesResponse: Codable {
        var status: String
        var documentTypes: [DocumentType]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case documentTypes = "documentTypes"
        }
    }

    struct DocumentType: Codable {
        var documentType: String
        var issueDateRequired: Bool?
        var expiryDateRequired: Bool?
        var documentNumberRequired: Bool?

        enum CodingKeys: String, CodingKey {
            case documentType = "documentType"
            case expiryDateRequired = "expiryDateRequired"
            case documentNumberRequired = "documentNumberRequired"
            case issueDateRequired = "issueDateRequired"
        }
    }

    struct UserDocumentsResponse: Codable {
        var status: String
        var userDocuments: [UserDocument]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case userDocuments = "userDocuments"
        }
    }

    struct UserDocument: Codable {
        var documentType: String
        var fileName: String
        var status: String

        enum CodingKeys: String, CodingKey {
            case documentType = "documentType"
            case fileName = "fileName"
            case status = "status"
        }
    }

    struct UploadDocumentResponse: Codable {
        var status: String

        enum CodingKeys: String, CodingKey {
            case status = "status"
        }
    }

    struct PaymentsResponse: Codable {
        var status: String
        var depositMethods: [DepositMethod]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case depositMethods = "depositMethods"
        }
    }

    struct DepositMethod: Codable {
        var code: String
        var paymentMethod: String
        var methods: [PaymentMethod]?

        enum CodingKeys: String, CodingKey {
            case code = "code"
            case paymentMethod = "paymentMethod"
            case methods = "methods"
        }
    }

    struct PaymentMethod: Codable {
        var name: String
        var type: String
        var brands: [String]?

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case type = "type"
            case brands = "brands"
        }
    }
    struct ProcessDepositResponse: Codable {
        var status: String
        var paymentId: String?
        var continueUrl: String?
        var clientKey: String?
        var sessionId: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case paymentId = "paymentId"
            case continueUrl = "continueUrl"
            case clientKey = "clientKey"
            case sessionId = "sessionId"
            case message = "message"
        }
    }

    struct UpdatePaymentResponse: Codable {
        var resultCode: String
        var action: UpdatePaymentAction

        enum CodingKeys: String, CodingKey {
            case resultCode = "resultCode"
            case action = "action"
        }
    }

    struct UpdatePaymentAction: Codable {
        var paymentMethodType: String
        var url: String
        var method: String
        var type: String

        enum CodingKeys: String, CodingKey {
            case paymentMethodType = "paymentMethodType"
            case url = "url"
            case method = "method"
            case type = "type"
        }
    }
}
