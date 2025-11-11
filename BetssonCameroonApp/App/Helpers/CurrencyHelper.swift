//
//  CurrencyHelper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//  Updated for web parity: Currency formatting without symbols
//

import Foundation

/// Currency formatting helper matching web app behavior
///
/// This helper formats monetary amounts to match the web app's `formattedCurrency()` function
/// from `web-app/src/utils/bettingUtils.js:151-156`.
///
/// Key Characteristics:
/// - No currency symbols or codes (just formatted numbers)
/// - Fixed 'en-US' locale (comma thousand separator, period decimal)
/// - Always 2 decimal places
/// - Thousand separators enabled
///
/// Examples:
/// - formatAmount(1000) → "1,000.00"
/// - formatAmount(1234.56) → "1,234.56"
/// - formatAmount(0) → "0.00"
struct CurrencyHelper {

    /// Formats a monetary amount to match web app behavior (no currency symbol, comma separators, 2 decimals)
    ///
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted string like "1,234.56" (no currency symbol)
    ///
    /// This matches web's formattedCurrency() function from utils/bettingUtils.js:151-156
    ///
    /// Examples:
    /// ```swift
    /// CurrencyHelper.formatAmount(1000)      // → "1,000.00"
    /// CurrencyHelper.formatAmount(1234.56)   // → "1,234.56"
    /// CurrencyHelper.formatAmount(0)         // → "0.00"
    /// CurrencyHelper.formatAmount(-500)      // → "-500.00"
    /// ```
    static func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()

        // Match web's Intl.NumberFormat('en-US') behavior
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal  // Decimal style (NOT .currency - no symbols!)

        // Always 2 decimal places (matches web minimumFractionDigits: 2, maximumFractionDigits: 2)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        // Enable thousand separators (comma in en_US locale)
        formatter.usesGroupingSeparator = true

        // Round half up (standard rounding)
        formatter.roundingMode = .halfUp

        // Format and return
        guard let formatted = formatter.string(from: NSNumber(value: amount)) else {
            return "0.00"  // Fallback if formatting fails
        }

        return formatted
    }

    /// Formats a monetary amount with currency code prefix
    ///
    /// - Parameters:
    ///   - amount: The amount to format
    ///   - currency: The currency code (e.g., "XAF", "EUR", "USD")
    /// - Returns: Formatted string like "XAF 1,234.56"
    ///
    /// Examples:
    /// ```swift
    /// CurrencyHelper.formatAmountWithCurrency(1000, currency: "XAF")      // → "XAF 1,000.00"
    /// CurrencyHelper.formatAmountWithCurrency(1234.56, currency: "EUR")   // → "EUR 1,234.56"
    /// CurrencyHelper.formatAmountWithCurrency(0, currency: "USD")         // → "USD 0.00"
    /// ```
    static func formatAmountWithCurrency(_ amount: Double, currency: String) -> String {
        let formattedAmount = formatAmount(amount)
        return "\(currency) \(formattedAmount)"
    }
}

// MARK: - Legacy Support (Deprecated)

/// Legacy CurrencyFormater struct for backward compatibility during migration
///
/// ⚠️ DEPRECATED: This struct exists only for backward compatibility.
/// Use `CurrencyHelper.formatAmount()` instead.
@available(*, deprecated, message: "Use CurrencyHelper.formatAmount(_:) instead. This adds currency symbols which web doesn't use.")
struct CurrencyFormater {

    static var defaultFormat: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.roundingMode = .halfUp
        currencyFormatter.currencyCode = "EUR"
        return currencyFormatter
    }()

    /// Legacy method for wallet amount formatting
    ///
    /// ⚠️ DEPRECATED: Use `CurrencyHelper.formatAmount(_:)` instead
    ///
    /// This method now delegates to the new implementation without currency symbols
    @available(*, deprecated, message: "Use CurrencyHelper.formatAmount(_:) instead")
    static func formatWalletAmount(_ amount: Double) -> String {
        return CurrencyHelper.formatAmount(amount)
    }

    /// Legacy instance method (unused, kept for compatibility)
    @available(*, deprecated, message: "Use CurrencyHelper.formatAmount(_:) instead")
    func currencyTypeFormatting(string: String) -> String {
        guard let number = Double(string) else {
            return "0.00"
        }
        return CurrencyHelper.formatAmount(number)
    }

    /// Legacy instance method (unused, kept for compatibility)
    @available(*, deprecated, message: "Use CurrencyHelper.formatAmount(_:) instead")
    func currencyTypeWithSeparatorFormatting(string: String) -> String {
        guard let number = Double(string) else {
            return "0.00"
        }
        return CurrencyHelper.formatAmount(number)
    }
}

/// Legacy CurrencyType enum (no longer needed since we don't show currency symbols)
///
/// ⚠️ DEPRECATED: This enum is no longer used in the new implementation
@available(*, deprecated, message: "Currency symbols are no longer displayed. Handle currency context in UI layer if needed.")
enum CurrencyType: String {
    case eur = "€"
    case usd = "$"
    case gbp = "£"
    case xaf = "XAF"

    init?(rawValue: String) {
        switch rawValue {
        case "€":
            self = .eur
        case "$":
            self = .usd
        case "£":
            self = .gbp
        case "XAF":
            self = .xaf
        default:
            self = .eur
        }
    }

    var code: String {
        switch self {
        case .eur:
            return "EUR"
        case .usd:
            return "USD"
        case .gbp:
            return "GBP"
        case .xaf:
            return "XAF"
        }
    }
}
