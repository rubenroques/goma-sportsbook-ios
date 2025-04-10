import Foundation

struct GetTransactionsHistoryStatuses: Codable {
    var unknown: [String]?
    var deposit: [String]?
    var withdraw: [String]?
    var refund: [String]?
    var taxDeduction: [String]?

    enum CodingKeys: String, CodingKey {
        case unknown = "Unknown"
        case deposit = "Deposit"
        case withdraw = "Withdraw"
        case refund = "Refund"
        case taxDeduction = "TaxDeduction"
    }
}
