import Combine
import UIKit

// MARK: - Data Models

/// Represents the game data to be displayed in the casino game play mode selector
public struct CasinoGamePlayModeSelectorGameData: Equatable, Hashable {
    public let id: String
    public let name: String
    public let imageURL: String?
    public let provider: String
    public let volatility: String?
    public let minStake: String
    public let description: String?
    
    public init(
        id: String,
        name: String,
        imageURL: String? = nil,
        provider: String,
        volatility: String? = nil,
        minStake: String,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.provider = provider
        self.volatility = volatility
        self.minStake = minStake
        self.description = description
    }
}

/// Represents a configurable button in the play mode selector
public struct CasinoGamePlayModeButton: Equatable, Hashable {
    public let id: String
    public let type: ButtonType
    public let title: String
    public let state: ButtonState
    public let style: ButtonStyle
    
    public enum ButtonType: Equatable, Hashable {
        case primary      // LOGIN_TO_PLAY
        case secondary    // PRACTICE_PLAY  
        case tertiary     // Other actions
    }
    
    public enum ButtonState: Equatable, Hashable {
        case enabled
        case disabled
        case loading
    }
    
    public enum ButtonStyle: Equatable, Hashable {
        case filled       // Solid background
        case outlined     // Border only
        case text         // Text only
    }
    
    public init(
        id: String,
        type: ButtonType,
        title: String,
        state: ButtonState,
        style: ButtonStyle
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.state = state
        self.style = style
    }
}

// MARK: - Display State

/// Represents the complete visual state of the casino game play mode selector
public struct CasinoGamePlayModeSelectorDisplayState: Equatable {
    public let gameData: CasinoGamePlayModeSelectorGameData
    public let buttons: [CasinoGamePlayModeButton]
    public let isLoading: Bool
    
    public init(
        gameData: CasinoGamePlayModeSelectorGameData,
        buttons: [CasinoGamePlayModeButton],
        isLoading: Bool = false
    ) {
        self.gameData = gameData
        self.buttons = buttons
        self.isLoading = isLoading
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for casino game play mode selector view models
public protocol CasinoGamePlayModeSelectorViewModelProtocol: AnyObject {
    /// Publisher for reactive updates to the display state
    var displayStatePublisher: AnyPublisher<CasinoGamePlayModeSelectorDisplayState, Never> { get }
    
    /// Called when a button is tapped
    /// - Parameter buttonId: The unique identifier of the tapped button
    func buttonTapped(buttonId: String)
    
    /// Called to refresh/reload game data
    func refreshGameData()
    
    /// Called to set loading state
    /// - Parameter loading: Whether the component should show loading state
    func setLoading(_ loading: Bool)
}