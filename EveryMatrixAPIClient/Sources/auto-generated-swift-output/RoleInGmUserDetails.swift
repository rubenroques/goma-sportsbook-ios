import Foundation

struct RoleInGmUserDetails: Codable {
    var description: String?
    var authorDisplayName: String?
    var name: String?
    var userRoleCreated: String?
    var userRoleId: Int64?
    var activeStatus: Int32?

    enum CodingKeys: String, CodingKey {
        case description
        case authorDisplayName
        case name
        case userRoleCreated
        case userRoleId
        case activeStatus
    }
}
