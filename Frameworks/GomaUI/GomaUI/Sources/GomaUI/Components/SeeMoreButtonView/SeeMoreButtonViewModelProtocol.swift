import Combine
import UIKit

// MARK: - Button Style Enum

/// Style options for SeeMoreButton
public enum SeeMoreButtonStyle {
    case solidBackground
    case bordered
}

// MARK: - Data Models

/// Data model for SeeMoreButton component configuration
public struct SeeMoreButtonData: Equatable, Hashable {
    /// Unique identifier for the button
    public let id: String
    
    /// Button title text (e.g., "Load More Games")
    public let title: String
    
    /// Optional count to display (e.g., "Load 15 more games")
    public let remainingCount: Int?
    
    /// Button style (defaults to solidBackground)
    public let style: SeeMoreButtonStyle
    
    public init(id: String, title: String, remainingCount: Int? = nil, style: SeeMoreButtonStyle = .solidBackground) {
        self.id = id
        self.title = title
        self.remainingCount = remainingCount
        self.style = style
    }
}

// MARK: - Display State

/// Represents the visual state of the SeeMoreButton component
public struct SeeMoreButtonDisplayState: Equatable {
    /// Whether the button is currently in loading state
    public let isLoading: Bool
    
    /// Whether the button is enabled for interaction
    public let isEnabled: Bool
    
    /// The button configuration data
    public let buttonData: SeeMoreButtonData
    
    public init(isLoading: Bool = false, isEnabled: Bool = true, buttonData: SeeMoreButtonData) {
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.buttonData = buttonData
    }
    
    // MARK: - Convenience State Creators
    
    public static func normal(buttonData: SeeMoreButtonData) -> SeeMoreButtonDisplayState {
        return SeeMoreButtonDisplayState(isLoading: false, isEnabled: true, buttonData: buttonData)
    }
    
    public static func loading(buttonData: SeeMoreButtonData) -> SeeMoreButtonDisplayState {
        return SeeMoreButtonDisplayState(isLoading: true, isEnabled: false, buttonData: buttonData)
    }
    
    public static func disabled(buttonData: SeeMoreButtonData) -> SeeMoreButtonDisplayState {
        return SeeMoreButtonDisplayState(isLoading: false, isEnabled: false, buttonData: buttonData)
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for SeeMoreButton ViewModels
public protocol SeeMoreButtonViewModelProtocol: AnyObject {
    
    // MARK: - Publishers
    
    /// Publisher for reactive state updates
    var displayStatePublisher: AnyPublisher<SeeMoreButtonDisplayState, Never> { get }
    
    // MARK: - State Management
    
    /// Set the loading state of the button
    /// - Parameter loading: Whether the button should show loading state
    func setLoading(_ loading: Bool)
    
    /// Set the enabled state of the button
    /// - Parameter enabled: Whether the button should be enabled for interaction
    func setEnabled(_ enabled: Bool)
    
    /// Update the remaining count display
    /// - Parameter count: New remaining count, nil to hide count
    func updateRemainingCount(_ count: Int?)
    
    // MARK: - User Interaction
    
    /// Called when the button is tapped
    func buttonTapped()
}