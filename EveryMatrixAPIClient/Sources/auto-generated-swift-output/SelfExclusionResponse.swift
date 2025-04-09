import Foundation

struct SelfExclusionResponse: Codable {
    var type: String?
    var expiryDate: String?
    var expiryIsoTimestamp: String?
    var period: String?
    var sevenDaysPeriodNum: Int32?
    var coolOffReason: String?
    var coolOffDescription: String?
    var unsatisfiedReason: String?
    var unsatisfiedDescription: String?
    var allowNewsEmail: Bool?
    var allowSmsOffer: Bool?
    var selfExclusionReason: String?

    enum CodingKeys: String, CodingKey {
        case type
        case expiryDate
        case expiryIsoTimestamp
        case period
        case sevenDaysPeriodNum
        case coolOffReason
        case coolOffDescription
        case unsatisfiedReason
        case unsatisfiedDescription
        case allowNewsEmail
        case allowSmsOffer
        case selfExclusionReason
    }
}
