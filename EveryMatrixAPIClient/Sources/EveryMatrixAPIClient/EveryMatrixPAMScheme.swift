import Foundation

/// Generated API client for accessing endpoints
public enum EveryMatrixPAMScheme: Endpoint {
    
    case login
    case register

    /// Base URL for the API
    public var url: String {
        return "https://betsson-api.stage.norway.everymatrix.com/"
    }

    /// Path component of the endpoint
    public var endpoint: String {
        return ""
    }

    /// HTTP method for the endpoint
    public var method: HTTP.Method {
        return .get
    }

    /// Query parameters for the endpoint
    public var query: [URLQueryItem]? {
        return nil
    }

    /// HTTP headers for the endpoint
    public var headers: HTTP.Headers? {
        // Default headers for all requests
        var headers: HTTP.Headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "GOMA/native-app/iOS",
        ]

        return headers
    }

    /// Request body for the endpoint
    public var body: Data? {
        return nil
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
         return TimeInterval(10)
    }
    
    var requireSessionKey: Bool {
        return false
    }
    
    var comment: String? {
        return nil
    }
    
}
