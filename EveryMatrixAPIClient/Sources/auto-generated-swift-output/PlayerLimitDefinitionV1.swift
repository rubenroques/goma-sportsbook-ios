import Foundation

struct PlayerLimitDefinitionV1: Codable {
    var id: String?
    var playerId: String?
    var domainId: String?
    var amount: Double?
    var currency: String?
    var period: String?
    var type: String?
    var products: [String]?
    var walletTypes: [String]?
    var countries: [String]?
    var schedules: [PlayerLimitScheduleV1]?

    enum CodingKeys: String, CodingKey {
        case id
        case playerId
        case domainId
        case amount
        case currency
        case period
        case type
        case products
        case walletTypes
        case countries
        case schedules
    }
}
