import Foundation

/// Data model for a casino game displayed as a simple image card
public struct CasinoGameImageData: Equatable, Hashable, Identifiable {
    public let id: String
    public let imageURL: String?
    public let gameURL: String

    public init(id: String, imageURL: String?, gameURL: String) {
        self.id = id
        self.imageURL = imageURL
        self.gameURL = gameURL
    }
}
