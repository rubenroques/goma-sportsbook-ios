import Foundation

struct ResPresentation: Codable {
    var name: String?
    var url: String?
    var description: String?
    var assets: String?

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case description
        case assets
    }
}
