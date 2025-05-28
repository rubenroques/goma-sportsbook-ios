import Foundation

/// Response from the login endpoint
public struct LoginResponse: Codable, Equatable {
    /// Session ID for the authenticated user
    public let sessionID: String
    /// Universal ID for the user
    public let universalID: String
    /// Whether the user needs to accept terms and conditions
    public let hasToAcceptTC: Bool
    /// Whether the user needs to set a password
    public let hasToSetPass: Bool
    
    /// Create a SessionToken from this response
    public var sessionToken: SessionToken {
        return SessionToken(sessionID: sessionID, universalID: universalID)
    }
    
    /// Initializes a new login response
    /// - Parameters:
    ///   - sessionID: Session ID for the authenticated user
    ///   - universalID: Universal ID for the user
    ///   - hasToAcceptTC: Whether the user needs to accept terms and conditions
    ///   - hasToSetPass: Whether the user needs to set a password
    public init(sessionID: String, universalID: String, hasToAcceptTC: Bool, hasToSetPass: Bool) {
        self.sessionID = sessionID
        self.universalID = universalID
        self.hasToAcceptTC = hasToAcceptTC
        self.hasToSetPass = hasToSetPass
    }
} 
