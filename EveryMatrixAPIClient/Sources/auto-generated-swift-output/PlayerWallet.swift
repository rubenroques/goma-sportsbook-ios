import Foundation

struct PlayerWallet: Codable {
    var name: String?
    var bonusMoney: Double?
    var bonusMoneyCurrency: String?
    var lockedMoney: Double?
    var lockedMoneyCurrency: String?
    var realMoney: Double?
    var realMoneyCurrency: String?
    var withdrawableMoney: Double?
    var withdrawableMoneyCurrency: String?

    enum CodingKeys: String, CodingKey {
        case name
        case bonusMoney
        case bonusMoneyCurrency
        case lockedMoney
        case lockedMoneyCurrency
        case realMoney
        case realMoneyCurrency
        case withdrawableMoney
        case withdrawableMoneyCurrency
    }
}
