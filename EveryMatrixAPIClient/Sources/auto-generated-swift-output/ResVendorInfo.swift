import Foundation

struct ResVendorInfo: Codable {
    var games: [JSONObject]?

    enum CodingKeys: String, CodingKey {
        case games
    }
}
