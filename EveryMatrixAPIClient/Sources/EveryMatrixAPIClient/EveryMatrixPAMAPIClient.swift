import Foundation
import Combine

/// Client for interacting with EveryMatrix Player Account Management (PAM) API
public final class EveryMatrixPAMAPIClient {
    private let connector: EveryMatrixConnector
    private let configuration: EveryMatrixConfiguration
    
    /// Initialize a new PAM API client
    /// - Parameters:
    ///   - configuration: Configuration for the API client
    ///   - connector: Connector for making HTTP requests
    public init(
        configuration: EveryMatrixConfiguration = .default,
        connector: EveryMatrixConnector
    ) {
        self.configuration = configuration
        self.connector = connector
    }
    
    /// Login with username and password
    /// - Parameters:
    ///   - username: User's username
    ///   - password: User's password
    /// - Returns: A publisher that emits a LoginResponse or an error
    public func login(username: String, password: String) -> AnyPublisher<LoginResponse, EveryMatrixAuthenticationError> {
        return connector.request(EveryMatrixPAMScheme.login(username: username, password: password))
    }
    
    /// Register a new user
    /// - Parameter request: Registration request containing user details
    /// - Returns: A publisher that emits a RegistrationResponse or an error
    public func register(request: RegistrationRequest) -> AnyPublisher<RegistrationResponse, EveryMatrixAuthenticationError> {
        return connector.request(EveryMatrixPAMScheme.register(registrationRequest: request))
    }
    
    /// Logout the current user
    /// - Parameter sessionId: The session ID to invalidate
    /// - Returns: A publisher that completes when logout is successful or emits an error
    public func logout(sessionId: String) -> AnyPublisher<Bool, EveryMatrixAuthenticationError> {
        return connector.request(EveryMatrixPAMScheme.logout(sessionId: sessionId))
    }
    
    /// Fetch player balance
    /// - Parameter userId: The ID of the player
    /// - Returns: A publisher that emits a BalanceResponse or an error
    public func getBalance(userId: String) -> AnyPublisher<BalanceResponse, EveryMatrixAuthenticationError> {
        return connector.request(EveryMatrixPAMScheme.getBalance(userId: userId))
    }
    
    /// Get the current configuration
    public var currentConfiguration: EveryMatrixConfiguration {
        return configuration
    }
}
