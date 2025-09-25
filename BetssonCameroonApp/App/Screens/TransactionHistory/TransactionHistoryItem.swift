
import Foundation

struct TransactionHistoryItem: Hashable, Identifiable {
    let id: String
    let type: TransactionHistoryItemType
    let date: Date
    let amount: Double
    let currency: String
    let status: String
    let description: String
    let details: String?
    let iconName: String
    let balance: Double?
}

enum TransactionHistoryItemType: Hashable {
    case banking(BankingTransactionType)
    case wagering(WageringTransactionType)

    var category: TransactionCategory {
        switch self {
        case .banking:
            return .payments
        case .wagering:
            return .games
        }
    }

    var displayName: String {
        switch self {
        case .banking(let bankingType):
            return bankingType.displayName
        case .wagering(let wageringType):
            return wageringType.displayName
        }
    }

    var iconName: String {
        switch self {
        case .banking(let bankingType):
            return bankingType.iconName
        case .wagering(let wageringType):
            return wageringType.iconName
        }
    }
}

enum TransactionCategory: String, CaseIterable {
    case all = "all"
    case payments = "payments"
    case games = "games"

    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .payments:
            return "Payments"
        case .games:
            return "Games"
        }
    }
}

extension TransactionHistoryItem {
    static func from(bankingTransaction: BankingTransaction) -> TransactionHistoryItem {
        let description = bankingTransaction.type.displayName
        let details = bankingTransaction.vendorReference ?? bankingTransaction.externalReference

        return TransactionHistoryItem(
            id: "#T"+bankingTransaction.id,
            type: .banking(bankingTransaction.type),
            date: bankingTransaction.created,
            amount: bankingTransaction.realAmount,
            currency: bankingTransaction.currency,
            status: bankingTransaction.status,
            description: description,
            details: details,
            iconName: bankingTransaction.type.iconName,
            balance: nil // Banking transactions don't have balance information
        )
    }

    static func from(wageringTransaction: WageringTransaction) -> TransactionHistoryItem {
        let description = wageringTransaction.transName ?? wageringTransaction.transType.displayName
        let details = wageringTransaction.gameId

        return TransactionHistoryItem(
            id: "#T"+wageringTransaction.id,
            type: .wagering(wageringTransaction.transType),
            date: wageringTransaction.createdDate,
            amount: wageringTransaction.realAmount,
            currency: wageringTransaction.currencyCode,
            status: "Completed", // Wagering transactions are always completed when we receive them
            description: description,
            details: details,
            iconName: wageringTransaction.transType.iconName,
            balance: wageringTransaction.balance // Use the actual balance from wagering transaction
        )
    }
}
