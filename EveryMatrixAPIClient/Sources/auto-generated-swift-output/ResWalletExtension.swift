import Foundation

struct ResWalletExtension: Codable {
    var bonus: ResBonusInWalletExtension?
    var grantedPlayerCurrencyAmount: Double?

    enum CodingKeys: String, CodingKey {
        case bonus
        case grantedPlayerCurrencyAmount
    }
}
