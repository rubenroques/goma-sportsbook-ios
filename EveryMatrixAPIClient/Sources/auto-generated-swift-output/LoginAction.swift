import Foundation

struct LoginAction: Codable {
    var id: Int32?
    var name: String?
    var action: JSONObject?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case action
    }
}
