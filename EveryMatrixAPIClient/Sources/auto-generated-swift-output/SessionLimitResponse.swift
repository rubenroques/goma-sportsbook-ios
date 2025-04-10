import Foundation

struct SessionLimitResponse: Codable {
    var amount: Int32?
    var updateAmount: Int32?
    var isModified: Bool?
    var expiryDate: String?
    var expiryIsoTimestamp: String?
    var minutes: Float?
    var updateMinutes: Float?

    enum CodingKeys: String, CodingKey {
        case amount
        case updateAmount
        case isModified
        case expiryDate
        case expiryIsoTimestamp
        case minutes
        case updateMinutes
    }
}
