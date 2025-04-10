import Foundation

/// Represents the credentials required for logging in to the EveryMatrix API
public struct LoginCredentials: Codable {
    /// The user's username
    public let username: String
    
    /// The user's password
    public let password: String
    
    /// Initialize a new LoginCredentials instance
    /// - Parameters:
    ///   - username: The user's username
    ///   - password: The user's password
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    private enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}

extension LoginCredentials: Equatable {
    public static func == (lhs: LoginCredentials, rhs: LoginCredentials) -> Bool {
        return lhs.username == rhs.username &&
               lhs.password == rhs.password
    }
} 