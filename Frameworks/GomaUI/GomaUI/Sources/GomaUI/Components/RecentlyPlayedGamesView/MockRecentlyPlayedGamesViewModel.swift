import Combine
import Foundation

public class MockRecentlyPlayedGamesViewModel: RecentlyPlayedGamesViewModelProtocol {
    
    // MARK: - Properties
    public let sectionData: (id: String, title: String, games: [RecentlyPlayedGameData])
    
    // MARK: - Publishers
    @Published private var games: [RecentlyPlayedGameData]
    @Published private var title: String
    
    public var gamesPublisher: AnyPublisher<[RecentlyPlayedGameData], Never> {
        $games.eraseToAnyPublisher()
    }
    
    public var titlePublisher: AnyPublisher<String, Never> {
        $title.eraseToAnyPublisher()
    }
    
    public var sectionId: String {
        sectionData.id
    }
    
    // MARK: - Initialization
    public init(sectionId: String, title: String, games: [RecentlyPlayedGameData]) {
        self.sectionData = (id: sectionId, title: title, games: games)
        self.games = games
        self.title = title
    }
    
    // MARK: - Actions
    public func gameSelected(_ gameId: String) {
        print("Game selected: \(gameId)")
        // Mock action - could trigger navigation or analytics
        if let game = games.first(where: { $0.id == gameId }) {
            print("Opening game: \(game.name) by \(game.provider)")
        }
    }
    
    public func refreshGames() {
        // Mock refresh - could reload from network
        print("Refreshing recently played games...")
        // For demo purposes, shuffle the current games
        games = games.shuffled()
    }
    
    // MARK: - State Update Methods (for testing)
    public func updateGames(_ newGames: [RecentlyPlayedGameData]) {
        games = newGames
    }
    
    public func updateTitle(_ newTitle: String) {
        title = newTitle
    }
    
    public func addGame(_ game: RecentlyPlayedGameData) {
        // Add to beginning (most recent)
        games.insert(game, at: 0)
        // Keep only last 10 games
        if games.count > 10 {
            games = Array(games.prefix(10))
        }
    }
    
    public func removeGame(withId gameId: String) {
        games.removeAll { $0.id == gameId }
    }
}

// MARK: - Factory Methods
extension MockRecentlyPlayedGamesViewModel {
    
    public static var defaultRecentlyPlayed: MockRecentlyPlayedGamesViewModel {
        let games = [
            RecentlyPlayedGameData(
                id: "gonzo-quest-001",
                name: "Gonzo's Quest",
                provider: "Netent",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/gonzo-quest"
            ),
            RecentlyPlayedGameData(
                id: "starburst-002",
                name: "Starburst",
                provider: "Netent",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/starburst"
            ),
            RecentlyPlayedGameData(
                id: "book-of-dead-003",
                name: "Book of Dead",
                provider: "Play'n GO",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/book-of-dead"
            ),
            RecentlyPlayedGameData(
                id: "big-bass-bonanza-004",
                name: "Big Bass Bonanza",
                provider: "Pragmatic Play",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/big-bass-bonanza"
            ),
            RecentlyPlayedGameData(
                id: "sweet-bonanza-005",
                name: "Sweet Bonanza",
                provider: "Pragmatic Play",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/sweet-bonanza"
            )
        ]
        
        return MockRecentlyPlayedGamesViewModel(
            sectionId: "recently-played",
            title: "Recently Played",
            games: games
        )
    }
    
    public static var emptyRecentlyPlayed: MockRecentlyPlayedGamesViewModel {
        return MockRecentlyPlayedGamesViewModel(
            sectionId: "recently-played",
            title: "Recently Played",
            games: []
        )
    }
    
    public static var fewGames: MockRecentlyPlayedGamesViewModel {
        let games = [
            RecentlyPlayedGameData(
                id: "aviator-001",
                name: "Aviator",
                provider: "Spribe",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/aviator"
            ),
            RecentlyPlayedGameData(
                id: "crazy-time-002",
                name: "Crazy Time",
                provider: "Evolution Gaming",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/crazy-time"
            )
        ]
        
        return MockRecentlyPlayedGamesViewModel(
            sectionId: "recently-played",
            title: "Recently Played",
            games: games
        )
    }
    
    public static var longGameNames: MockRecentlyPlayedGamesViewModel {
        let games = [
            RecentlyPlayedGameData(
                id: "long-name-001",
                name: "The Great Adventure of the Golden Treasure",
                provider: "Long Provider Name Studio",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/long-name"
            ),
            RecentlyPlayedGameData(
                id: "another-long-002",
                name: "Super Mega Ultra Big Win Jackpot Deluxe",
                provider: "Another Very Long Provider Name",
                imageURL: "casinoGameDemo",
                gameURL: "https://casino.example.com/games/another-long"
            )
        ]
        
        return MockRecentlyPlayedGamesViewModel(
            sectionId: "recently-played",
            title: "Recently Played",
            games: games
        )
    }
    
    // MARK: - Custom Factory
    public static func customRecentlyPlayed(
        sectionId: String,
        title: String,
        games: [RecentlyPlayedGameData]
    ) -> MockRecentlyPlayedGamesViewModel {
        return MockRecentlyPlayedGamesViewModel(
            sectionId: sectionId,
            title: title,
            games: games
        )
    }
}