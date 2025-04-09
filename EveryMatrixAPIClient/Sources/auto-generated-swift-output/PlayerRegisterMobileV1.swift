import Foundation

struct PlayerRegisterMobileV1: Codable {
    var prefix: String?
    var number: String?

    enum CodingKeys: String, CodingKey {
        case prefix
        case number
    }
}
