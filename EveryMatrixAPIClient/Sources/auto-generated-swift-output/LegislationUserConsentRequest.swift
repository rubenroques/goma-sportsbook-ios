import Foundation

struct LegislationUserConsentRequest: Codable {
    var tagCode: String?
    var note: String?
    var status: Int32?

    enum CodingKeys: String, CodingKey {
        case tagCode
        case note
        case status
    }
}
