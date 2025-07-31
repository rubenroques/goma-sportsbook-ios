import Combine
import Foundation

// MARK: - Data Models
public struct CasinoCategorySectionData: Equatable, Hashable, Identifiable {
    public let id: String               // category identifier  
    public let categoryTitle: String    // category title (e.g., "New Games")
    public let categoryButtonText: String // button text (e.g., "All 41")
    public let games: [CasinoGameCardData] // array of games in this category
    
    public init(
        id: String,
        categoryTitle: String,
        categoryButtonText: String,
        games: [CasinoGameCardData]
    ) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.categoryButtonText = categoryButtonText
        self.games = games
    }
}

// MARK: - View Model Protocol
public protocol CasinoCategorySectionViewModelProtocol: AnyObject {
    // Child ViewModels (Vertical Pattern - Parent creates children for its subviews)
    var categoryBarViewModel: CasinoCategoryBarViewModelProtocol { get }
    var gameCardViewModels: [CasinoGameCardViewModelProtocol] { get }
    
    // Publishers for reactive updates
    var gameCardViewModelsPublisher: AnyPublisher<[CasinoGameCardViewModelProtocol], Never> { get }
    
    // Read-only properties
    var sectionId: String { get }
    var categoryTitle: String { get }
    
    // Actions
    func gameSelected(_ gameId: String)
    func categoryButtonTapped()
    func refreshGames()
}