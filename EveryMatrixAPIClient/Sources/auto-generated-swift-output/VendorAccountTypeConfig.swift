import Foundation

struct VendorAccountTypeConfig: Codable {
    var id: Int64?
    var userId: Int64?
    var vendorIdentity: String?
    var accountType: String?
    var displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "userID"
        case vendorIdentity
        case accountType
        case displayName
    }
}
