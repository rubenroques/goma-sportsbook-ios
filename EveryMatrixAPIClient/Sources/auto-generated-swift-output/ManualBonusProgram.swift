import Foundation

struct ManualBonusProgram: Codable {
    var id: String?
    var realm: String?
    var domainId: Int64?
    var code: String?
    var type: String?
    var selectable: Bool?
    var minimumAmount: [String: Double]?
    var maximumAmount: [String: Double]?
    var name: String?
    var url: String?
    var description: String?
    var assets: String?
    var startTime: String?
    var endTime: String?
    var walletExtension: ResWalletExtension?

    enum CodingKeys: String, CodingKey {
        case id
        case realm
        case domainId = "domainID"
        case code
        case type
        case selectable
        case minimumAmount
        case maximumAmount
        case name
        case url
        case description
        case assets
        case startTime
        case endTime
        case walletExtension = "extension"
    }
}
