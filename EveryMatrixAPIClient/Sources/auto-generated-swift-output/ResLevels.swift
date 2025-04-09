import Foundation

struct ResLevels: Codable {
    var maxRepeats: Int32?
    var increment: [String: JSONObject]?

    enum CodingKeys: String, CodingKey {
        case maxRepeats
        case increment
    }
}
