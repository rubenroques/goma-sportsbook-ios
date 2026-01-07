import Combine
import UIKit

/// Mock implementation of `MarketNamePillLabelViewModelProtocol` for testing and previews.
final public class MockMarketNamePillLabelViewModel: MarketNamePillLabelViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<MarketNamePillDisplayState, Never>
    
    public var displayStatePublisher: AnyPublisher<MarketNamePillDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Access for Testing
    public var currentDisplayState: MarketNamePillDisplayState {
        return displayStateSubject.value
    }
    
    // MARK: - Initialization
    public init(displayState: MarketNamePillDisplayState) {
        self.displayStateSubject = CurrentValueSubject(displayState)
    }
    
    // MARK: - MarketNamePillLabelViewModelProtocol
    public func updatePillData(_ data: MarketNamePillData) {
        let newState = MarketNamePillDisplayState(pillData: data)
        displayStateSubject.send(newState)
    }
    
    public func updateDisplayState(_ state: MarketNamePillDisplayState) {
        displayStateSubject.send(state)
    }
    
    public func handleInteraction() {
        // In a mock, we can just print or perform simple action
        print("Pill interaction: \(displayStateSubject.value.pillData.text)")
    }
}

// MARK: - Mock Factory
extension MockMarketNamePillLabelViewModel {
    
    /// Standard pill with default styling
    public static var standardPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "1X2",
            style: .standard,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Highlighted pill for emphasis
    public static var highlightedPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Over/Under",
            style: .highlighted,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Disabled pill
    public static var disabledPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Handicap",
            style: .disabled,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Interactive pill that can be tapped
    public static var interactivePill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Both Teams to Score",
            style: .standard,
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    
    /// Custom styled pill
    public static var customStyledPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Custom Market",
            style: .custom(
                borderColor: .systemPurple,
                textColor: .systemPurple,
                backgroundColor: UIColor.systemPurple.withAlphaComponent(0.1)
            ),
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Pill without fading line
    public static var pillWithoutLine: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "No Line",
            style: .standard,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Long text pill to test layout
    public static var longTextPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Very Long Market Name",
            style: .standard,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    /// Short text pill
    public static var shortTextPill: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "FT",
            style: .highlighted,
            isInteractive: false
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
}

// MARK: - Simulation Helpers
extension MockMarketNamePillLabelViewModel {
    
    /// Updates text dynamically (useful for testing)
    public func updateText(_ newText: String) {
        let currentState = displayStateSubject.value
        let newPillData = MarketNamePillData(
            text: newText,
            style: currentState.pillData.style,
            isInteractive: currentState.pillData.isInteractive
        )
        updatePillData(newPillData)
    }
    
    /// Cycles through different styles
    public func cycleStyles() {
        let styles: [MarketNamePillStyle] = [.standard, .highlighted, .disabled]
        let currentState = displayStateSubject.value
        
        for (index, style) in styles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.0) {
                let newPillData = MarketNamePillData(
                    text: currentState.pillData.text,
                    style: style,
                    isInteractive: currentState.pillData.isInteractive
                )
                self.updatePillData(newPillData)
            }
        }
    }
}

// MARK: - Real-World Usage Examples
extension MockMarketNamePillLabelViewModel {
    
    /// Common betting market examples
    public static var winDrawWinMarket: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "1X2",
            style: .highlighted,
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    public static var overUnderMarket: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Over/Under 2.5",
            style: .standard,
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    public static var handicapMarket: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "Asian Handicap",
            style: .standard,
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
    
    public static var bothTeamsToScoreMarket: MockMarketNamePillLabelViewModel {
        let pillData = MarketNamePillData(
            text: "BTTS",
            style: .standard,
            isInteractive: true
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        return MockMarketNamePillLabelViewModel(displayState: displayState)
    }
}
