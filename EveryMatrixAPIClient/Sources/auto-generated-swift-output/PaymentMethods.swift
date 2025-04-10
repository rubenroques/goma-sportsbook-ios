import Foundation

struct PaymentMethods: Codable {
    var paymentMethods: [PaymentMethods]?
    var ordering: Ordering?
    var bannersConfiguration: BannersConfiguration?

    enum CodingKeys: String, CodingKey {
        case paymentMethods = "PaymentMethods"
        case ordering = "Ordering"
        case bannersConfiguration = "BannersConfiguration"
    }
}
