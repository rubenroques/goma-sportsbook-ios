import Foundation

struct CumulativeSessionLimitResponse: Codable {
    var period: String?
    var minutes: Int32?
    var updateMinutes: Int32?
    var isModified: Bool?
    var expiryDate: String?
    var expiryIsoTimestamp: String?

    enum CodingKeys: String, CodingKey {
        case period
        case minutes
        case updateMinutes
        case isModified
        case expiryDate
        case expiryIsoTimestamp
    }
}
