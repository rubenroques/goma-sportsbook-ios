import Combine
import Foundation

public class MockCasinoCategorySectionViewModel: CasinoCategorySectionViewModelProtocol {
    
    // MARK: - Properties
    public let sectionData: CasinoCategorySectionData
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels (Vertical Pattern ✅)
    // Parent ViewModel creates children for its subviews within the same component
    public let categoryBarViewModel: CasinoCategoryBarViewModelProtocol
    private var _gameCardViewModels: [CasinoGameCardViewModelProtocol]
    
    public var gameCardViewModels: [CasinoGameCardViewModelProtocol] {
        _gameCardViewModels
    }
    
    // MARK: - Publishers
    @Published private var gameCardViewModelsState: [CasinoGameCardViewModelProtocol]
    
    public var gameCardViewModelsPublisher: AnyPublisher<[CasinoGameCardViewModelProtocol], Never> {
        $gameCardViewModelsState.eraseToAnyPublisher()
    }
    
    public var sectionId: String {
        sectionData.id
    }
    
    public var categoryTitle: String {
        sectionData.categoryTitle
    }
    
    // MARK: - Initialization
    public init(sectionData: CasinoCategorySectionData) {
        self.sectionData = sectionData
        
        // ✅ CORRECT: Parent ViewModel creates child ViewModels for its subviews
        
        // Create category bar ViewModel
        let categoryBarData = CasinoCategoryBarData(
            id: sectionData.id,
            title: sectionData.categoryTitle,
            buttonText: sectionData.categoryButtonText
        )
        self.categoryBarViewModel = MockCasinoCategoryBarViewModel(categoryData: categoryBarData)
        
        // Create game card ViewModels for each game
        self._gameCardViewModels = sectionData.games.map { gameData in
            MockCasinoGameCardViewModel(gameData: gameData)
        }
        
        // Initialize published state
        self.gameCardViewModelsState = _gameCardViewModels
        
        // Setup inter-communication between child ViewModels
        setupChildCommunication()
    }
    
    // MARK: - Child ViewModel Communication
    private func setupChildCommunication() {
        // Setup callbacks from child ViewModels to parent
        
        // Category bar button tapped - handled in this parent ViewModel
        // (The view will call categoryButtonTapped() directly)
        
        // Game selection - handled in this parent ViewModel  
        // (The view will call gameSelected(_:) directly)
        
        // Any cross-child communication would be handled here
        // For example, if selecting a game should update the category bar
    }
    
    // MARK: - Actions
    public func gameSelected(_ gameId: String) {
        print("Game selected in section '\(categoryTitle)': \(gameId)")
        
        // Business logic for game selection
        if let selectedGame = sectionData.games.first(where: { $0.id == gameId }) {
            print("Opening game: \(selectedGame.name) by \(selectedGame.provider)")
            
            // Could update analytics, track user behavior, etc.
            trackGameSelection(gameId: gameId, categoryId: sectionId)
        }
        
        // Could notify other child ViewModels if needed
        // For example, update recently played games
    }
    
    public func categoryButtonTapped() {
        print("Category button tapped for: \(categoryTitle)")
        
        // Business logic for category button tap
        // Could trigger navigation to full category view, filtering, etc.
        trackCategoryButtonTap(categoryId: sectionId)
    }
    
    public func refreshGames() {
        print("Refreshing games for category: \(categoryTitle)")
        
        // Mock refresh - could reload from network
        // For demo purposes, shuffle the current games
        _gameCardViewModels = _gameCardViewModels.shuffled()
        gameCardViewModelsState = _gameCardViewModels
    }
    
    // MARK: - State Update Methods (for testing)
    public func updateGames(_ newGames: [CasinoGameCardData]) {
        // Create new ViewModels for new games
        _gameCardViewModels = newGames.map { gameData in
            MockCasinoGameCardViewModel(gameData: gameData)
        }
        gameCardViewModelsState = _gameCardViewModels
    }
    
    public func addGame(_ gameData: CasinoGameCardData) {
        let newGameViewModel = MockCasinoGameCardViewModel(gameData: gameData)
        _gameCardViewModels.append(newGameViewModel)
        gameCardViewModelsState = _gameCardViewModels
    }
    
    public func removeGame(withId gameId: String) {
        _gameCardViewModels.removeAll { viewModel in
            viewModel.gameId == gameId
        }
        gameCardViewModelsState = _gameCardViewModels
    }
    
    // MARK: - Analytics (Mock)
    private func trackGameSelection(gameId: String, categoryId: String) {
        // Mock analytics tracking
        print("Analytics: Game '\(gameId)' selected from category '\(categoryId)'")
    }
    
    private func trackCategoryButtonTap(categoryId: String) {
        // Mock analytics tracking
        print("Analytics: Category button tapped for '\(categoryId)'")
    }
}

// MARK: - Factory Methods
extension MockCasinoCategorySectionViewModel {
    
    public static var newGamesSection: MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "new-game-001",
                name: "Dragon's Fortune",
                gameURL: "https://casino.example.com/games/dragons-fortune",
                imageURL: "casinoGameDemo",
                rating: 4.8,
                provider: "Red Tiger Gaming",
                minStake: "XAF 50"
            ),
            CasinoGameCardData(
                id: "new-game-002", 
                name: "Mega Wheel",
                gameURL: "https://casino.example.com/games/mega-wheel",
                imageURL: "casinoGameDemo",
                rating: 4.6,
                provider: "Pragmatic Play",
                minStake: "XAF 100"
            ),
            CasinoGameCardData(
                id: "new-game-003",
                name: "Crystal Quest",
                gameURL: "https://casino.example.com/games/crystal-quest",
                imageURL: "casinoGameDemo",
                rating: 4.4,
                provider: "Thunderkick",
                minStake: "XAF 25"
            ),
            CasinoGameCardData(
                id: "new-game-004",
                name: "Lucky Pharaoh",
                gameURL: "https://casino.example.com/games/lucky-pharaoh",
                imageURL: "casinoGameDemo",
                rating: 4.7,
                provider: "Novomatic",
                minStake: "XAF 200"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "new-games",
            categoryTitle: "New Games",
            categoryButtonText: "All 41",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    public static var popularGamesSection: MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "popular-001",
                name: "Starburst",
                gameURL: "https://casino.example.com/games/starburst",
                imageURL: "casinoGameDemo",
                rating: 4.9,
                provider: "NetEnt",
                minStake: "XAF 10"
            ),
            CasinoGameCardData(
                id: "popular-002",
                name: "Book of Dead",
                gameURL: "https://casino.example.com/games/book-of-dead",
                imageURL: "casinoGameDemo",
                rating: 4.8,
                provider: "Play'n GO",
                minStake: "XAF 20"
            ),
            CasinoGameCardData(
                id: "popular-003",
                name: "Gonzo's Quest",
                gameURL: "https://casino.example.com/games/gonzo-quest",
                imageURL: "casinoGameDemo",
                rating: 4.7,
                provider: "NetEnt",
                minStake: "XAF 50"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "popular-games",
            categoryTitle: "Popular Games",
            categoryButtonText: "All 127",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    public static var slotGamesSection: MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "slot-001",
                name: "Mega Moolah",
                gameURL: "https://casino.example.com/games/mega-moolah",
                imageURL: "casinoGameDemo",
                rating: 4.5,
                provider: "Microgaming",
                minStake: "XAF 25"
            ),
            CasinoGameCardData(
                id: "slot-002",
                name: "Divine Fortune",
                gameURL: "https://casino.example.com/games/divine-fortune",
                imageURL: "casinoGameDemo",
                rating: 4.6,
                provider: "NetEnt",
                minStake: "XAF 40"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "slot-games",
            categoryTitle: "Slot Games",
            categoryButtonText: "All 89",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    public static var emptySection: MockCasinoCategorySectionViewModel {
        let sectionData = CasinoCategorySectionData(
            id: "empty-section",
            categoryTitle: "Empty Category",
            categoryButtonText: "All 0",
            games: []
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    // MARK: - Custom Factory
    public static func customSection(
        id: String,
        categoryTitle: String,
        categoryButtonText: String,
        games: [CasinoGameCardData]
    ) -> MockCasinoCategorySectionViewModel {
        let sectionData = CasinoCategorySectionData(
            id: id,
            categoryTitle: categoryTitle,
            categoryButtonText: categoryButtonText,
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
}