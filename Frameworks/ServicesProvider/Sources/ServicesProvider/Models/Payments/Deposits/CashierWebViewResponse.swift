
import Foundation

/// Response containing WebView URL for banking operations
public struct CashierWebViewResponse: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Cashier information containing the WebView URL
    public let cashierInfo: CashierInfo
    
    /// Response status code from the API
    public let responseCode: String?
    
    /// Unique request identifier for tracking
    public let requestId: String?
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case cashierInfo = "CashierInfo"
        case responseCode = "ResponseCode"
        case requestId = "RequestId"
    }
    
    // MARK: - Initializer
    
    /// Initialize cashier WebView response
    /// - Parameters:
    ///   - cashierInfo: Cashier information with URL
    ///   - responseCode: API response status
    ///   - requestId: Unique request identifier
    public init(cashierInfo: CashierInfo, responseCode: String? = nil, requestId: String? = nil) {
        self.cashierInfo = cashierInfo
        self.responseCode = responseCode
        self.requestId = requestId
    }
}

/// Cashier information containing WebView URL
public struct CashierInfo: Codable, Equatable {
    
    // MARK: - Properties
    
    /// URL for the banking WebView
    public let url: String
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case url = "Url"
    }
    
    // MARK: - Initializer
    
    /// Initialize cashier info
    /// - Parameter url: WebView URL
    public init(url: String) {
        self.url = url
    }
}
