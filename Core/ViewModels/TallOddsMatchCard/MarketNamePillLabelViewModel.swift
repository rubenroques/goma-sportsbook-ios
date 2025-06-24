import GomaUI
import Combine
import UIKit

/// Production implementation of `MarketNamePillLabelViewModelProtocol` for real market data.
final class MarketNamePillLabelViewModel: MarketNamePillLabelViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<MarketNamePillDisplayState, Never>
    
    public var displayStatePublisher: AnyPublisher<MarketNamePillDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(marketName: String, style: MarketNamePillStyle = .standard, isInteractive: Bool = false) {
        let pillData = MarketNamePillData(
            text: marketName,
            style: style,
            isInteractive: isInteractive
        )
        
        let displayState = MarketNamePillDisplayState(pillData: pillData)
        self.displayStateSubject = CurrentValueSubject(displayState)
    }
    
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
        // In production, this could trigger analytics or navigation
        print("Market pill interaction: \(displayStateSubject.value.pillData.text)")
    }
}

// MARK: - Factory Methods
extension MarketNamePillLabelViewModel {
    
    /// Creates a standard market name pill from market data
    static func create(from marketInfoData: MarketInfoData) -> MarketNamePillLabelViewModel {
        return MarketNamePillLabelViewModel(
            marketName: marketInfoData.marketName,
            style: .standard,
            isInteractive: false
        )
    }
    
    /// Creates a highlighted market name pill
    static func createHighlighted(from marketInfoData: MarketInfoData) -> MarketNamePillLabelViewModel {
        return MarketNamePillLabelViewModel(
            marketName: marketInfoData.marketName,
            style: .highlighted,
            isInteractive: false
        )
    }
    
    /// Creates an interactive market name pill
    static func createInteractive(from marketInfoData: MarketInfoData) -> MarketNamePillLabelViewModel {
        return MarketNamePillLabelViewModel(
            marketName: marketInfoData.marketName,
            style: .standard,
            isInteractive: true
        )
    }
}