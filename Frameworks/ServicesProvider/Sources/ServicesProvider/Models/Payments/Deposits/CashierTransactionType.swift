
import Foundation

/// Enumeration representing the type of banking transaction
public enum CashierTransactionType: String, CaseIterable, Codable {
    case deposit = "Deposit"
    case withdraw = "Withdraw"
    
    /// Localized display name for the transaction type
    public var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .withdraw:
            return "Withdraw"
        }
    }
    
    /// URL parameter value for API requests
    public var apiValue: String {
        return rawValue
    }
}
