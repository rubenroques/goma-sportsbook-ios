import Foundation

struct PlayerRegisterBirthV1: Codable {
    var day: Int32?
    var month: Int32?
    var year: Int32?

    enum CodingKeys: String, CodingKey {
        case day
        case month
        case year
    }
}
