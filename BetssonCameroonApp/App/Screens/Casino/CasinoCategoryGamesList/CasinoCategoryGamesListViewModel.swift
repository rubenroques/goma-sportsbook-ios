//
//  CasinoCategoryGamesListViewModel.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class CasinoCategoryGamesListViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for CasinoCoordinator
    var onGameSelected: ((String) -> Void) = { _ in }
    var onNavigateBack: (() -> Void) = { }
    
    // MARK: - Published Properties
    @Published private(set) var games: [MockCasinoGameCardViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var categoryTitle: String
    
    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: MockQuickLinksTabBarViewModel
    let multiWidgetToolbarViewModel: MockMultiWidgetToolbarViewModel
    
    // MARK: - Properties
    private let categoryId: String
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(categoryId: String, categoryTitle: String, servicesProvider: ServicesProvider.Client) {
        self.categoryId = categoryId
        self.categoryTitle = categoryTitle
        self.servicesProvider = servicesProvider
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        
        setupChildViewModelCallbacks()
        loadGamesForCategory()
    }
    
    // MARK: - Public Methods
    func reloadGames() {
        loadGamesForCategory()
    }
    
    func gameSelected(_ gameId: String) {
        onGameSelected(gameId)
    }
    
    func navigateBack() {
        onNavigateBack()
    }
    
    // MARK: - Private Methods
    private func loadGamesForCategory() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network call - replace with real service call later
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            self.games = self.createGamesForCategory(self.categoryId)
            self.isLoading = false
        }
    }
    
    private func setupChildViewModelCallbacks() {
        // QuickLinks tab bar callbacks
        quickLinksTabBarViewModel.onTabSelected = { tabId in
            print("Casino Category Games: Tab selected: \(tabId)")
            // Handle tab switching if needed
        }
    }
    
    // MARK: - Mock Games Generation
    private func createGamesForCategory(_ categoryId: String) -> [MockCasinoGameCardViewModel] {
        let gamesData: [CasinoGameCardData]
        
        switch categoryId {
        case "new-games":
            gamesData = createNewGames()
        case "popular-games":
            gamesData = createPopularGames()
        case "slot-games":
            gamesData = createSlotGames()
        case "live-games":
            gamesData = createLiveGames()
        case "jackpot-games":
            gamesData = createJackpotGames()
        case "table-games":
            gamesData = createTableGames()
        default:
            gamesData = createDefaultGames()
        }
        
        return gamesData.map { gameData in
            let viewModel = MockCasinoGameCardViewModel(gameData: gameData)
            viewModel.onGameSelected = { [weak self] gameId in
                self?.gameSelected(gameId)
            }
            return viewModel
        }
    }
    
    private func createNewGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "new-001", name: "Dragon's Fortune", gameURL: "https://casino.example.com/games/dragons-fortune", imageURL: "casinoGameDemo", rating: 4.8, provider: "Red Tiger Gaming", minStake: "XAF 50"),
            CasinoGameCardData(id: "new-002", name: "Mega Wheel", gameURL: "https://casino.example.com/games/mega-wheel", imageURL: "casinoGameDemo", rating: 4.6, provider: "Pragmatic Play", minStake: "XAF 100"),
            CasinoGameCardData(id: "new-003", name: "Crystal Quest", gameURL: "https://casino.example.com/games/crystal-quest", imageURL: "casinoGameDemo", rating: 4.4, provider: "Thunderkick", minStake: "XAF 25"),
            CasinoGameCardData(id: "new-004", name: "Lucky Pharaoh", gameURL: "https://casino.example.com/games/lucky-pharaoh", imageURL: "casinoGameDemo", rating: 4.7, provider: "Novomatic", minStake: "XAF 200"),
            CasinoGameCardData(id: "new-005", name: "Wild West Gold", gameURL: "https://casino.example.com/games/wild-west-gold", imageURL: "casinoGameDemo", rating: 4.5, provider: "Pragmatic Play", minStake: "XAF 75"),
            CasinoGameCardData(id: "new-006", name: "Fire Joker", gameURL: "https://casino.example.com/games/fire-joker", imageURL: "casinoGameDemo", rating: 4.3, provider: "Play'n GO", minStake: "XAF 30")
        ]
    }
    
    private func createPopularGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "popular-001", name: "Starburst", gameURL: "https://casino.example.com/games/starburst", imageURL: "casinoGameDemo", rating: 4.9, provider: "NetEnt", minStake: "XAF 10"),
            CasinoGameCardData(id: "popular-002", name: "Book of Dead", gameURL: "https://casino.example.com/games/book-of-dead", imageURL: "casinoGameDemo", rating: 4.8, provider: "Play'n GO", minStake: "XAF 20"),
            CasinoGameCardData(id: "popular-003", name: "Gonzo's Quest", gameURL: "https://casino.example.com/games/gonzo-quest", imageURL: "casinoGameDemo", rating: 4.7, provider: "NetEnt", minStake: "XAF 50"),
            CasinoGameCardData(id: "popular-004", name: "Sweet Bonanza", gameURL: "https://casino.example.com/games/sweet-bonanza", imageURL: "casinoGameDemo", rating: 4.6, provider: "Pragmatic Play", minStake: "XAF 40"),
            CasinoGameCardData(id: "popular-005", name: "Legacy of Dead", gameURL: "https://casino.example.com/games/legacy-of-dead", imageURL: "casinoGameDemo", rating: 4.5, provider: "Play'n GO", minStake: "XAF 25"),
            CasinoGameCardData(id: "popular-006", name: "The Dog House", gameURL: "https://casino.example.com/games/the-dog-house", imageURL: "casinoGameDemo", rating: 4.4, provider: "Pragmatic Play", minStake: "XAF 60")
        ]
    }
    
    private func createSlotGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "slot-001", name: "Mega Moolah", gameURL: "https://casino.example.com/games/mega-moolah", imageURL: "casinoGameDemo", rating: 4.5, provider: "Microgaming", minStake: "XAF 25"),
            CasinoGameCardData(id: "slot-002", name: "Divine Fortune", gameURL: "https://casino.example.com/games/divine-fortune", imageURL: "casinoGameDemo", rating: 4.6, provider: "NetEnt", minStake: "XAF 40"),
            CasinoGameCardData(id: "slot-003", name: "Reactoonz", gameURL: "https://casino.example.com/games/reactoonz", imageURL: "casinoGameDemo", rating: 4.3, provider: "Play'n GO", minStake: "XAF 20"),
            CasinoGameCardData(id: "slot-004", name: "Jammin' Jars", gameURL: "https://casino.example.com/games/jammin-jars", imageURL: "casinoGameDemo", rating: 4.4, provider: "Push Gaming", minStake: "XAF 30"),
            CasinoGameCardData(id: "slot-005", name: "Wolf Gold", gameURL: "https://casino.example.com/games/wolf-gold", imageURL: "casinoGameDemo", rating: 4.7, provider: "Pragmatic Play", minStake: "XAF 50")
        ]
    }
    
    private func createLiveGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "live-001", name: "Live Blackjack", gameURL: "https://casino.example.com/games/live-blackjack", imageURL: "casinoGameDemo", rating: 4.9, provider: "Evolution Gaming", minStake: "XAF 500"),
            CasinoGameCardData(id: "live-002", name: "Live Roulette", gameURL: "https://casino.example.com/games/live-roulette", imageURL: "casinoGameDemo", rating: 4.8, provider: "NetEnt Live", minStake: "XAF 100"),
            CasinoGameCardData(id: "live-003", name: "Live Baccarat", gameURL: "https://casino.example.com/games/live-baccarat", imageURL: "casinoGameDemo", rating: 4.7, provider: "Pragmatic Play Live", minStake: "XAF 250"),
            CasinoGameCardData(id: "live-004", name: "Dream Catcher", gameURL: "https://casino.example.com/games/dream-catcher", imageURL: "casinoGameDemo", rating: 4.6, provider: "Evolution Gaming", minStake: "XAF 10"),
            CasinoGameCardData(id: "live-005", name: "Monopoly Live", gameURL: "https://casino.example.com/games/monopoly-live", imageURL: "casinoGameDemo", rating: 4.5, provider: "Evolution Gaming", minStake: "XAF 50")
        ]
    }
    
    private func createJackpotGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "jackpot-001", name: "Mega Fortune", gameURL: "https://casino.example.com/games/mega-fortune", imageURL: "casinoGameDemo", rating: 4.6, provider: "NetEnt", minStake: "XAF 50"),
            CasinoGameCardData(id: "jackpot-002", name: "Hall of Gods", gameURL: "https://casino.example.com/games/hall-of-gods", imageURL: "casinoGameDemo", rating: 4.5, provider: "NetEnt", minStake: "XAF 100"),
            CasinoGameCardData(id: "jackpot-003", name: "Arabian Nights", gameURL: "https://casino.example.com/games/arabian-nights", imageURL: "casinoGameDemo", rating: 4.4, provider: "NetEnt", minStake: "XAF 75"),
            CasinoGameCardData(id: "jackpot-004", name: "Age of the Gods", gameURL: "https://casino.example.com/games/age-of-the-gods", imageURL: "casinoGameDemo", rating: 4.3, provider: "Playtech", minStake: "XAF 25")
        ]
    }
    
    private func createTableGames() -> [CasinoGameCardData] {
        return [
            CasinoGameCardData(id: "table-001", name: "European Roulette", gameURL: "https://casino.example.com/games/european-roulette", imageURL: "casinoGameDemo", rating: 4.7, provider: "NetEnt", minStake: "XAF 10"),
            CasinoGameCardData(id: "table-002", name: "Classic Blackjack", gameURL: "https://casino.example.com/games/classic-blackjack", imageURL: "casinoGameDemo", rating: 4.8, provider: "NetEnt", minStake: "XAF 50"),
            CasinoGameCardData(id: "table-003", name: "Punto Banco", gameURL: "https://casino.example.com/games/punto-banco", imageURL: "casinoGameDemo", rating: 4.4, provider: "NetEnt", minStake: "XAF 25"),
            CasinoGameCardData(id: "table-004", name: "Caribbean Stud Poker", gameURL: "https://casino.example.com/games/caribbean-stud-poker", imageURL: "casinoGameDemo", rating: 4.3, provider: "NetEnt", minStake: "XAF 100"),
            CasinoGameCardData(id: "table-005", name: "Three Card Poker", gameURL: "https://casino.example.com/games/three-card-poker", imageURL: "casinoGameDemo", rating: 4.2, provider: "NetEnt", minStake: "XAF 75")
        ]
    }
    
    private func createDefaultGames() -> [CasinoGameCardData] {
        return createPopularGames() // Fallback to popular games
    }
}
