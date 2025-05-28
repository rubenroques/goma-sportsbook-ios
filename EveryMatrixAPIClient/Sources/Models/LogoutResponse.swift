import Foundation

/// Represents the response from a successful logout request
public struct LogoutResponse: Codable {
    /// The status message returned by the API
    public let message: String
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
}

extension LogoutResponse: Equatable {
    public static func == (lhs: LogoutResponse, rhs: LogoutResponse) -> Bool {
        return lhs.message == rhs.message
    }
} 