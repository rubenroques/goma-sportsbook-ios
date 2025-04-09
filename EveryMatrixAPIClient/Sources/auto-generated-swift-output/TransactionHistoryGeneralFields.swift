import Foundation

struct TransactionHistoryGeneralFields: Codable {
    var code: String?
    var created: String?
    var status: String?
    var type: String?
    var paymentMethod: String?
    var amount: Double?
    var currency: String?
    var feeAmount: Double?
    var canCancel: Bool?
    var rejectionNote: String?

    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case created = "Created"
        case status = "Status"
        case type = "Type"
        case paymentMethod = "PaymentMethod"
        case amount = "Amount"
        case currency = "Currency"
        case feeAmount = "FeeAmount"
        case canCancel = "CanCancel"
        case rejectionNote = "RejectionNote"
    }
}
