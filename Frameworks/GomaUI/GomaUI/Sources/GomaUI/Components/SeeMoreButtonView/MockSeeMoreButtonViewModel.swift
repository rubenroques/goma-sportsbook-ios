import Combine
import UIKit

/// Mock implementation of `SeeMoreButtonViewModelProtocol` for testing and previews
final public class MockSeeMoreButtonViewModel: SeeMoreButtonViewModelProtocol {
    
    // MARK: - Properties
    
    private let displayStateSubject: CurrentValueSubject<SeeMoreButtonDisplayState, Never>
    
    public var displayStatePublisher: AnyPublisher<SeeMoreButtonDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var buttonData: SeeMoreButtonData
    private var isLoading: Bool = false
    private var isEnabled: Bool = true
    
    // MARK: - Callbacks
    
    /// Callback fired when button is tapped (for testing)
    public var onButtonTapped: (() -> Void) = { }
    
    // MARK: - Initialization
    
    public init(buttonData: SeeMoreButtonData, isLoading: Bool = false, isEnabled: Bool = true) {
        self.buttonData = buttonData
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        
        // Create initial display state
        let initialState = SeeMoreButtonDisplayState(
            isLoading: isLoading,
            isEnabled: isEnabled,
            buttonData: buttonData
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - SeeMoreButtonViewModelProtocol
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
        publishNewState()
    }
    
    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        publishNewState()
    }
    
    public func updateRemainingCount(_ count: Int?) {
        buttonData = SeeMoreButtonData(
            id: buttonData.id,
            title: buttonData.title,
            remainingCount: count
        )
        publishNewState()
    }
    
    public func buttonTapped() {
        print("SeeMoreButton tapped: \(buttonData.id)")
        onButtonTapped()
        
        // Simulate loading state for demo purposes
        if !isLoading {
            setLoading(true)
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.setLoading(false)
                
                // Simulate reducing count
                if let currentCount = self?.buttonData.remainingCount, currentCount > 10 {
                    self?.updateRemainingCount(currentCount - 10)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func publishNewState() {
        let newState = SeeMoreButtonDisplayState(
            isLoading: isLoading,
            isEnabled: isEnabled,
            buttonData: buttonData
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory

extension MockSeeMoreButtonViewModel {
    
    /// Default mock for basic "Load More" functionality
    public static var defaultMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-default",
            title: "Load More Games",
            remainingCount: nil
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData)
    }
    
    /// Mock in loading state
    public static var loadingMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-loading",
            title: "Load More Games",
            remainingCount: nil
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData, isLoading: true, isEnabled: false)
    }
    
    /// Mock with remaining count display
    public static var withCountMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-count",
            title: "Load More Games",
            remainingCount: 25
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData)
    }
    
    /// Mock in disabled state
    public static var disabledMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-disabled",
            title: "Load More Games",
            remainingCount: nil
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData, isLoading: false, isEnabled: false)
    }
    
    /// Mock for category-specific usage
    public static func categoryMock(categoryId: String, remainingCount: Int) -> MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-\(categoryId)",
            title: "Load More Games",
            remainingCount: remainingCount
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData)
    }
    
    /// Interactive mock that simulates realistic state changes
    public static var interactiveMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-interactive",
            title: "Load More Games",
            remainingCount: 50
        )
        let mock = MockSeeMoreButtonViewModel(buttonData: buttonData)
        
        // Set up realistic interaction behavior
        mock.onButtonTapped = {
            print("Interactive mock: Button tapped!")
        }
        
        return mock
    }
    
    /// Mock for testing error states
    public static var errorStateMock: MockSeeMoreButtonViewModel {
        let buttonData = SeeMoreButtonData(
            id: "load-more-error",
            title: "Retry Loading",
            remainingCount: nil
        )
        return MockSeeMoreButtonViewModel(buttonData: buttonData, isLoading: false, isEnabled: true)
    }
}