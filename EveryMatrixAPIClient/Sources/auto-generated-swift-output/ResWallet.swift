import Foundation

struct ResWallet: Codable {
    var maxWinAmount: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case maxWinAmount
    }
}
