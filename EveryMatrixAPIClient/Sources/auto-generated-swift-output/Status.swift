import Foundation

struct Status: Codable {
    var created: String?
    var verificationVersion: String?
    var status: String?
    var responseCode: String?
    var responseMessage: String?
    var comment: String?

    enum CodingKeys: String, CodingKey {
        case created = "Created"
        case verificationVersion = "VerificationVersion"
        case status = "Status"
        case responseCode = "ResponseCode"
        case responseMessage = "ResponseMessage"
        case comment = "Comment"
    }
}
