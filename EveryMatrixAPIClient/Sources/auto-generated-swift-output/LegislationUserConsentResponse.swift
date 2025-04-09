import Foundation

struct LegislationUserConsentResponse: Codable {
    var userId: Int64?
    var consentTypeId: Int64?
    var tagCode: String?
    var expirationDate: String?
    var status: Int32?
    var friendlyName: String?

    enum CodingKeys: String, CodingKey {
        case userId = "userID"
        case consentTypeId
        case tagCode
        case expirationDate
        case status
        case friendlyName
    }
}
