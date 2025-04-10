import Foundation

/// Represents a mobile phone number for registration
public struct MobilePhone: Codable {
    /// The country prefix (e.g., "+351")
    public let prefix: String
    
    /// The phone number
    public let number: String
    
    public init(prefix: String, number: String) {
        self.prefix = prefix
        self.number = number
    }
}

/// Represents birth date information
public struct BirthDate: Codable {
    /// Day of birth (1-31)
    public let day: Int
    
    /// Month of birth (1-12)
    public let month: Int
    
    /// Year of birth (e.g., 1987)
    public let year: Int
    
    public init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
}

/// Represents user consent settings
public struct UserConsents: Codable {
    /// Acceptance of terms and conditions
    public let termsAndConditions: Bool
    
    /// Consent for email marketing
    public let emailMarketing: Bool
    
    /// Consent for SMS marketing
    public let sms: Bool
    
    /// Consent for third-party marketing
    public let thirdParty: Bool
    
    public init(termsAndConditions: Bool, emailMarketing: Bool, sms: Bool, thirdParty: Bool) {
        self.termsAndConditions = termsAndConditions
        self.emailMarketing = emailMarketing
        self.sms = sms
        self.thirdParty = thirdParty
    }
    
    private enum CodingKeys: String, CodingKey {
        case termsAndConditions = "termsandconditions"
        case emailMarketing = "emailmarketing"
        case sms
        case thirdParty = "3rdparty"
    }
}

/// Represents a registration request to the EveryMatrix API
public struct RegistrationRequest: Codable {
    /// Required fields
    public let username: String
    public let firstname: String
    public let lastname: String
    public let motherMaidenName: String
    public let address1: String
    public let birth: BirthDate
    public let city: String
    public let country: String
    public let currency: String
    public let email: String
    public let postalCode: String
    public let password: String
    public let title: String
    public let securityAnswer: String
    public let securityQuestion: String
    public let mobile: MobilePhone
    
    /// Optional fields
    public let address2: String?
    public let userConsents: UserConsents
    public let nationality: String?
    public let personalId: String?
    public let birthPlace: String?
    public let affiliateMarker: String?
    public let alias: String?
    public let language: String?
    public let gender: String?
    public let iban: String?
    
    public init(
        username: String,
        firstname: String,
        lastname: String,
        motherMaidenName: String,
        address1: String,
        birth: BirthDate,
        city: String,
        country: String,
        currency: String,
        email: String,
        postalCode: String,
        password: String,
        title: String,
        securityAnswer: String,
        securityQuestion: String,
        mobile: MobilePhone,
        address2: String? = nil,
        userConsents: UserConsents,
        nationality: String? = nil,
        personalId: String? = nil,
        birthPlace: String? = nil,
        affiliateMarker: String? = nil,
        alias: String? = nil,
        language: String? = nil,
        gender: String? = nil,
        iban: String? = nil
    ) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.motherMaidenName = motherMaidenName
        self.address1 = address1
        self.birth = birth
        self.city = city
        self.country = country
        self.currency = currency
        self.email = email
        self.postalCode = postalCode
        self.password = password
        self.title = title
        self.securityAnswer = securityAnswer
        self.securityQuestion = securityQuestion
        self.mobile = mobile
        self.address2 = address2
        self.userConsents = userConsents
        self.nationality = nationality
        self.personalId = personalId
        self.birthPlace = birthPlace
        self.affiliateMarker = affiliateMarker
        self.alias = alias
        self.language = language
        self.gender = gender
        self.iban = iban
    }
} 