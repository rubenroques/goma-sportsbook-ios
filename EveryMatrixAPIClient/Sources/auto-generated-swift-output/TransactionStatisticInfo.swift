import Foundation

struct TransactionStatisticInfo: Codable {
    var currency: String?
    var depositSum: Double?
    var withdrawalSum: Double?
    var profileSum: Double?

    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case depositSum = "DepositSum"
        case withdrawalSum = "WithdrawalSum"
        case profileSum = "ProfileSum"
    }
}
