import Foundation

struct PaymentMethodLogo: Codable {
    var logoType: String?
    var logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case logoType = "LogoType"
        case logoUrl = "LogoUrl"
    }
}
