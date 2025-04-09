import Foundation

struct TransactionHistoryInfo: Codable {
    var generalFields: TransactionHistoryGeneralFields?
    var paymentFields: [String: String]?
    var logos: [PaymentMethodLogo]?

    enum CodingKeys: String, CodingKey {
        case generalFields = "GeneralFields"
        case paymentFields = "PaymentFields"
        case logos = "Logos"
    }
}
