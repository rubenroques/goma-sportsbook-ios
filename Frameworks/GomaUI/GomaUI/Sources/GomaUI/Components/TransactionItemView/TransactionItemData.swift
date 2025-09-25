import Foundation
import UIKit

public struct TransactionItemData {

    // MARK: - Properties

    public let id: String
    public let category: String
    public let status: TransactionStatus?
    public let amount: Double
    public let currency: String
    public let transactionId: String
    public let date: Date
    public let balance: Double?
    public let isPositive: Bool

    // MARK: - Initialization

    public init(
        id: String = UUID().uuidString,
        category: String,
        status: TransactionStatus? = nil,
        amount: Double,
        currency: String,
        transactionId: String,
        date: Date,
        balance: Double? = nil
    ) {
        self.id = id
        self.category = category
        self.status = status
        self.amount = amount
        self.currency = currency
        self.transactionId = transactionId
        self.date = date
        self.balance = balance
        self.isPositive = amount >= 0
    }

    // MARK: - Computed Properties

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        let prefix = isPositive ? "+" : "-"
        let absAmount = abs(amount)

        if let formattedNumber = formatter.string(from: NSNumber(value: absAmount)) {
            return "\(prefix)\(currency) \(formattedNumber)"
        }
        return "\(prefix)\(currency) \(absAmount)"
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd/MM - HH:mm"
        return formatter.string(from: date)
    }

    public var formattedBalance: String {
        guard let balance = balance else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: balance)) {
            return "Balance: \(currency) \(formattedNumber)"
        }
        return "Balance: \(currency) \(balance)"
    }
}