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
    public let emailVerificationStatus: EmailVerificationStatus
    public let userRegistrationStatus: UserRegistrationStatus
    
    public init(userIdentifier: String,
                username: String,
                email: String,
                firstName: String?,
                lastName: String?,
                birthDate: Date,
                emailVerificationStatus: EmailVerificationStatus,
                userRegistrationStatus: UserRegistrationStatus) {
        self.userIdentifier = userIdentifier
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
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
}

public struct SimpleSignUpForm {
    let email: String
    let username: String
    let password: String
    let birthDate: Date
    let mobilePrefix: String
    let mobileNumber: String
    let countryIsoCode: String
    let currencyCode: String
}
