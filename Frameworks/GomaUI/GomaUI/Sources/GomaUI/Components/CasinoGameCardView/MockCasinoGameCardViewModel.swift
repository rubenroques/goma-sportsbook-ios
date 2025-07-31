import Combine
import Foundation

public class MockCasinoGameCardViewModel: CasinoGameCardViewModelProtocol {
    
    // MARK: - Properties
    public let gameData: CasinoGameCardData
    
    // MARK: - Publishers
    @Published private var displayState: CasinoGameCardDisplayState
    @Published private var gameName: String
    @Published private var imageURL: String?
    @Published private var rating: Double
    
    public var displayStatePublisher: AnyPublisher<CasinoGameCardDisplayState, Never> {
        $displayState.eraseToAnyPublisher()
    }
    
    public var gameNamePublisher: AnyPublisher<String, Never> {
        $gameName.eraseToAnyPublisher()
    }
    
    public var imageURLPublisher: AnyPublisher<String?, Never> {
        $imageURL.eraseToAnyPublisher()
    }
    
    public var ratingPublisher: AnyPublisher<Double, Never> {
        $rating.eraseToAnyPublisher()
    }
    
    public var gameId: String {
        gameData.id
    }
    
    public var gameURL: String {
        gameData.gameURL
    }
    
    // MARK: - Initialization
    public init(gameData: CasinoGameCardData) {
        self.gameData = gameData
        self.displayState = .normal
        self.gameName = gameData.name
        self.imageURL = gameData.imageURL
        self.rating = gameData.rating
    }
    
    // MARK: - Image Loading Methods
    public func imageLoadingFailed() {
        displayState = .imageError
    }
    
    public func imageLoadingSucceeded() {
        displayState = .normal
    }
    
    // MARK: - State Update Methods (for testing)
    public func setDisplayState(_ state: CasinoGameCardDisplayState) {
        displayState = state
    }
    
    public func updateGameName(_ name: String) {
        gameName = name
    }
    
    public func updateRating(_ newRating: Double) {
        rating = max(0.0, min(5.0, newRating))
    }
}

// MARK: - Factory Methods
extension MockCasinoGameCardViewModel {
    
    public static var plinkGoal: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "plink-goal-001",
            name: "Plink Goal",
            gameURL: "https://casino.example.com/games/plink-goal",
            imageURL: "casinoGameDemo", // Use demo image
            rating: 4.5
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var aviator: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "aviator-002",
            name: "Aviator",
            gameURL: "https://casino.example.com/games/aviator",
            imageURL: "casinoGameDemo", // Use demo image
            rating: 4.8
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var beastBelow: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "beast-below-003",
            name: "Beast Below",
            gameURL: "https://casino.example.com/games/beast-below",
            imageURL: "casinoGameDemo", // Use demo image
            rating: 4.2
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var loadingGame: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "loading-004",
            name: "Loading Game",
            gameURL: "https://casino.example.com/games/loading",
            imageURL: nil,
            rating: 3.5
        )
        let viewModel = MockCasinoGameCardViewModel(gameData: gameData)
        viewModel.setDisplayState(.loading)
        return viewModel
    }
    
    public static var imageFailedGame: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "failed-005",
            name: "Image Failed Game",
            gameURL: "https://casino.example.com/games/failed",
            imageURL: "https://invalid-url.com/image.jpg", // Invalid URL to trigger failure
            rating: 3.0
        )
        let viewModel = MockCasinoGameCardViewModel(gameData: gameData)
        viewModel.setDisplayState(.imageError)
        return viewModel
    }
    
    // MARK: - Custom Factory
    public static func customGame(
        id: String,
        name: String,
        gameURL: String,
        imageURL: String? = nil,
        rating: Double
    ) -> MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: id,
            name: name,
            gameURL: gameURL,
            imageURL: imageURL,
            rating: rating
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
}