import Foundation

struct PaginationResponse: Codable {
    var first: String?
    var next: String?
    var previous: String?
    var last: String?

    enum CodingKeys: String, CodingKey {
        case first
        case next
        case previous
        case last
    }
}
