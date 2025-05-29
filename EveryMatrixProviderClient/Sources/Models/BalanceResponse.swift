import Foundation

/// Represents the overall balance information for a player.
public struct BalanceResponse: Codable, Equatable {
    public let totalAmount: [String: Double]
    public let totalCashAmount: [String: Double]
    public let totalWithdrawableAmount: [String: Double]
    public let totalRealAmount: [String: Double]
    public let totalBonusAmount: [String: Double]
    public let items: [BalanceItem]

    public init(totalAmount: [String: Double], totalCashAmount: [String: Double], totalWithdrawableAmount: [String: Double], totalRealAmount: [String: Double], totalBonusAmount: [String: Double], items: [BalanceItem]) {
        self.totalAmount = totalAmount
        self.totalCashAmount = totalCashAmount
        self.totalWithdrawableAmount = totalWithdrawableAmount
        self.totalRealAmount = totalRealAmount
        self.totalBonusAmount = totalBonusAmount
        self.items = items
    }
}

/// Represents a single item within the player's balance details.
public struct BalanceItem: Codable, Equatable {
    public let type: String
    public let amount: Double
    public let currency: String?
    public let productType: String?
    public let sessionTimestamp: String? // Assuming String for now, could be Date if format known
    public let walletAccountType: String?
    public let sessionId: String?
    public let creditLine: Double? // Assuming Double, could be String

    public init(type: String, amount: Double, currency: String?, productType: String?, sessionTimestamp: String?, walletAccountType: String?, sessionId: String?, creditLine: Double?) {
        self.type = type
        self.amount = amount
        self.currency = currency
        self.productType = productType
        self.sessionTimestamp = sessionTimestamp
        self.walletAccountType = walletAccountType
        self.sessionId = sessionId
        self.creditLine = creditLine
    }
}