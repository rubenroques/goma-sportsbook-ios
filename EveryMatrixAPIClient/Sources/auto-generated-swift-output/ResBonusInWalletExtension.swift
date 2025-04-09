import Foundation

struct ResBonusInWalletExtension: Codable {
    var presentation: ResPresentation?
    var wallet: ResWallet?

    enum CodingKeys: String, CodingKey {
        case presentation
        case wallet
    }
}
