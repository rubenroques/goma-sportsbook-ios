
import Foundation

struct Country: Codable, Hashable {
    var name: String
    var capital: String?
    var region: String
    var iso2Code: String
    var iso3Code: String
    var numericCode: String
    var phonePrefix: String
}
