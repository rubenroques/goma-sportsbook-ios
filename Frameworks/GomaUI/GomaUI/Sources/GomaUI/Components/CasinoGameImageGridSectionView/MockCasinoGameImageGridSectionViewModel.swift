import Foundation
import Combine

/// Mock implementation of CasinoGameImageGridSectionViewModelProtocol for testing and previews
public final class MockCasinoGameImageGridSectionViewModel: CasinoGameImageGridSectionViewModelProtocol {

    // MARK: - Published Properties

    @Published private var _gamePairViewModels: [CasinoGameImagePairViewModelProtocol]

    // MARK: - Protocol Properties

    public let categoryBarViewModel: CasinoCategoryBarViewModelProtocol
    public let sectionId: String
    public let categoryTitle: String

    public var gamePairViewModels: [CasinoGameImagePairViewModelProtocol] {
        _gamePairViewModels
    }

    public var gamePairViewModelsPublisher: AnyPublisher<[CasinoGameImagePairViewModelProtocol], Never> {
        $_gamePairViewModels.eraseToAnyPublisher()
    }

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void)?
    public var onCategoryButtonTapped: (() -> Void)?

    // MARK: - Initialization

    public init(
        sectionId: String,
        categoryTitle: String,
        categoryButtonText: String,
        gamePairViewModels: [CasinoGameImagePairViewModelProtocol]
    ) {
        self.sectionId = sectionId
        self.categoryTitle = categoryTitle
        self._gamePairViewModels = gamePairViewModels

        // Create category bar ViewModel
        let categoryData = CasinoCategoryBarData(
            id: sectionId,
            title: categoryTitle,
            buttonText: categoryButtonText
        )
        self.categoryBarViewModel = MockCasinoCategoryBarViewModel(categoryData: categoryData)

        // Set up callbacks on pair ViewModels
        setupPairCallbacks()
    }

    /// Convenience initializer from section data
    public convenience init(data: CasinoGameImageGridSectionData) {
        let pairs = MockCasinoGameImagePairViewModel.pairs(from: data.games)

        self.init(
            sectionId: data.id,
            categoryTitle: data.categoryTitle,
            categoryButtonText: data.categoryButtonText,
            gamePairViewModels: pairs
        )
    }

    // MARK: - Protocol Methods

    public func gameSelected(_ gameId: String) {
        onGameSelected?(gameId)
    }

    public func categoryButtonTapped() {
        onCategoryButtonTapped?()
    }

    public func refreshGames() {
        // In mock, just trigger a refresh notification
        _gamePairViewModels = _gamePairViewModels
    }

    // MARK: - Private Methods

    private func setupPairCallbacks() {
        for pair in _gamePairViewModels {
            if let mockPair = pair as? MockCasinoGameImagePairViewModel {
                mockPair.onGameSelected = { [weak self] gameId in
                    self?.gameSelected(gameId)
                }
            }
        }
    }
}

// MARK: - Factory Methods

extension MockCasinoGameImageGridSectionViewModel {

    /// Lite Games section with 8 games (4 columns, all pairs full)
    public static var liteGamesSection: MockCasinoGameImageGridSectionViewModel {
        let games: [CasinoGameImageData] = [
            CasinoGameImageData(id: "plinkgoal-1", imageURL: "https://picsum.photos/164/164?random=1", gameURL: "https://example.com/plinkgoal"),
            CasinoGameImageData(id: "plinkgoal-2", imageURL: "https://picsum.photos/164/164?random=2", gameURL: "https://example.com/plinkgoal"),
            CasinoGameImageData(id: "samba-soccer-1", imageURL: "https://picsum.photos/164/164?random=3", gameURL: "https://example.com/samba"),
            CasinoGameImageData(id: "samba-soccer-2", imageURL: "https://picsum.photos/164/164?random=4", gameURL: "https://example.com/samba"),
            CasinoGameImageData(id: "aviator-1", imageURL: "https://picsum.photos/164/164?random=5", gameURL: "https://example.com/aviator"),
            CasinoGameImageData(id: "aviator-2", imageURL: "https://picsum.photos/164/164?random=6", gameURL: "https://example.com/aviator"),
            CasinoGameImageData(id: "beast-below-1", imageURL: "https://picsum.photos/164/164?random=7", gameURL: "https://example.com/beast"),
            CasinoGameImageData(id: "beast-below-2", imageURL: "https://picsum.photos/164/164?random=8", gameURL: "https://example.com/beast")
        ]

        return MockCasinoGameImageGridSectionViewModel(
            data: CasinoGameImageGridSectionData(
                id: "lite-games",
                categoryTitle: "Lite Games",
                categoryButtonText: "All 41",
                games: games
            )
        )
    }

    /// Section with odd number of games (last column has only top card)
    public static var oddGamesSection: MockCasinoGameImageGridSectionViewModel {
        let games: [CasinoGameImageData] = [
            CasinoGameImageData(id: "game-1", imageURL: "https://picsum.photos/164/164?random=10", gameURL: "https://example.com/1"),
            CasinoGameImageData(id: "game-2", imageURL: "https://picsum.photos/164/164?random=11", gameURL: "https://example.com/2"),
            CasinoGameImageData(id: "game-3", imageURL: "https://picsum.photos/164/164?random=12", gameURL: "https://example.com/3"),
            CasinoGameImageData(id: "game-4", imageURL: "https://picsum.photos/164/164?random=13", gameURL: "https://example.com/4"),
            CasinoGameImageData(id: "game-5", imageURL: "https://picsum.photos/164/164?random=14", gameURL: "https://example.com/5"),
            CasinoGameImageData(id: "game-6", imageURL: "https://picsum.photos/164/164?random=15", gameURL: "https://example.com/6"),
            CasinoGameImageData(id: "game-7", imageURL: "https://picsum.photos/164/164?random=16", gameURL: "https://example.com/7") // Odd - top only
        ]

        return MockCasinoGameImageGridSectionViewModel(
            data: CasinoGameImageGridSectionData(
                id: "crash-games",
                categoryTitle: "Crash Games",
                categoryButtonText: "All 23",
                games: games
            )
        )
    }

    /// Empty section (no games)
    public static var emptySection: MockCasinoGameImageGridSectionViewModel {
        MockCasinoGameImageGridSectionViewModel(
            sectionId: "empty-section",
            categoryTitle: "Empty Section",
            categoryButtonText: "All 0",
            gamePairViewModels: []
        )
    }

    /// Section with few games (2 games = 1 column)
    public static var fewGamesSection: MockCasinoGameImageGridSectionViewModel {
        let games: [CasinoGameImageData] = [
            CasinoGameImageData(id: "game-a", imageURL: "https://picsum.photos/164/164?random=20", gameURL: "https://example.com/a"),
            CasinoGameImageData(id: "game-b", imageURL: "https://picsum.photos/164/164?random=21", gameURL: "https://example.com/b")
        ]

        return MockCasinoGameImageGridSectionViewModel(
            data: CasinoGameImageGridSectionData(
                id: "few-games",
                categoryTitle: "Few Games",
                categoryButtonText: "All 2",
                games: games
            )
        )
    }
}
