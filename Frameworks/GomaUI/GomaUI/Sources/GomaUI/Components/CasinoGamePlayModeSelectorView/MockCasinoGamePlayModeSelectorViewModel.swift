import Combine
import UIKit

/// Mock implementation of `CasinoGamePlayModeSelectorViewModelProtocol` for testing and previews
final public class MockCasinoGamePlayModeSelectorViewModel: CasinoGamePlayModeSelectorViewModelProtocol {

    // MARK: - Properties
    
    private let displayStateSubject: CurrentValueSubject<CasinoGamePlayModeSelectorDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<CasinoGamePlayModeSelectorDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var gameData: CasinoGamePlayModeSelectorGameData
    private var buttons: [CasinoGamePlayModeButton]
    private var isLoading: Bool
    
    // MARK: - Initialization
    
    public init(
        gameData: CasinoGamePlayModeSelectorGameData,
        buttons: [CasinoGamePlayModeButton],
        isLoading: Bool = false
    ) {
        self.gameData = gameData
        self.buttons = buttons
        self.isLoading = isLoading
        
        // Create initial display state
        let initialState = CasinoGamePlayModeSelectorDisplayState(
            gameData: gameData,
            buttons: buttons,
            isLoading: isLoading
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - CasinoGamePlayModeSelectorViewModelProtocol
    
    public func buttonTapped(buttonId: String) {
        print("MockViewModel: Button tapped - \(buttonId)")
        
        // Simulate different button actions
        switch buttonId {
        case "login":
            print("MockViewModel: Triggering login flow")
        case "practice":
            print("MockViewModel: Starting practice mode")
        case "play":
            print("MockViewModel: Starting real money play")
        case "deposit":
            print("MockViewModel: Opening deposit screen")
        default:
            print("MockViewModel: Unknown button action")
        }
    }
    
    public func refreshGameData() {
        print("MockViewModel: Refreshing game data")
        setLoading(true)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.setLoading(false)
        }
    }
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
        publishNewState()
    }
    
    // MARK: - Helper Methods
    
    private func publishNewState() {
        let newState = CasinoGamePlayModeSelectorDisplayState(
            gameData: gameData,
            buttons: buttons,
            isLoading: isLoading
        )
        displayStateSubject.send(newState)
    }
    
    public func updateButtons(_ newButtons: [CasinoGamePlayModeButton]) {
        buttons = newButtons
        publishNewState()
    }
    
    public func updateGameData(_ newGameData: CasinoGamePlayModeSelectorGameData) {
        gameData = newGameData
        publishNewState()
    }
}

// MARK: - Mock Factory

extension MockCasinoGamePlayModeSelectorViewModel {
    
    /// Default mock for logged-out users - shows LOGIN and PRACTICE buttons
    public static var defaultMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "surging-7s",
            name: "Surging 7s",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "Pragmatic Play",
            volatility: "Medium",
            minStake: "XAF 1",
            description: "Engross yourself into the world of Surging 7s with a variety of fruity symbols accompanied by numerous exciting features. The Link Bonus adds additional action where Prizepots and random credits are awarded!"
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "login",
                type: .primary,
                title: "LOGIN_TO_PLAY",
                state: .enabled,
                style: .filled
            ),
            CasinoGamePlayModeButton(
                id: "practice",
                type: .secondary,
                title: "PRACTICE_PLAY",
                state: .enabled,
                style: .outlined
            )
        ]
        
        return MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons
        )
    }
    
    /// Mock for logged-in users with sufficient funds
    public static var loggedInMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "mega-fortune",
            name: "Mega Fortune",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "NetEnt",
            volatility: "High",
            minStake: "XAF 5",
            description: "Experience the luxury lifestyle with Mega Fortune! This progressive jackpot slot features luxury symbols and the chance to win life-changing amounts."
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "play",
                type: .primary,
                title: "PLAY_NOW",
                state: .enabled,
                style: .filled
            ),
            CasinoGamePlayModeButton(
                id: "practice",
                type: .secondary,
                title: "PRACTICE_MODE",
                state: .enabled,
                style: .outlined
            )
        ]
        
        return MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons
        )
    }
    
    /// Mock for users with insufficient funds
    public static var insufficientFundsMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "book-of-dead",
            name: "Book of Dead",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "Play'n GO",
            volatility: "High",
            minStake: "XAF 10",
            description: "Join Rich Wilde on his adventure in ancient Egypt. Book of Dead offers exciting bonus features and the potential for big wins."
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "deposit",
                type: .primary,
                title: "DEPOSIT_TO_PLAY",
                state: .enabled,
                style: .filled
            ),
            CasinoGamePlayModeButton(
                id: "practice",
                type: .secondary,
                title: "PRACTICE_PLAY",
                state: .enabled,
                style: .outlined
            )
        ]
        
        return MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons
        )
    }
    
    /// Mock showing loading state
    public static var loadingMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "starburst",
            name: "Starburst",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "NetEnt",
            volatility: "Low",
            minStake: "XAF 1",
            description: "The cosmic classic that never gets old! Starburst features expanding wilds and re-spins for exciting gameplay."
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "login",
                type: .primary,
                title: "LOGIN_TO_PLAY",
                state: .loading,
                style: .filled
            ),
            CasinoGamePlayModeButton(
                id: "practice",
                type: .secondary,
                title: "PRACTICE_PLAY",
                state: .disabled,
                style: .outlined
            )
        ]
        
        return MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons,
            isLoading: true
        )
    }
    
    /// Mock for disabled/maintenance mode
    public static var disabledMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "maintenance-game",
            name: "Under Maintenance",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "Provider",
            volatility: "N/A",
            minStake: "N/A",
            description: "This game is currently under maintenance. Please try again later."
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "maintenance",
                type: .primary,
                title: "GAME_UNAVAILABLE",
                state: .disabled,
                style: .filled
            )
        ]
        
        return MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons
        )
    }
    
    /// Interactive mock that changes state when buttons are tapped
    public static var interactiveMock: MockCasinoGamePlayModeSelectorViewModel {
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: "surging-7s",
            name: "Surging 7s",
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: "Pragmatic Play",
            volatility: "Medium",
            minStake: "XAF 1",
            description: "Interactive demo - tap buttons to see state changes!"
        )
        
        let buttons = [
            CasinoGamePlayModeButton(
                id: "login",
                type: .primary,
                title: "LOGIN_TO_PLAY",
                state: .enabled,
                style: .filled
            ),
            CasinoGamePlayModeButton(
                id: "practice",
                type: .secondary,
                title: "PRACTICE_PLAY",
                state: .enabled,
                style: .outlined
            )
        ]
        
        let mock = MockCasinoGamePlayModeSelectorViewModel(
            gameData: gameData,
            buttons: buttons
        )
        
        // Create interactive behavior by providing custom button tap handler
        // This demonstrates how to create interactive behavior without inheritance
        return mock
    }
}