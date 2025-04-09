import Foundation

struct Group: Codable {
    var paymentCategory: String?
    var paymentMethodsOrder: [String]?

    enum CodingKeys: String, CodingKey {
        case paymentCategory = "PaymentCategory"
        case paymentMethodsOrder = "PaymentMethodsOrder"
    }
}
