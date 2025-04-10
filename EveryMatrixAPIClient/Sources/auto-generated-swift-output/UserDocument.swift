import Foundation

struct UserDocument: Codable {
    var id: Int64?
    var userId: Int64?
    var docSeries: String?
    var docNumber: String?
    var docStatus: String?
    var docExpirationDate: String?
    var docType: String?
    var modified: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case docSeries
        case docNumber
        case docStatus
        case docExpirationDate
        case docType
        case modified
    }
}
