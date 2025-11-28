import Foundation
import Combine

/// Data model for a casino game image grid section
public struct CasinoGameImageGridSectionData: Equatable, Hashable, Identifiable {
    public let id: String
    public let categoryTitle: String
    public let categoryButtonText: String
    public let games: [CasinoGameImageData]

    public init(
        id: String,
        categoryTitle: String,
        categoryButtonText: String,
        games: [CasinoGameImageData]
    ) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.categoryButtonText = categoryButtonText
        self.games = games
    }
}

/// Protocol defining the interface for CasinoGameImageGridSectionView's ViewModel
public protocol CasinoGameImageGridSectionViewModelProtocol: AnyObject {
    /// ViewModel for the category bar header
    var categoryBarViewModel: CasinoCategoryBarViewModelProtocol { get }

    /// ViewModels for the game pairs (games grouped in vertical pairs)
    var gamePairViewModels: [CasinoGameImagePairViewModelProtocol] { get }

    /// Publisher for game pair ViewModels updates
    var gamePairViewModelsPublisher: AnyPublisher<[CasinoGameImagePairViewModelProtocol], Never> { get }

    /// Unique identifier for this section
    var sectionId: String { get }

    /// Category title
    var categoryTitle: String { get }

    /// Called when a game is selected
    func gameSelected(_ gameId: String)

    /// Called when the category button is tapped
    func categoryButtonTapped()

    /// Refresh the games data
    func refreshGames()
}
