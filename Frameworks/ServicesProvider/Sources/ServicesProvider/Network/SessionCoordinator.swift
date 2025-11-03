import Foundation
import Combine

/*
// Updating tokens
coordinator.updateToken(.rest(token: "new-rest-token"))
coordinator.updateToken(.custom(key: "special", token: "custom-token"), provider: "SportRadar")

// Observing tokens
coordinator.tokenPublisher(for: .socket(token: nil))
    .sink { token in
        print("Socket token updated: \(token ?? "nil")")
    }
    .store(in: &cancellables)

// Force refresh
coordinator.forceTokenRefresh(for: .auth(token: nil))
*/

/// Represents different types of session tokens used across providers
public enum SessionToken {
    case rest(token: String?)
    case socket(token: String?)
    case launch(token: String?)
    case auth(token: String?)
    case custom(key: String, token: String?)
    
    var key: String {
        switch self {
        case .rest: return "rest"
        case .socket: return "socket"
        case .launch: return "launch"
        case .auth: return "auth"
        case .custom(let key, _): return key
        }
    }
    
    var value: String? {
        switch self {
        case .rest(let token): return token
        case .socket(let token): return token
        case .launch(let token): return token
        case .auth(let token): return token
        case .custom(_, let token): return token
        }
    }
}

/// Protocol for components that can update session tokens
public protocol SessionTokenUpdater: AnyObject {
    func forceTokenRefresh(forType type: SessionToken) -> AnyPublisher<String?, Never>
}

/// Main coordinator for managing session tokens across different providers
public final class SessionCoordinator {
    
    // MARK: - Properties
    
    private var tokenPublishers: [String: CurrentValueSubject<String?, Never>]
    private var tokenUpdaters: [String: SessionTokenUpdater]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        self.tokenPublishers = [:]
        self.tokenUpdaters = [:]
    }
    
    // MARK: - Public Methods
    
    /// Clears all active sessions
    public func clearAllSessions() {
        for publisher in tokenPublishers.values {
            publisher.send(nil)
        }
    }
    
    /// Updates a token of a specific type
    /// - Parameters:
    ///   - token: The session token with its new value
    ///   - provider: Optional provider identifier
    public func updateToken(_ token: SessionToken, provider: Provider? = nil) {
        let key = makeKey(token: token, provider: provider)
        tokenPublishers[key]?.send(token.value)
    }
    
    /// Clears a specific token type
    /// - Parameters:
    ///   - type: The type of token to clear
    ///   - provider: Optional provider identifier
    public func clearToken(_ type: SessionToken, provider: Provider? = nil) {
        let key = makeKey(token: type, provider: provider)
        tokenPublishers[key]?.send(nil)
    }
    
    /// Gets a publisher for a specific token type
    /// - Parameters:
    ///   - type: The type of token to observe
    ///   - provider: Optional provider identifier
    /// - Returns: A publisher that emits token updates
    public func tokenPublisher(for type: SessionToken, provider: Provider? = nil) -> AnyPublisher<String?, Never> {
        let key = makeKey(token: type, provider: provider)
        
        if let publisher = tokenPublishers[key] {
            return publisher.eraseToAnyPublisher()
        } else {
            tokenPublishers[key] = .init(type.value)
            return tokenPublishers[key]!.eraseToAnyPublisher()
        }
    }
    
    /// Registers a token updater for a specific token type
    /// - Parameters:
    ///   - updater: The component that can update tokens
    ///   - type: The type of token this updater handles
    ///   - provider: Optional provider identifier
    public func registerUpdater(_ updater: SessionTokenUpdater, for type: SessionToken, provider: Provider? = nil) {
        let key = makeKey(token: type, provider: provider)
        tokenUpdaters[key] = updater
    }
    
    /// Forces a token refresh for a specific type
    /// - Parameters:
    ///   - type: The type of token to refresh
    ///   - provider: Optional provider identifier
    /// - Returns: A publisher that will emit the refreshed token
    public func forceTokenRefresh(for type: SessionToken, provider: Provider? = nil) -> AnyPublisher<String?, Never>? {
        let key = makeKey(token: type, provider: provider)
        tokenPublishers[key]?.send(nil)
        
        return tokenUpdaters[key]?.forceTokenRefresh(forType: type)
    }
    
    // MARK: - Private Methods
    
    private func makeKey(token: SessionToken, provider: Provider?) -> String {
        if let provider = provider {
            return "\(provider).\(token.key)"
        }
        return token.key
    }
}



