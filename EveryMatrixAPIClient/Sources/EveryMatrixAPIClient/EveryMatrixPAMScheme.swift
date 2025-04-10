import Foundation

/// Generated API client for accessing endpoints
public enum EveryMatrixPAMScheme: Endpoint {
    /// Authentication endpoints
    case login(username: String, password: String)
    case register(registrationRequest: RegistrationRequest)
    case logout(sessionId: String)
    /// Get player balance
    case getBalance(userId: String)

    /// Configuration for the scheme
    private static let config = EveryMatrixConfiguration.default

    /// Base URL for the API
    public var url: String {
        return Self.config.environment.baseURL
    }

    /// Path component of the endpoint
    public var endpoint: String {
        switch self {
        case .login:
            return "/v1/player/login/player"
        case .register:
            return "/v1/player/register"
        case .logout:
            return "/v1/player/session/player"
        case .getBalance(let userId):
            return "/v2/player/\(userId)/balance"
        }
    }

    /// HTTP method for the endpoint
    public var method: HTTP.Method {
        switch self {
        case .login:
            return .post
        case .register:
            return .put
        case .logout:
            return .delete
        case .getBalance:
            return .get
        }
    }

    /// Query parameters for the endpoint
    public var query: [URLQueryItem]? {
        return nil
    }

    /// HTTP headers for the endpoint
    public var headers: HTTP.Headers? {
        var headers = Self.config.defaultHeaders

        // Add session ID header for logout
        if case .logout(let sessionId) = self {
            headers["X-SessionId"] = sessionId
        }

        // Balance endpoint also needs session headers (implicitly handled by connector via requireSessionKey)
        // No specific headers needed here beyond defaults and session handled by connector.

        return headers
    }

    /// Request body for the endpoint
    public var body: Data? {
        switch self {
        case .login(let username, let password):
            let credentials = LoginCredentials(username: username, password: password)
            return try? JSONEncoder().encode(credentials)

        case .register(let request):
            return try? JSONEncoder().encode(request)

        case .logout:
            return nil
        case .getBalance:
            return nil
        }
    }

    public var cachePolicy: URLRequest.CachePolicy {
        return Self.config.defaultCachePolicy
    }

    public var timeout: TimeInterval {
        return Self.config.defaultTimeout
    }

    public var requireSessionKey: Bool {
        if case .logout = self {
            return true
        }
        // Balance endpoint requires session key
        if case .getBalance = self {
            return true
        }
        return false
    }

    public var comment: String? {
        return nil
    }
}
