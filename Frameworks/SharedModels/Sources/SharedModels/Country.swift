import Foundation

public struct Country: Codable, Equatable, Hashable {

    public var id: String?
    public var name: String
    public var capital: String?
    public var region: String
    public var iso2Code: String
    public var iso3Code: String
    public var numericCode: String
    public var phonePrefix: String
    public var frenchName: String

    public init(id: String? = nil, name: String, capital: String? = nil, region: String = "", iso2Code: String, iso3Code: String = "", numericCode: String = "", phonePrefix: String = "", frenchName: String = "") {
        self.id = id
        self.name = name
        self.capital = capital
        self.region = region
        self.iso2Code = iso2Code
        self.iso3Code = iso3Code
        self.numericCode = numericCode
        self.phonePrefix = phonePrefix
        self.frenchName = frenchName
    }

}

