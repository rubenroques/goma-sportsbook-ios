import Combine
import UIKit

// MARK: - Data Models
public struct RecentlyPlayedGameData: Equatable, Hashable, Identifiable {
    public let id: String           // game identifier
    public let name: String         // game name (e.g., "Gonzo's Quest")
    public let provider: String?    // provider name (e.g., "Netent") - optional, not displayed if nil
    public let imageURL: String?    // game image URL or bundle name
    public let gameURL: String      // URL for launching the game
    
    public init(
        id: String,
        name: String,
        provider: String? = nil,
        imageURL: String? = nil,
        gameURL: String
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.imageURL = imageURL
        self.gameURL = gameURL
    }
}

// MARK: - View Model Protocol
public protocol RecentlyPlayedGamesViewModelProtocol: AnyObject {
    // Publishers for reactive updates
    var gamesPublisher: AnyPublisher<[RecentlyPlayedGameData], Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    
    // Read-only properties
    var sectionId: String { get }
    
    // Actions
    func gameSelected(_ gameId: String)
    func refreshGames()
}