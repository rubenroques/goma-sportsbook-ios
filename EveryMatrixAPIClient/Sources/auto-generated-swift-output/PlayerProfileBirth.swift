import Foundation

struct PlayerProfileBirth: Codable {
    var year: Int32?
    var month: Int32?
    var day: Int32?

    enum CodingKeys: String, CodingKey {
        case year
        case month
        case day
    }
}
