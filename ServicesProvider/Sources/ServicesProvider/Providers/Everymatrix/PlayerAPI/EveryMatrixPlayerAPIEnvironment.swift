import Foundation

/// Environment configuration for EveryMatrix API
public enum EveryMatrixPlayerAPIEnvironment {
    /// Production environment
    case production
    /// Staging environment
    case staging
    /// Custom environment with specific URL
    case custom(baseURL: String)

    /// Base URL for the environment
    var baseURL: String {
        switch self {
        case .production:
            return "https://betsson-api.everymatrix.com"
        case .staging:
            return "https://betsson-api.stage.norway.everymatrix.com"
        case .custom(let url):
            return url
        }
    }
}

/// Configuration for EveryMatrix API client
public final class EveryMatrixConfiguration: @unchecked Sendable {
    /// Current environment
    public let environment: EveryMatrixPlayerAPIEnvironment

    /// Default timeout interval for requests
    public let defaultTimeout: TimeInterval

    /// Default cache policy for requests
    public let defaultCachePolicy: URLRequest.CachePolicy

    /// Default headers to include in all requests
    public let defaultHeaders: [String: String]

    /// Shared instance with default configuration
    public static let `default` = EveryMatrixConfiguration(
        environment: .staging,
        defaultTimeout: 30,
        defaultCachePolicy: .reloadIgnoringLocalCacheData,
        defaultHeaders: [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "GOMA/native-app/iOS"
        ]
    )

    /// Initialize a new configuration
    /// - Parameters:
    ///   - environment: The API environment to use
    ///   - defaultTimeout: Default timeout for requests in seconds
    ///   - defaultCachePolicy: Default cache policy for requests
    ///   - defaultHeaders: Default headers to include in all requests
    public init(
        environment: EveryMatrixPlayerAPIEnvironment,
        defaultTimeout: TimeInterval = 30,
        defaultCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        defaultHeaders: [String: String] = [:]
    ) {
        self.environment = environment
        self.defaultTimeout = defaultTimeout
        self.defaultCachePolicy = defaultCachePolicy
        self.defaultHeaders = defaultHeaders
    }
}
