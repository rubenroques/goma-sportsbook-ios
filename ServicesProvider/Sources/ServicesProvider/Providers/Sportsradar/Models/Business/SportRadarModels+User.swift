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
        let message: String?
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
        let birthDepartment: String?

        let extraInfos: [ExtraInfo]?

        enum CodingKeys: String, CodingKey {
            case status = "status"

            case partyId = "partyId"
            case userId = "userId"
            case email = "email"

            case firstName = "firstName"
            case lastName = "lastName"
            case nickname = "nickname"
            case language = "language"
            case phone = "phone"
            case phoneCountryCode = "phoneCountryCode"
            case phoneLocalNumber = "phoneLocalNumber"
            case phoneNeedsReview = "phoneNeedsReview"
            case birthDate = "birthDate"
            case birthDateFormatted = "birthDateFormatted"
            case regDate = "regDate"
            case regDateFormatted = "regDateFormatted"
            case mobilePhone = "mobilePhone"
            case mobileCountryCode = "mobileCountryCode"
            case mobileLocalNumber = "mobileLocalNumber"
            case mobileNeedsReview = "mobileNeedsReview"
            case currency = "currency"
            case lastLogin = "lastLogin"
            case lastLoginFormatted = "lastLoginFormatted"
            case level = "level"
            case parentID = "parentID"
            case userType = "userType"
            case isAutopay = "isAutopay"
            case registrationStatus = "registrationStatus"
            case sessionKey = "sessionKey"

            case vipStatus = "vipStatus"
            case kycStatus = "kycStatus"
            case emailVerificationStatus = "emailVerificationStatus"
            case verificationStatus = "verificationStatus"
            case lockedStatus = "lockedStatus"

            case gender = "gender"
            case contactPreference = "contactPreference"
            case verificationMethod = "verificationMethod"
            case docNumber = "docNumber"
            case readonlyFields = "readonlyFields"

            case accountNumber = "accountNumber"
            case idCardNumber = "idCardNumber"
            case madeDeposit = "madeDeposit"
            case testPlayer = "testPlayer"

            case address = "address"
            case city = "city"
            case province = "province"
            case postalCode = "postalCode"
            case country = "country"
            case nationality = "nationality"
            case municipality = "municipality"
            case streetNumber = "streetNumber"
            case building = "building"
            case unit = "unit"
            case floorNumber = "floorNumber"
            case birthDepartment = "birthDepartment"

            case extraInfos = "extraInfo"
        }

        struct ExtraInfo: Codable {

            let key: String
            let value: String

            enum CodingKeys: String, CodingKey {
                case key
                case value
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.key = try container.decode(String.self, forKey: .key)
                self.value = try container.decode(String.self, forKey: .value)
            }
        }

        public init(status: String, partyId: String, userId: String, email: String, firstName: String?, lastName: String?, nickname: String?, language: String?, phone: String?, phoneCountryCode: String?, phoneLocalNumber: String?, phoneNeedsReview: Bool?, birthDate: String?, birthDateFormatted: Date, regDate: String?, regDateFormatted: Date?, mobilePhone: String?, mobileCountryCode: String?, mobileLocalNumber: String?, mobileNeedsReview: Bool?, currency: String?, lastLogin: String?, lastLoginFormatted: Date?, level: Int?, parentID: String?, userType: Int?, isAutopay: Bool?, registrationStatus: String?, sessionKey: String?, vipStatus: String?, kycStatus: String?, emailVerificationStatus: String, verificationStatus: String?, lockedStatus: String?, gender: String?, contactPreference: String?, verificationMethod: String?, docNumber: String?, readonlyFields: String?, accountNumber: String?, idCardNumber: String?, madeDeposit: Bool?, testPlayer: Bool?, address: String?, city: String?, province: String?, postalCode: String?, country: String?, nationality: String?, municipality: String?, streetNumber: String?, building: String?, unit: String?, floorNumber: String?, birthDepartment: String?) {

            self.status = status
            self.partyId = partyId
            self.userId = userId
            self.email = email
            self.firstName = firstName
            self.lastName = lastName
            self.nickname = nickname
            self.language = language
            self.phone = phone
            self.phoneCountryCode = phoneCountryCode
            self.phoneLocalNumber = phoneLocalNumber
            self.phoneNeedsReview = phoneNeedsReview
            self.birthDate = birthDate
            self.birthDateFormatted = birthDateFormatted
            self.regDate = regDate
            self.regDateFormatted = regDateFormatted
            self.mobilePhone = mobilePhone
            self.mobileCountryCode = mobileCountryCode
            self.mobileLocalNumber = mobileLocalNumber
            self.mobileNeedsReview = mobileNeedsReview
            self.currency = currency
            self.lastLogin = lastLogin
            self.lastLoginFormatted = lastLoginFormatted
            self.level = level
            self.parentID = parentID
            self.userType = userType
            self.isAutopay = isAutopay
            self.registrationStatus = registrationStatus
            self.sessionKey = sessionKey
            self.vipStatus = vipStatus
            self.kycStatus = kycStatus
            self.emailVerificationStatus = emailVerificationStatus
            self.verificationStatus = verificationStatus
            self.lockedStatus = lockedStatus
            self.gender = gender
            self.contactPreference = contactPreference
            self.verificationMethod = verificationMethod
            self.docNumber = docNumber
            self.readonlyFields = readonlyFields
            self.accountNumber = accountNumber
            self.idCardNumber = idCardNumber
            self.madeDeposit = madeDeposit
            self.testPlayer = testPlayer
            self.address = address
            self.city = city
            self.province = province
            self.postalCode = postalCode
            self.country = country
            self.nationality = nationality
            self.municipality = municipality
            self.streetNumber = streetNumber
            self.building = building
            self.unit = unit
            self.floorNumber = floorNumber
            self.birthDepartment = birthDepartment
            self.extraInfos = nil
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlayerInfoResponse.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            self.status = try container.decode(String.self, forKey: .status)
            self.partyId = try container.decode(String.self, forKey: .partyId)
            self.userId = try container.decode(String.self, forKey: .userId)
            self.email = try container.decode(String.self, forKey: .email)
            self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
            self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
            self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
            self.language = try container.decodeIfPresent(String.self, forKey: .language)
            self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
            self.phoneCountryCode = try container.decodeIfPresent(String.self, forKey: .phoneCountryCode)
            self.phoneLocalNumber = try container.decodeIfPresent(String.self, forKey: .phoneLocalNumber)
            self.phoneNeedsReview = try container.decodeIfPresent(Bool.self, forKey: .phoneNeedsReview)
            self.birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
            self.birthDateFormatted = try container.decode(Date.self, forKey: .birthDateFormatted)
            self.regDate = try container.decodeIfPresent(String.self, forKey: .regDate)
            self.regDateFormatted = try container.decodeIfPresent(Date.self, forKey: .regDateFormatted)
            self.mobilePhone = try container.decodeIfPresent(String.self, forKey: .mobilePhone)
            self.mobileCountryCode = try container.decodeIfPresent(String.self, forKey: .mobileCountryCode)
            self.mobileLocalNumber = try container.decodeIfPresent(String.self, forKey: .mobileLocalNumber)
            self.mobileNeedsReview = try container.decodeIfPresent(Bool.self, forKey: .mobileNeedsReview)
            self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
            self.lastLogin = try container.decodeIfPresent(String.self, forKey: .lastLogin)
            self.lastLoginFormatted = try container.decodeIfPresent(Date.self, forKey: .lastLoginFormatted)
            self.level = try container.decodeIfPresent(Int.self, forKey: .level)
            self.parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
            self.userType = try container.decodeIfPresent(Int.self, forKey: .userType)
            self.isAutopay = try container.decodeIfPresent(Bool.self, forKey: .isAutopay)
            self.registrationStatus = try container.decodeIfPresent(String.self, forKey: .registrationStatus)
            self.sessionKey = try container.decodeIfPresent(String.self, forKey: .sessionKey)
            self.vipStatus = try container.decodeIfPresent(String.self, forKey: .vipStatus)
            self.kycStatus = try container.decodeIfPresent(String.self, forKey: .kycStatus)
            self.emailVerificationStatus = try container.decode(String.self, forKey: .emailVerificationStatus)
            self.verificationStatus = try container.decodeIfPresent(String.self, forKey: .verificationStatus)
            self.lockedStatus = try container.decodeIfPresent(String.self, forKey: .lockedStatus)
            self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
            self.contactPreference = try container.decodeIfPresent(String.self, forKey: .contactPreference)
            self.verificationMethod = try container.decodeIfPresent(String.self, forKey: .verificationMethod)
            self.docNumber = try container.decodeIfPresent(String.self, forKey: .docNumber)
            self.readonlyFields = try container.decodeIfPresent(String.self, forKey: .readonlyFields)
            self.accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
            self.idCardNumber = try container.decodeIfPresent(String.self, forKey: .idCardNumber)
            self.madeDeposit = try container.decodeIfPresent(Bool.self, forKey: .madeDeposit)
            self.testPlayer = try container.decodeIfPresent(Bool.self, forKey: .testPlayer)
            self.address = try container.decodeIfPresent(String.self, forKey: .address)
            self.city = try container.decodeIfPresent(String.self, forKey: .city)
            self.province = try container.decodeIfPresent(String.self, forKey: .province)
            self.postalCode = try container.decodeIfPresent(String.self, forKey: .postalCode)
            self.country = try container.decodeIfPresent(String.self, forKey: .country)
            self.nationality = try container.decodeIfPresent(String.self, forKey: .nationality)
            self.municipality = try container.decodeIfPresent(String.self, forKey: .municipality)
            self.streetNumber = try container.decodeIfPresent(String.self, forKey: .streetNumber)
            self.building = try container.decodeIfPresent(String.self, forKey: .building)
            self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
            self.floorNumber = try container.decodeIfPresent(String.self, forKey: .floorNumber)
            self.birthDepartment = try container.decodeIfPresent(String.self, forKey: .birthDepartment)

            self.extraInfos = try? container.decodeIfPresent([ExtraInfo].self, forKey: .extraInfos)
        }

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

    struct CheckUsernameResponse: Codable {

        let errors: [CheckUsernameError]?
        let status: String
        let message: String?
        let additionalInfos: [CheckUsernameAdditionalInfo]?

        enum CodingKeys: String, CodingKey {
            case errors = "errors"
            case status = "status"
            case message = "message"
            case additionalInfos = "additionalInfo"
        }

        struct CheckUsernameAdditionalInfo: Codable {

            let key: String
            let value: String

            enum CodingKeys: String, CodingKey {
                case key
                case value
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.key = try container.decode(String.self, forKey: .key)
                self.value = try container.decode(String.self, forKey: .value)
            }
        }

        struct CheckUsernameError: Codable {

            let field: String
            let error: String

            enum CodingKeys: String, CodingKey {
                case field
                case error
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.field = try container.decode(String.self, forKey: .field)
                self.error = try container.decode(String.self, forKey: .error)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.errors = try container.decodeIfPresent([CheckUsernameError].self, forKey: .errors)
            self.status = try container.decode(String.self, forKey: .status)
            self.message = try container.decodeIfPresent(String.self, forKey: .message)

            self.additionalInfos = try? container.decodeIfPresent([CheckUsernameAdditionalInfo].self, forKey: .additionalInfos)
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
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
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
        var sessionData: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case paymentId = "paymentId"
            case continueUrl = "continueUrl"
            case clientKey = "clientKey"
            case sessionId = "sessionId"
            case sessionData = "sessionData"
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

    struct PersonalDepositLimitResponse: Codable {

        var status: String
        var dailyLimit: String?
        var weeklyLimit: String?
        var monthlyLimit: String?
        var currency: String
        var hasPendingWeeklyLimit: String?
        var pendingWeeklyLimit: String?
        var pendingWeeklyLimitEffectiveDate: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case dailyLimit = "dailyLimit"
            case weeklyLimit = "weeklyLimit"
            case monthlyLimit = "monthlyLimit"
            case currency = "currency"
            case hasPendingWeeklyLimit = "hasPendingWeeklyLimit"
            case pendingWeeklyLimit = "pendingWeeklyLimit"
            case pendingWeeklyLimitEffectiveDate = "pendingWeeklyLimitEffectiveDate"
        }
    }

    struct LimitsResponse: Codable {

        var status: String
        var wagerLimit: String?
        var lossLimit: String?
        var currency: String
        var pendingWagerLimit: LimitPending?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case wagerLimit = "wagerLimit"
            case lossLimit = "lossLimit"
            case currency = "currency"
            case pendingWagerLimit = "pendingWagerLimit"
        }
    }

    struct LimitPending: Codable {
        var effectiveDate: String
        var limit: String
        var limitNumber: Double

        enum CodingKeys: String, CodingKey {
            case effectiveDate = "effectiveDate"
            case limit = "limit"
            case limitNumber = "limitNumber"
        }
    }

    struct BasicResponse: Codable {
        var status: String
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
        }
    }

    struct SupportResponse: Codable {
        var request: SupportRequest?
        var error: String?
        var description: String?

        enum CodingKeys: String, CodingKey {
            case request = "request"
            case error = "error"
            case description = "description"
        }
    }

    struct SupportRequest: Codable {
        var id: Int
        var status: String

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case status = "status"
        }
    }

}
