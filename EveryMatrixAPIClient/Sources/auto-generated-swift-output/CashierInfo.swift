import Foundation

struct CashierInfo: Codable {
    var url: String?

    enum CodingKeys: String, CodingKey {
        case url = "Url"
    }
}
