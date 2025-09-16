
import Foundation

/// Response containing WebView URL for banking operations (Provider-agnostic domain model)
public struct CashierWebViewResponse: Equatable {
    
    // MARK: - Properties
    
    /// WebView URL for banking operations
    public let webViewURL: String
    
    /// Response status code from the API
    public let responseCode: String?
    
    /// Unique request identifier for tracking
    public let requestId: String?
    
    // MARK: - Initializer
    
    /// Initialize cashier WebView response
    /// - Parameters:
    ///   - webViewURL: The WebView URL
    ///   - responseCode: API response status
    ///   - requestId: Unique request identifier
    public init(webViewURL: String, responseCode: String? = nil, requestId: String? = nil) {
        self.webViewURL = webViewURL
        self.responseCode = responseCode
        self.requestId = requestId
    }
}

// MARK: - Convenience Properties

public extension CashierWebViewResponse {
    
    /// Check if response contains valid URL
    var hasValidURL: Bool {
        return !webViewURL.isEmpty && URL(string: webViewURL) != nil
    }
    
    /// Check if the API response was successful
    var isSuccessful: Bool {
        return responseCode?.lowercased() == "success"
    }
}
