import Foundation

struct AccountReq: Codable {
    var token: String?
    var data: [String: String]?

    enum CodingKeys: String, CodingKey {
        case token = "Token"
        case data = "Data"
    }
}
