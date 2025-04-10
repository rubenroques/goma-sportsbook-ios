import Foundation

struct WageringProgress: Codable {
    var currentLevel: Int64?
    var currentLevelIncrement: Int64?
    var gap: Double?

    enum CodingKeys: String, CodingKey {
        case currentLevel
        case currentLevelIncrement
        case gap
    }
}
