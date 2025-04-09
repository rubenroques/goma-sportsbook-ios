import Foundation

struct Country: Codable {
    var name: String?
    var alpha2Code: String?
    var alpha3Code: String?
    var isRegAllowed: Bool?
    var numericCode: String?
    var id: Int32?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case alpha2Code = "Alpha2Code"
        case alpha3Code = "Alpha3Code"
        case isRegAllowed = "IsRegAllowed"
        case numericCode = "NumericCode"
        case id = "ID"
    }
}
