//
//  User.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation

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
    
    
    public let emailVerificationStatus: EmailVerificationStatus
    public let userRegistrationStatus: UserRegistrationStatus
    
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
                emailVerificationStatus: EmailVerificationStatus,
                userRegistrationStatus: UserRegistrationStatus) {
        
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
        
        self.emailVerificationStatus = emailVerificationStatus
        self.userRegistrationStatus = userRegistrationStatus
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
    
    public init(username: String? = nil, email: String? = nil, firstName: String? = nil, lastName: String? = nil, birthDate: Date? = nil, gender: String? = nil, address: String? = nil, province: String? = nil, city: String? = nil, postalCode: String? = nil, country: Country? = nil, cardId: String? = nil, mobileNumber: String? = nil, securityQuestion: String? = nil, securityAnswer: String? = nil) {
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
}
