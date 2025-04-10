import Foundation

struct ReceiptFields: Codable {
    var type: String?
    var name: String?
    var description: String?
    var defaultValue: String?
    var useCopyButton: Bool?
    var usePrintButton: Bool?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case name = "Name"
        case description = "Description"
        case defaultValue = "DefaultValue"
        case useCopyButton = "UseCopyButton"
        case usePrintButton = "UsePrintButton"
    }
}
