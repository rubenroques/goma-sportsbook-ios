import Foundation

struct PlayerProfileConsents: Codable {
    var acceptNewsEmail: Bool?
    var acceptSMSOffers: Bool?

    enum CodingKeys: String, CodingKey {
        case acceptNewsEmail
        case acceptSMSOffers
    }
}
