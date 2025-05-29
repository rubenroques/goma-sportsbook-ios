import Foundation
import Combine

/// Represents the current state of authentication
public enum AuthenticationState: Hashable {
    /// No authentication attempt has been made
    case initial
    /// Authentication is in progress
    case authenticating
    /// User is authenticated with a valid token
    case authenticated(SessionToken)
    /// Authentication has failed or been cleared
    case unauthenticated
}

/// A class responsible for managing authentication state and session tokens for the EveryMatrix API.
/// This authenticator handles token management and refresh operations.
public final class EveryMatrixAuthenticator {

    // MARK: - Properties

    /// The current session token, if any
    private var token: SessionToken? {
        didSet {
            updateAuthenticationState()
        }
    }

    /// A publisher that emits valid session tokens or errors during token refresh operations
    private var refreshPublisher: AnyPublisher<SessionToken, Error>?

    /// Queue for synchronizing token operations
    private let queue = DispatchQueue(label: "com.goma.authenticator.\(UUID().uuidString)")

    /// Current authentication state
    @Published private(set) public var state: AuthenticationState = .initial

    /// Publisher for authentication state changes
    public var statePublisher: AnyPublisher<AuthenticationState, Never> {
        $state.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    /// Creates a new instance of the EveryMatrix authenticator
    public init() {}

    // MARK: - Token Management

    /// Returns the current session token's ID, if available
    /// - Returns: The session ID as a String, or nil if no token is present
    public func getToken() -> String? {
        return token?.sessionID
    }
    
    /// Returns whether the authenticator currently holds a valid session token
    /// - Returns: True if a valid token exists, false otherwise
    public func hasValidToken() -> Bool {
        return queue.sync {
            isTokenValid(token)
        }
    }
    
    /// Updates the current session token
    /// - Parameter newToken: The new session token to store, or nil to clear the current token
    public func updateToken(_ newToken: SessionToken?) {
        queue.sync {
            token = newToken
            refreshPublisher = nil
        }
    }

    /// Returns a publisher that emits a valid session token
    /// - Parameter forceRefresh: Whether to force a token refresh even if a valid token exists
    /// - Returns: A publisher that emits a valid session token or an error
    public func publisherWithValidToken(forceRefresh: Bool = false) -> AnyPublisher<SessionToken, Error> {
        return queue.sync { [weak self] in
            guard let self = self else {
                return Fail(error: EveryMatrixError.unexpectedDeallocation).eraseToAnyPublisher()
            }

            // Update state to authenticating if we need to refresh
            if forceRefresh || self.token == nil {
                self.state = .authenticating
            }

            // If we're already refreshing, return the existing publisher
            if let publisher = self.refreshPublisher {
                return publisher
            }

            // If we have a valid token and don't need to force refresh, return it
            if !forceRefresh, let token = self.token, isTokenValid(token) {
                return Just(token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // Create a new publisher for token refresh
            let publisher = self.createTokenRefreshPublisher()
                .handleEvents(receiveOutput: { [weak self] token in
                    self?.queue.sync {
                        self?.token = token
                        self?.refreshPublisher = nil
                    }
                }, receiveCompletion: { [weak self] completion in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                        if case .failure = completion {
                            self?.state = .unauthenticated
                        }
                    }
                })
                .share()
                .eraseToAnyPublisher()

            self.refreshPublisher = publisher
            return publisher
        }
    }

    // MARK: - Private Methods

    /// Creates a publisher that refreshes the session token
    /// - Returns: A publisher that emits a new session token or an error
    private func createTokenRefreshPublisher() -> AnyPublisher<SessionToken, Error> {
        // This will be implemented when we have the API client ready
        // For now, return a failure to indicate unimplemented
        return Fail(error: EveryMatrixError.invalidRequestFormat).eraseToAnyPublisher()
    }

    /// Validates whether a token is still valid
    /// - Parameter token: The token to validate
    /// - Returns: True if the token is valid, false otherwise
    private func isTokenValid(_ token: SessionToken?) -> Bool {
        // For now, consider any non-nil token as valid
        // In the future, we might want to add expiration time checks
        return token != nil
    }

    /// Updates the authentication state based on the current token
    private func updateAuthenticationState() {
        if let token = token {
            state = .authenticated(token)
        } else {
            state = .unauthenticated
        }
    }
}
