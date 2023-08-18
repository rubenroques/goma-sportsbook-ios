import Foundation

public struct Country: Codable, Equatable {

    public var name: String
    public var capital: String?
    public var region: String
    public var iso2Code: String
    public var iso3Code: String
    public var numericCode: String
    public var phonePrefix: String

    public init(name: String, capital: String? = nil, region: String, iso2Code: String, iso3Code: String, numericCode: String, phonePrefix: String) {
        self.name = name
        self.capital = capital
        self.region = region
        self.iso2Code = iso2Code
        self.iso3Code = iso3Code
        self.numericCode = numericCode
        self.phonePrefix = phonePrefix
    }

}
