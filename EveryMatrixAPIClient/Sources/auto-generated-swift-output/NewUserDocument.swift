import Foundation

struct NewUserDocument: Codable {
    var docSeries: String?
    var docNumber: String?
    var docStatus: String?
    var docExpirationDate: String?
    var docType: String?

    enum CodingKeys: String, CodingKey {
        case docSeries
        case docNumber
        case docStatus
        case docExpirationDate
        case docType
    }
}
