import Foundation

struct Transaction: Codable {
    var merchantId: Int32?
    var code: String?
    var type: String?
    var externalCustomerId: String?
    var status: Status?
    var amounts: [Amounts]?

    enum CodingKeys: String, CodingKey {
        case merchantId = "MerchantId"
        case code = "Code"
        case type = "Type"
        case externalCustomerId = "ExternalCustomerId"
        case status = "Status"
        case amounts = "Amounts"
    }
}
