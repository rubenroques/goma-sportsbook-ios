//
//  User.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import SharedModels

public enum KnowYourClientStatus: String, Codable {
    case open
    case requested
    case failed
    case completed
}

public enum UserVerificationStatus: String, Codable {
    case verified
    case unverified
}

public enum EmailVerificationStatus: String, Codable {
    case verified
    case unverified
}

public enum UserRegistrationStatus: String, Codable {
    case completed
    case quickOpen
    case quickRegister
}

public enum KnowYourCustomerStatus: String, Codable {
    case request
    case passConditional
    case pass
}

public struct UserOverview: Codable {
    
    public let sessionKey: String
    public let username: String
    public let email: String
    
    public let partyID: String?
    public let language: String?
    public let currency: String?
    public let parentID: String?
    
    public let level: String?
    public let userType: String?
    public let isFirstLogin: String?
    public let registrationStatus: String?
    public let country: String?
    public let kycStatus: String?
    public let lockStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case sessionKey = "sessionKey"
        case username = "username"
        case email = "email"
        case partyID = "partyId"
        case language = "language"
        case currency = "currency"
        case parentID = "parentId"
        case level = "level"
        case userType = "userType"
        case isFirstLogin = "isFirstLogin"
        case registrationStatus = "registrationStatus"
        case country = "country"
        case kycStatus = "kycStatus"
        case lockStatus = "lockStatus"
    }
    
}

public struct UserProfile: Codable {
    
    public let userIdentifier: String
    public let username: String
    public let email: String
    public let firstName: String?
    public let lastName: String?
    public let birthDate: Date
    public let gender: String?
    public let nationalityCode: String?
    public let countryCode: String?
    public let personalIdNumber: String?
    public let address: String?
    public let province: String?
    public let city: String?
    public let postalCode: String?
    public let birthDepartment: String?
    public let streetNumber: String?

    public let avatarName: String?
    public let godfatherCode: String?
    public let placeOfBirth: String?
    public let additionalStreetLine: String?

    public let emailVerificationStatus: EmailVerificationStatus
    public let userRegistrationStatus: UserRegistrationStatus
    public let kycStatus: KnowYourCustomerStatus
    
    public init(userIdentifier: String,
                username: String,
                email: String,
                firstName: String?,
                lastName: String?,
                birthDate: Date,
                gender: String?,
                nationalityCode: String?,
                countryCode: String?,
                personalIdNumber: String?,
                address: String?,
                province: String?,
                city: String?,
                postalCode: String?,
                birthDepartment: String?,
                streetNumber: String?,
                avatarName: String?,
                godfatherCode: String?,
                placeOfBirth: String?,
                additionalStreetLine: String?,
                emailVerificationStatus: EmailVerificationStatus,
                userRegistrationStatus: UserRegistrationStatus,
                kycStatus: KnowYourCustomerStatus) {
        
        self.userIdentifier = userIdentifier
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.nationalityCode = nationalityCode
        self.countryCode = countryCode
        self.personalIdNumber = personalIdNumber
        self.address = address
        self.province = province
        self.city = city
        self.postalCode = postalCode
        self.birthDepartment = birthDepartment
        self.streetNumber = streetNumber

        self.avatarName = avatarName
        self.godfatherCode = godfatherCode
        self.placeOfBirth = placeOfBirth
        self.additionalStreetLine = additionalStreetLine

        self.emailVerificationStatus = emailVerificationStatus
        self.userRegistrationStatus = userRegistrationStatus
        self.kycStatus = kycStatus
    }

}

public extension UserProfile {
    var isEmailVerified: Bool {
        return self.emailVerificationStatus == .verified
    }
    var isRegistrationCompleted: Bool {
        return self.userRegistrationStatus == .completed
    }
    var nationalityCountry: Country? {
        if let nationalityCode = self.nationalityCode {
            return Country.init(isoCode: nationalityCode)
        }
        return nil
    }
    var country: Country? {
        if let countryCode = self.countryCode {
            return Country.init(isoCode: countryCode)
        }
        return nil
    }
}

public struct SimpleSignUpForm {
    public var email: String
    public var username: String
    public var password: String
    public var birthDate: Date
    public var mobilePrefix: String
    public var mobileNumber: String
    public var countryIsoCode: String
    public var currencyCode: String

    public init(email: String, username: String, password: String, birthDate: Date, mobilePrefix: String, mobileNumber: String, countryIsoCode: String, currencyCode: String) {
        self.email = email
        self.username = username
        self.password = password
        self.birthDate = birthDate
        self.mobilePrefix = mobilePrefix
        self.mobileNumber = mobileNumber
        self.countryIsoCode = countryIsoCode
        self.currencyCode = currencyCode
    }

}

public class SignUpForm {

    public var email: String
    public var username: String
    public var password: String
    public var birthDate: Date
    public var mobilePrefix: String
    public var mobileNumber: String
    public var nationalityIsoCode: String
    public var currencyCode: String

    public var firstName: String
    public var lastName: String

    public var gender: String
    public var address: String

    public var city: String
    public var postCode: String
    public var countryIsoCode: String

    public var birthDepartment: String
    public var streetNumber: String
    public var birthCountry: String
    public var birthCity: String

    public var bonusCode: String?
    public var receiveMarketingEmails: Bool?

    public var avatarName: String?
    public var additionalStreetAddress: String?
    public var godfatherCode: String?

    public init(email: String, username: String, password: String, birthDate: Date,
                mobilePrefix: String, mobileNumber: String, nationalityIsoCode: String,
                currencyCode: String, firstName: String, lastName: String,
                gender: String, address: String, city: String,
                countryIsoCode: String, bonusCode: String? = nil,
                receiveMarketingEmails: Bool? = nil, avatarName: String? = nil,
                godfatherCode: String? = nil, postCode: String,
                birthDepartment: String, streetNumber: String,
                birthCountry: String, birthCity: String) {

        self.email = email
        self.username = username
        self.password = password
        self.birthDate = birthDate
        self.mobilePrefix = mobilePrefix
        self.mobileNumber = mobileNumber
        self.nationalityIsoCode = nationalityIsoCode
        self.currencyCode = currencyCode
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.address = address
        self.city = city
        self.countryIsoCode = countryIsoCode
        self.bonusCode = bonusCode
        self.receiveMarketingEmails = receiveMarketingEmails
        self.avatarName = avatarName
        self.godfatherCode = godfatherCode
        self.postCode = postCode
        self.birthDepartment = birthDepartment
        self.streetNumber = streetNumber
        self.birthCountry = birthCountry
        self.birthCity = birthCity
        
    }

}

public struct SignUpResponse {

    public struct SignUpError {
        public var field: String
        public var error: String
    }

    public var successful: Bool
    public var errors: [SignUpError]?

    public init(successful: Bool, errors: [SignUpError]? = nil) {
        self.successful = successful
        self.errors = errors
    }
    
}

public struct UpdateUserProfileForm {
    
    public var username: String?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var birthDate: Date?
    public var gender: String?
    public var address: String?
    public var province: String?
    public var city: String?
    public var postalCode: String?
    public var country: Country?
    public var cardId: String?
    
    public var mobileNumber: String?
    public var securityQuestion: String?
    public var securityAnswer: String?
    
    public init(username: String? = nil, email: String? = nil, firstName: String? = nil,
                lastName: String? = nil, birthDate: Date? = nil, gender: String? = nil,
                address: String? = nil, province: String? = nil, city: String? = nil,
                postalCode: String? = nil, country: Country? = nil, cardId: String? = nil,
                mobileNumber: String? = nil, securityQuestion: String? = nil, securityAnswer: String? = nil) {
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.address = address
        self.province = province
        self.city = city
        self.postalCode = postalCode
        self.country = country
        self.cardId = cardId
        self.mobileNumber = mobileNumber
        self.securityQuestion = securityQuestion
        self.securityAnswer = securityAnswer
    }
    
}

public struct UserWallet {
    public var vipStatus: String?
    public var currency: String?
    public var loyaltyPoint: Int?
    
    public var totalString: String?
    public var total: Double?
    public var withdrawableString: String?
    public var withdrawable: Double?
    public var bonusString: String?
    public var bonus: Double?
    public var pendingBonusString: String?
    public var pendingBonus: Double?
    public var casinoPlayableBonusString: String?
    public var casinoPlayableBonus: Double?
    public var sportsbookPlayableBonusString: String?
    public var sportsbookPlayableBonus: Double?
    public var withdrawableEscrowString: String?
    public var withdrawableEscrow: Double?
    public var totalWithdrawableString: String?
    public var totalWithdrawable: Double?
    public var withdrawRestrictionAmountString: String?
    public var withdrawRestrictionAmount: Double?
    public var totalEscrowString: String?
    public var totalEscrow: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalString = "totalBalance"
        case total = "totalBalanceNumber"
        case withdrawableString = "withdrawableBalance"
        case withdrawable = "withdrawableBalanceNumber"
        case bonusString = "bonusBalance"
        case bonus = "bonusBalanceNumber"
        case pendingBonusString = "pendingBonusBalance"
        case pendingBonus = "pendingBonusBalanceNumber"
        case casinoPlayableBonusString = "casinoPlayableBonusBalance"
        case casinoPlayableBonus = "casinoPlayableBonusBalanceNumber"
        case sportsbookPlayableBonusString = "sportsbookPlayableBonusBalance"
        case sportsbookPlayableBonus = "sportsbookPlayableBonusBalanceNumber"
        case withdrawableEscrowString = "withdrawableEscrowBalance"
        case withdrawableEscrow = "withdrawableEscrowBalanceNumber"
        case totalWithdrawableString = "totalWithdrawableBalance"
        case totalWithdrawable = "totalWithdrawableBalanceNumber"
        case withdrawRestrictionAmountString = "withdrawRestrictionAmount"
        case withdrawRestrictionAmount = "withdrawRestrictionAmountNumber"
        case totalEscrowString = "totalEscrowBalance"
        case totalEscrow = "totalEscrowBalanceNumber"
        case currency = "currency"
        case loyaltyPoint = "loyaltyPoint"
        case vipStatus = "vipStatus"
    }
    
    
}

public struct UsernameValidation {
    public var username: String
    public var isAvailable: Bool
    public var suggestedUsernames: [String]?
    public var hasErrors: Bool
}

public struct DocumentTypesResponse {
    public var status: String
    public var documentTypes: [DocumentType]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case documentTypes = "documentTypes"
    }
}

public struct DocumentType {
    public var documentType: String
    public var issueDateRequired: Bool?
    public var expiryDateRequired: Bool?
    public var documentNumberRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case documentType = "documentType"
        case expiryDateRequired = "expiryDateRequired"
        case documentNumberRequired = "documentNumberRequired"
        case issueDateRequired = "issueDateRequired"
    }
}

public struct UserDocumentsResponse {
    public var status: String
    public var userDocuments: [UserDocument]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case documentTypes = "userDocuments"
    }
}

public struct UserDocument {
    public var documentType: String
    public var fileName: String
    public var status: String

    enum CodingKeys: String, CodingKey {
        case documentType = "documentType"
        case fileName = "fileName"
        case status = "status"
    }
}

public struct UploadDocumentResponse {
    public var status: String
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
}

public struct PaymentsResponse: Codable {
    public var status: String
    public var depositMethods: [DepositMethod]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case depositMethods = "depositMethods"
    }
}

public struct DepositMethod: Codable {
    public var code: String
    public var paymentMethod: String
    public var methods: [PaymentMethod]?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case paymentMethod = "paymentMethod"
        case methods = "methods"
    }
}

public struct PaymentMethod: Codable {
    public var name: String
    public var type: String
    public var brands: [String]?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
        case brands = "brands"
    }
}

public struct SimplePaymentMethodsResponse: Codable {

    public var paymentMethods: [SimplePaymentMethod]

}

public struct SimplePaymentMethod: Codable {
    public var name: String
    public var type: String
}

public struct ProcessDepositResponse: Codable {
    public var status: String
    public var paymentId: String?
    public var continueUrl: String?
    public var clientKey: String?
    public var sessionId: String?
    public var sessionData: String?
    public var message: String?

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

public struct UpdatePaymentResponse: Codable {
    public var resultCode: String
    public var action: UpdatePaymentAction

    enum CodingKeys: String, CodingKey {
        case resultCode = "resultCode"
        case action = "action"
    }
}

public struct UpdatePaymentAction: Codable {
    public var paymentMethodType: String
    public var url: String
    public var method: String
    public var type: String

    enum CodingKeys: String, CodingKey {
        case paymentMethodType = "paymentMethodType"
        case url = "url"
        case method = "method"
        case type = "type"
    }
}

public struct PersonalDepositLimitResponse: Codable {

    public var status: String
    public var dailyLimit: String?
    public var weeklyLimit: String?
    public var monthlyLimit: String?
    public var currency: String
    public var hasPendingWeeklyLimit: String?
    public var pendingWeeklyLimit: String?
    public var pendingWeeklyLimitEffectiveDate: String?

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

public struct LimitsResponse: Codable {

    public var status: String
    public var wagerLimit: String?
    public var lossLimit: String?
    public var currency: String
    public var pendingWagerLimit: LimitPending?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case wagerLimit = "wagerLimit"
        case lossLimit = "lossLimit"
        case currency = "currency"
        case pendingWagerLimit = "pendingWagerLimit"
    }
}

public struct LimitPending: Codable {
    public var effectiveDate: String
    public var limit: String
    public var limitNumber: Double

    enum CodingKeys: String, CodingKey {
        case effectiveDate = "effectiveDate"
        case limit = "limit"
        case limitNumber = "limitNumber"
    }
}

public struct Limit {
    public var updatable: Bool
    public var current: LimitInfo?
    public var queued: LimitInfo?

    public init(updatable: Bool, current: LimitInfo?, queued: LimitInfo?) {
        self.updatable = updatable
        self.current = current
        self.queued = queued
    }
}

public struct LimitInfo {
    public var period: String
    public var currency: String
    public var amount: Double
    public var expiryDate: String?

    public init(period: String, currency: String, amount: Double, expiryDate: String? = nil) {
        self.period = period
        self.currency = currency
        self.amount = amount
        self.expiryDate = expiryDate
    }
}

public struct BasicResponse: Codable {
    public var status: String
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
}

public struct PasswordPolicy {
    public var regularExpression: String?
    public var message: String

    public init(regularExpression: String? = nil, message: String) {
        self.regularExpression = regularExpression
        self.message = message
    }
}
