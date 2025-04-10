import Foundation

/// Represents the response from a successful registration request
public struct RegistrationResponse: Codable {
    /// The registered username
    public let username: String
    
    /// The user's first name
    public let firstname: String
    
    /// The user's last name
    public let lastname: String
    
    /// The user's primary address
    public let address1: String
    
    /// The user's birth date information
    public let birth: BirthDate
    
    /// The user's city of residence
    public let city: String
    
    /// The user's country code
    public let country: String
    
    /// The user's currency preference
    public let currency: String
    
    /// The user's email address
    public let email: String
    
    /// The user's mobile phone information
    public let mobile: MobilePhone
    
    /// The user's secondary address (optional)
    public let address2: String?
    
    /// The user's personal identification number
    public let personalId: String?
    
    /// The user's alias/nickname
    public let alias: String?
    
    /// The unique identifier assigned to the user
    public let id: String
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case address1
        case birth
        case city
        case country
        case currency
        case email
        case mobile
        case address2
        case personalId
        case alias
        case id
    }
}

extension RegistrationResponse: Equatable {
    public static func == (lhs: RegistrationResponse, rhs: RegistrationResponse) -> Bool {
        return lhs.id == rhs.id &&
               lhs.username == rhs.username &&
               lhs.email == rhs.email
    }
} 