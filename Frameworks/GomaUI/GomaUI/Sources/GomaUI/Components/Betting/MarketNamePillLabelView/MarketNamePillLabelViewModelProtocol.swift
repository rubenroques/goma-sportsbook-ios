import Combine
import UIKit

// MARK: - Data Models

/// Represents the visual style of the market name pill
public enum MarketNamePillStyle: Equatable, Hashable {
    case standard
    case highlighted
    case disabled
    case custom(borderColor: UIColor, textColor: UIColor, backgroundColor: UIColor?)
}

/// Contains all data needed to display a market name pill label
public struct MarketNamePillData: Equatable, Hashable {
    public let text: String
    public let style: MarketNamePillStyle
    public let isInteractive: Bool
    
    public init(
        text: String,
        style: MarketNamePillStyle = .standard,
        isInteractive: Bool = false
    ) {
        self.text = text
        self.style = style
        self.isInteractive = isInteractive
    }
}

// MARK: - Display State

/// Represents the complete display state for the market name pill label component
public struct MarketNamePillDisplayState: Equatable {
    public let pillData: MarketNamePillData
    
    public init(pillData: MarketNamePillData) {
        self.pillData = pillData
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for MarketNamePillLabelView view model
public protocol MarketNamePillLabelViewModelProtocol {
    /// Publisher for reactive display state updates
    var displayStatePublisher: AnyPublisher<MarketNamePillDisplayState, Never> { get }
    
    /// Updates the pill data
    func updatePillData(_ data: MarketNamePillData)
    
    /// Updates the complete display state
    func updateDisplayState(_ state: MarketNamePillDisplayState)
    
    /// Triggers an interaction event (for interactive pills)
    func handleInteraction()
}
