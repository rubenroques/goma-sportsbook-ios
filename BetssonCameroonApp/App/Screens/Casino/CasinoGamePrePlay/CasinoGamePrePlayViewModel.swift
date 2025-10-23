//
//  CasinoGamePrePlayViewModel.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 01/08/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class CasinoGamePrePlayViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for CasinoCoordinator
    var onNavigateBack: (() -> Void) = { }
    var onLoginRequested: (() -> Void) = { }
    var onDepositRequested: (() -> Void) = { }
    var onStartGame: ((CasinoGamePlayMode, CasinoGame?) -> Void) = { _, _ in }
    
    // MARK: - Published Properties
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Properties
    private let gameId: String
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // Child ViewModel for the selector component
    let playSelectorViewModel: CasinoGamePlayModeSelectorViewModel
    
    // MARK: - Initialization
    init(gameId: String, servicesProvider: ServicesProvider.Client) {
        self.gameId = gameId
        self.servicesProvider = servicesProvider
        
        // Create the play selector view model
        self.playSelectorViewModel = CasinoGamePlayModeSelectorViewModel(
            gameId: gameId,
            servicesProvider: servicesProvider
        )
        
        setupChildViewModelCallbacks()
    }
    
    // MARK: - Public Methods
    func navigateBack() {
        onNavigateBack()
    }
    
    func refreshData() {
        playSelectorViewModel.refreshGameData()
    }
    
    // MARK: - Private Methods
    private func setupChildViewModelCallbacks() {
        // Connect play selector callbacks to our navigation closures
        playSelectorViewModel.onLoginRequested = { [weak self] in
            self?.onLoginRequested()
        }
        
        playSelectorViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested()
        }
        
        playSelectorViewModel.onStartGame = { [weak self] mode in
            self?.onStartGame(mode, self?.playSelectorViewModel.loadedGameDetails)
        }
    }
}

// MARK: - Game Play Mode

enum CasinoGamePlayMode {
    case practice
    case realMoney
}

// MARK: - Casino Game Play Mode Selector ViewModel

class CasinoGamePlayModeSelectorViewModel: CasinoGamePlayModeSelectorViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoGamePlayModeSelectorDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<CasinoGamePlayModeSelectorDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    private let gameId: String
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    private var gameDetails: CasinoGame?
    
    private static let gamesPlatform = "PC"
    
    // Navigation callbacks
    var onLoginRequested: (() -> Void) = { }
    var onDepositRequested: (() -> Void) = { }
    var onStartGame: ((CasinoGamePlayMode) -> Void) = { _ in }
    
    // Expose gameDetails for access by parent ViewModel
    var loadedGameDetails: CasinoGame? {
        return gameDetails
    }
    
    // MARK: - Initialization
    init(gameId: String, servicesProvider: ServicesProvider.Client) {
        self.gameId = gameId
        self.servicesProvider = servicesProvider
        
        // Create initial loading state
        let initialState = Self.createLoadingState(gameId: gameId)
        self.displayStateSubject = CurrentValueSubject(initialState)
        
        // Load game details from API
        loadGameDetails()
    }
    
    // MARK: - CasinoGamePlayModeSelectorViewModelProtocol
    
    public func buttonTapped(buttonId: String) {
        switch buttonId {
        case "login":
            onLoginRequested()
        case "practice":
            onStartGame(.practice)
        case "play":
            onStartGame(.realMoney)
        case "deposit":
            onDepositRequested()
        default:
            print("Unknown button tapped: \(buttonId)")
        }
    }
    
    public func refreshGameData() {
        loadGameDetails()
    }
    
    public func setLoading(_ loading: Bool) {
        guard
            let gameDetails = gameDetails
        else {
            // If no game details yet, show loading state
            let loadingState = Self.createLoadingState(gameId: self.gameId)
            displayStateSubject.send(loadingState)
            return
        }
        
        let newState = createDisplayState(from: gameDetails, isLoading: loading)
        displayStateSubject.send(newState)
    }
    
    // MARK: - Private Methods
    
    private func loadGameDetails() {
        servicesProvider.getGameDetails(
            gameId: gameId,
            language: "en",
            platform: Self.gamesPlatform
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to load game details: \(error)")
                }
            },
            receiveValue: { [weak self] game in
                guard
                    let self = self
                else {
                    return
                }
                
                self.gameDetails = game
                let newState = self.createDisplayState(from: game, isLoading: false)
                self.displayStateSubject.send(newState)
            }
        )
        .store(in: &cancellables)
    }
    
    private static func createLoadingState(gameId: String) -> CasinoGamePlayModeSelectorDisplayState {
        let placeholderGameData = CasinoGamePlayModeSelectorGameData(
            id: gameId,
            name: "Loading...",
            imageURL: nil,
            provider: "Loading...",
            volatility: "N/A",
            minStake: "N/A",
            description: "Loading game details..."
        )
        
        let loadingButtons = [
            CasinoGamePlayModeButton(
                id: "loading",
                type: .primary,
                title: "Loading...",
                state: .loading,
                style: .filled
            )
        ]
        
        return CasinoGamePlayModeSelectorDisplayState(
            gameData: placeholderGameData,
            buttons: loadingButtons,
            isLoading: true
        )
    }
    
    private func createDisplayState(from game: CasinoGame, isLoading: Bool) -> CasinoGamePlayModeSelectorDisplayState {
        // Convert CasinoGame to CasinoGamePlayModeSelectorGameData using ServiceProviderModelMapper
        let gameCardData = ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: game)
        
        let gameData = CasinoGamePlayModeSelectorGameData(
            id: gameCardData.id,
            name: gameCardData.name,
            imageURL: gameCardData.imageURL,
            provider: gameCardData.provider,  // Now optional, passes through
            volatility: mapRatingToVolatility(gameCardData.rating),
            minStake: gameCardData.minStake,
            description: game.description
        )
        
        // Determine button configuration based on user state
        let buttons = determineButtonConfiguration()
        
        return CasinoGamePlayModeSelectorDisplayState(
            gameData: gameData,
            buttons: buttons,
            isLoading: isLoading
        )
    }
    
    private func determineButtonConfiguration() -> [CasinoGamePlayModeButton] {
        let isUserLoggedIn = checkUserLoginStatus()
        
        if !isUserLoggedIn {
            // Logged-out user configuration
            return [
                CasinoGamePlayModeButton(
                    id: "login",
                    type: .primary,
                    title: "Login to Play",
                    state: .enabled,
                    style: .filled
                ),
                CasinoGamePlayModeButton(
                    id: "practice",
                    type: .secondary,
                    title: "Practice Play",
                    state: .enabled,
                    style: .outlined
                )
            ]
        } else {
            // Logged-in user configuration (skip funds check)
            return [
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
        }
    }
    
    private func checkUserLoginStatus() -> Bool {
        return Env.userSessionStore.isUserLogged()
    }
    
    private func mapRatingToVolatility(_ rating: Double) -> String {
        // Map game rating to volatility level
        switch rating {
        case 0..<3.0:
            return "Low"
        case 3.0..<4.0:
            return "Medium"
        case 4.0...5.0:
            return "High"
        default:
            return "Medium"
        }
    }
    
}
