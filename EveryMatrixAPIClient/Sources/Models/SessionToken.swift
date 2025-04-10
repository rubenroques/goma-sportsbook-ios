import Foundation

/// Represents a session token returned by the EveryMatrix API after successful login
public struct SessionToken: Codable, Hashable {
    /// The unique session identifier used for authenticating requests
    public let sessionID: String
    
    /// The universal identifier for the user
    public let universalID: String
    
    /// Indicates if the user needs to accept terms and conditions
    public let hasToAcceptTC: Bool
    
    /// Indicates if the user needs to set a password
    public let hasToSetPass: Bool
    
    private enum CodingKeys: String, CodingKey {
        case sessionID = "sessionID"
        case universalID = "universalID"
        case hasToAcceptTC = "hasToAcceptTC"
        case hasToSetPass = "hasToSetPass"
    }
    
    public init(sessionID: String, universalID: String, hasToAcceptTC: Bool = false, hasToSetPass: Bool = false) {
        self.sessionID = sessionID
        self.universalID = universalID
        self.hasToAcceptTC = hasToAcceptTC
        self.hasToSetPass = hasToSetPass
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sessionID = try container.decode(String.self, forKey: .sessionID)
        self.universalID = try container.decode(String.self, forKey: .universalID)
        self.hasToAcceptTC = try container.decodeIfPresent(Bool.self, forKey: .hasToAcceptTC) ?? false
        self.hasToSetPass = try container.decodeIfPresent(Bool.self, forKey: .hasToSetPass) ?? false
    }
    
}

extension SessionToken: Equatable {
    public static func == (lhs: SessionToken, rhs: SessionToken) -> Bool {
        return lhs.sessionID == rhs.sessionID &&
               lhs.universalID == rhs.universalID &&
               lhs.hasToAcceptTC == rhs.hasToAcceptTC &&
               lhs.hasToSetPass == rhs.hasToSetPass
    }
} 
