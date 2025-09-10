
import Foundation

/// Parameters required for banking WebView API requests
public struct CashierParameters: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Channel identifier (e.g., "mobile")
    public let channel: String
    
    /// Transaction type ("Deposit" or "Withdraw")
    public let type: String
    
    /// URL to redirect on successful transaction
    public let successUrl: String
    
    /// URL to redirect on transaction cancellation
    public let cancelUrl: String
    
    /// URL to redirect on transaction failure
    public let failUrl: String
    
    /// Language code for the WebView
    public let language: String
    
    /// Product type (e.g., "Sports", "Casino")
    public let productType: String
    
    /// Currency code for the transaction
    public let currency: String
    
    /// Whether to use short cashier UI
    public let isShortCashier: Bool
    
    /// Bonus code to apply (if any)
    public let bonusCode: String?
    
    /// Whether to show bonus selection input
    public let showBonusSelectionInput: Bool
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case channel = "Channel"
        case type = "Type"
        case successUrl = "SuccessUrl"
        case cancelUrl = "CancelUrl"
        case failUrl = "FailUrl"
        case language = "Language"
        case productType
        case currency
        case isShortCashier
        case bonusCode
        case showBonusSelectionInput
    }
    
    // MARK: - Initializer
    
    /// Initialize banking parameters
    /// - Parameters:
    ///   - channel: Channel identifier, defaults to "mobile"
    ///   - type: Transaction type
    ///   - successUrl: Success redirect URL
    ///   - cancelUrl: Cancel redirect URL
    ///   - failUrl: Failure redirect URL
    ///   - language: Language code
    ///   - productType: Product type, defaults to "Sports"
    ///   - currency: Currency code
    ///   - isShortCashier: Use short cashier UI, defaults to false
    ///   - bonusCode: Optional bonus code
    ///   - showBonusSelectionInput: Show bonus selection, defaults to true
    public init(
        channel: String = "Mobile",
        type: CashierTransactionType,
        successUrl: String,
        cancelUrl: String,
        failUrl: String,
        language: String,
        productType: String = "Sports",
        currency: String,
        isShortCashier: Bool = false,
        bonusCode: String? = nil,
        showBonusSelectionInput: Bool = true
    ) {
        self.channel = channel
        self.type = type.apiValue
        self.successUrl = successUrl
        self.cancelUrl = cancelUrl
        self.failUrl = failUrl
        self.language = language
        self.productType = productType
        self.currency = currency
        self.isShortCashier = isShortCashier
        self.bonusCode = bonusCode
        self.showBonusSelectionInput = showBonusSelectionInput
    }
}

// MARK: - Convenience Initializers

public extension CashierParameters {
    
    /// Create parameters for deposit transaction
    /// - Parameters:
    ///   - language: Language code
    ///   - currency: Currency code
    ///   - bonusCode: Optional bonus code
    /// - Returns: Configured banking parameters for deposit
    static func forDeposit(
        language: String,
        currency: String,
        bonusCode: String? = nil
    ) -> CashierParameters {
        return CashierParameters(
            type: .deposit,
            successUrl: "http://localhost:5173/deposit/success",
            cancelUrl: "http://localhost:5173/deposit/cancel",
            failUrl: "http://localhost:5173/deposit/fail",
            language: language,
            currency: currency,
            bonusCode: bonusCode
        )
    }
    
    /// Create parameters for withdraw transaction
    /// - Parameters:
    ///   - language: Language code
    ///   - currency: Currency code
    /// - Returns: Configured banking parameters for withdraw
    static func forWithdraw(
        language: String,
        currency: String
    ) -> CashierParameters {
        return CashierParameters(
            type: .withdraw,
            successUrl: "http://localhost:5173/withdraw/success",
            cancelUrl: "http://localhost:5173/withdraw/cancel",
            failUrl: "http://localhost:5173/withdraw/fail",
            language: language,
            currency: currency,
            showBonusSelectionInput: false
        )
    }
}
