import Foundation

struct References: Codable {
    var type: String?
    var created: String?
    var reference: String?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case created = "Created"
        case reference = "Reference"
    }
}
