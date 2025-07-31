import Combine
import Foundation

public class MockCasinoCategoryBarViewModel: CasinoCategoryBarViewModelProtocol {
    
    // MARK: - Properties
    public let categoryData: CasinoCategoryBarData
    
    // MARK: - Publishers
    @Published private var title: String
    @Published private var buttonText: String
    
    public var titlePublisher: AnyPublisher<String, Never> {
        $title.eraseToAnyPublisher()
    }
    
    public var buttonTextPublisher: AnyPublisher<String, Never> {
        $buttonText.eraseToAnyPublisher()
    }
    
    public var categoryId: String {
        categoryData.id
    }
    
    // MARK: - Initialization
    public init(categoryData: CasinoCategoryBarData) {
        self.categoryData = categoryData
        self.title = categoryData.title
        self.buttonText = categoryData.buttonText
    }
    
    // MARK: - Actions
    public func buttonTapped() {
        // Mock action - could trigger navigation or filtering
        print("Button tapped for category: \(categoryId)")
    }
    
    // MARK: - State Update Methods (for testing)
    public func updateTitle(_ newTitle: String) {
        title = newTitle
    }
    
    public func updateButtonText(_ newButtonText: String) {
        buttonText = newButtonText
    }
}

// MARK: - Factory Methods
extension MockCasinoCategoryBarViewModel {
    
    public static var newGames: MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: "new-games",
            title: "New Games",
            buttonText: "All 41"
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
    
    public static var popularGames: MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: "popular-games",
            title: "Popular Games",
            buttonText: "All 127"
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
    
    public static var slotGames: MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: "slot-games",
            title: "Slot Games",
            buttonText: "All 89"
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
    
    public static var liveGames: MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: "live-games",
            title: "Live Games",
            buttonText: "All 23"
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
    
    public static var jackpotGames: MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: "jackpot-games",
            title: "Jackpot Games",
            buttonText: "All 12"
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
    
    // MARK: - Custom Factory
    public static func customCategory(
        id: String,
        title: String,
        buttonText: String
    ) -> MockCasinoCategoryBarViewModel {
        let categoryData = CasinoCategoryBarData(
            id: id,
            title: title,
            buttonText: buttonText
        )
        return MockCasinoCategoryBarViewModel(categoryData: categoryData)
    }
}