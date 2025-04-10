import Foundation

struct Ordering: Codable {
    var isGroupingEnabled: Bool?
    var defaultPaymentMethodsOrder: [String]?
    var groups: [Group]?
    var country: String?

    enum CodingKeys: String, CodingKey {
        case isGroupingEnabled = "IsGroupingEnabled"
        case defaultPaymentMethodsOrder = "DefaultPaymentMethodsOrder"
        case groups = "Groups"
        case country = "Country"
    }
}
