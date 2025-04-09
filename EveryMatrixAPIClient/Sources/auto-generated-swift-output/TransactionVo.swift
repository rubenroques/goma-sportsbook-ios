import Foundation

struct TransactionVo: Codable {
    var paymentMethod: String?
    var amount: Double?
    var currency: String?
    var bonusCode: String?
    var customFields: [String: String]?

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "PaymentMethod"
        case amount = "Amount"
        case currency = "Currency"
        case bonusCode = "BonusCode"
        case customFields = "CustomFields"
    }
}
