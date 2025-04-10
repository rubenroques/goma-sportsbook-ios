import Foundation

/// Errors specific to authentication
public enum EveryMatrixAuthenticationError: Error, Equatable {
    /// No session token available, login required
    case loginRequired
    /// Invalid credentials provided
    case invalidCredentials
    /// Invalid session token
    case invalidToken
    /// Account is locked or suspended
    case accountLocked
    /// Registration data is invalid
    case invalidRegistrationData(String)
    /// Network or server error
    case networkError(String)
    /// Invalid request format or parameters
    case invalidRequest(String)
    /// Failed to decode the API response
    case invalidResponseDecoded(Error)
    /// Unknown error
    case unknown(String)

    /// Error description for the authentication errors
    public var localizedDescription: String {
        switch self {
        case .loginRequired:
            return "Authentication required. Please log in."
        case .invalidCredentials:
            return "Invalid username or password."
        case .invalidToken:
            return "Authentication session has expired. Please log in again."
        case .accountLocked:
            return "Account is locked or suspended. Please contact customer support."
        case .invalidRegistrationData(let message):
            return "Registration failed: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .invalidResponseDecoded(let error):
            return "Failed to parse server response: \(error.localizedDescription)"
        case .unknown(let message):
            return "Authentication error: \(message)"
        }
    }

    /// Equality implementation for Equatable
    public static func == (lhs: EveryMatrixAuthenticationError, rhs: EveryMatrixAuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.loginRequired, .loginRequired),
             (.invalidCredentials, .invalidCredentials),
             (.invalidToken, .invalidToken),
             (.accountLocked, .accountLocked):
            return true

        case (.invalidRegistrationData(let lhsMsg), .invalidRegistrationData(let rhsMsg)),
             (.networkError(let lhsMsg), .networkError(let rhsMsg)),
             (.invalidRequest(let lhsMsg), .invalidRequest(let rhsMsg)),
             (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg

        case (.invalidResponseDecoded(let lhsErr), .invalidResponseDecoded(let rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription

        default:
            return false
        }
    }
}