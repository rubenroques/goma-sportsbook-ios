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
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Child ViewModel for the selector component
    let playSelectorViewModel: CasinoGamePlayModeSelectorViewModel
    
    // MARK: - Initialization
    init(gameId: String, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.gameId = gameId
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore

        // Create the play selector view model with proper DI
        self.playSelectorViewModel = CasinoGamePlayModeSelectorViewModel(
            gameId: gameId,
            servicesProvider: servicesProvider,
            userSessionStore: userSessionStore
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
    private let userSessionStore: UserSessionStore
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
    init(gameId: String, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.gameId = gameId
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore

        // Create initial loading state
        let initialState = Self.createLoadingState(gameId: gameId)
        self.displayStateSubject = CurrentValueSubject(initialState)

        // Load game details from API
        loadGameDetails()

        // Subscribe to user session changes for reactive button updates
        setupUserSessionTracking()
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
        
        let language = LanguageManager.shared.currentLanguageCode

        servicesProvider.getGameDetails(
            gameId: gameId,
            language: language,
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
            name: localized("casino_loading"),
            thumbnailURL: nil,
            backgroundURL: nil,
            provider: localized("casino_loading"),
            volatility: localized("casino_not_available"),
            minStake: localized("casino_not_available"),
            description: localized("casino_loading_game_details")
        )

        let loadingButtons = [
            CasinoGamePlayModeButton(
                id: "loading",
                type: .primary,
                title: localized("casino_loading"),
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
            thumbnailURL: ServiceProviderModelMapper.thumbnailURL(from: game),
            backgroundURL: ServiceProviderModelMapper.backgroundURL(from: game),
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
                    title: localized("login_to_play"),
                    state: .enabled,
                    style: .filled
                ),
                CasinoGamePlayModeButton(
                    id: "practice",
                    type: .secondary,
                    title: localized("practice_play"),
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
                    title: localized("play_now"),
                    state: .enabled,
                    style: .filled
                ),
                CasinoGamePlayModeButton(
                    id: "practice",
                    type: .secondary,
                    title: localized("practice_mode"),
                    state: .enabled,
                    style: .outlined
                )
            ]
        }
    }
    
    private func setupUserSessionTracking() {
        // Subscribe to user profile status changes for reactive button updates
        userSessionStore.userProfileStatusPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }

                // Refresh button configuration when user logs in or out
                if let gameDetails = self.gameDetails {
                    let newState = self.createDisplayState(from: gameDetails, isLoading: false)
                    self.displayStateSubject.send(newState)
                }
            }
            .store(in: &cancellables)
    }

    private func checkUserLoginStatus() -> Bool {
        return userSessionStore.isUserLogged()
    }

    private func mapRatingToVolatility(_ rating: Double) -> String {
        // Map game rating to volatility level
        switch rating {
        case 0..<3.0:
            return localized("casino_volatility_low")
        case 3.0..<4.0:
            return localized("casino_volatility_medium")
        case 4.0...5.0:
            return localized("casino_volatility_high")
        default:
            return localized("casino_volatility_medium")
        }
    }
    
}
