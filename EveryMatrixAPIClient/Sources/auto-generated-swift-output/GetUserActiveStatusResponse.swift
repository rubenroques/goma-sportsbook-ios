import Foundation

struct GetUserActiveStatusResponse: Codable {
    var userId: String?
    var newStatus: String?
    var blockType: String?
    var sessionId: String?
    var sessionUserid: Int64?
    var contextDomainId: Int64?

    enum CodingKeys: String, CodingKey {
        case userId = "UserID"
        case newStatus = "NewStatus"
        case blockType = "BlockType"
        case sessionId = "SESSION_ID"
        case sessionUserid = "SESSION_USERID"
        case contextDomainId = "ContextDomainID"
    }
}
