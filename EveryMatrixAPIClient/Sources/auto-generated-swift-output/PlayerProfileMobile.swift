import Foundation

struct PlayerProfileMobile: Codable {
    var prefix: String?
    var number: String?

    enum CodingKeys: String, CodingKey {
        case prefix
        case number
    }
}
