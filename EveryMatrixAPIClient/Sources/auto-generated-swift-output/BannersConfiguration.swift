import Foundation

struct BannersConfiguration: Codable {
    var layout: String?
    var banners: [Banner]?

    enum CodingKeys: String, CodingKey {
        case layout = "Layout"
        case banners = "Banners"
    }
}
