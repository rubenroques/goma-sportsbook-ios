import Foundation

struct PlayerLimitScheduleV1: Codable {
    var id: String?
    var ins: String?
    var playerLimitId: String?
    var applyAt: String?
    var updateStatus: String?
    var updateAmount: Double?
    var isCoolOffCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case ins
        case playerLimitId
        case applyAt
        case updateStatus
        case updateAmount
        case isCoolOffCompleted
    }
}
