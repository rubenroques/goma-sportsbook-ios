import Foundation

struct Account: Codable {
    var maxAccounts: Double?

    enum CodingKeys: String, CodingKey {
        case maxAccounts = "MaxAccounts"
    }
}
