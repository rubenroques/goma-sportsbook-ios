import Foundation

struct ReceiptInfo: Codable {
    var receiptPageCaptionDisabled: Bool?
    var receiptFields: [ReceiptFields]?

    enum CodingKeys: String, CodingKey {
        case receiptPageCaptionDisabled = "ReceiptPageCaptionDisabled"
        case receiptFields = "ReceiptFields"
    }
}
