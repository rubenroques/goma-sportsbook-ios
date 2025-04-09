import Foundation

struct Banner: Codable {
    var code: String?
    var name: String?
    var type: String?
    var order: Int32?
    var desktopImageUrl: String?
    var desktopRedirectUrl: String?
    var mobileImageUrl: String?
    var mobileRedirectUrl: String?
    var position: Int32?

    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case name = "Name"
        case type = "Type"
        case order = "Order"
        case desktopImageUrl = "DesktopImageUrl"
        case desktopRedirectUrl = "DesktopRedirectUrl"
        case mobileImageUrl = "MobileImageUrl"
        case mobileRedirectUrl = "MobileRedirectUrl"
        case position = "Position"
    }
}
