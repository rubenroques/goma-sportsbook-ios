import Foundation

/// Data model for a casino game displayed as a simple image card
public struct CasinoGameImageData: Equatable, Hashable, Identifiable {
    public let id: String
    public let iconURL: String?     // square icon image (114x114)
    public let gameURL: String

    public init(id: String, iconURL: String?, gameURL: String) {
        self.id = id
        self.iconURL = iconURL
        self.gameURL = gameURL
    }
}
