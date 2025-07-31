//
//  CasinoCategoriesListViewModel.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class CasinoCategoriesListViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for CasinoCoordinator
    var onCategorySelected: ((String, String) -> Void) = { _, _ in }
    
    // MARK: - Published Properties
    @Published private(set) var categorySections: [MockCasinoCategorySectionViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: MockQuickLinksTabBarViewModel
    let topBannerSliderViewModel: TopBannerSliderViewModelProtocol
    let recentlyPlayedGamesViewModel: RecentlyPlayedGamesViewModelProtocol
    
    // MARK: - Properties
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.topBannerSliderViewModel = MockTopBannerSliderViewModel.casinoGameMock
        self.recentlyPlayedGamesViewModel = MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed
        
        setupCategorySections()
        setupChildViewModelCallbacks()
    }
    
    // MARK: - Public Methods
    func reloadCategories() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network call - replace with real service call later
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupCategorySections()
            self?.isLoading = false
        }
    }
    
    func categoryButtonTapped(categoryId: String, categoryTitle: String) {
        onCategorySelected(categoryId, categoryTitle)
    }
    
    // MARK: - Private Methods
    private func setupCategorySections() {
        // Create mock casino category sections using existing GomaUI components
        categorySections = [
            MockCasinoCategorySectionViewModel.newGamesSection,
            MockCasinoCategorySectionViewModel.popularGamesSection,
            MockCasinoCategorySectionViewModel.slotGamesSection,
            createLiveGamesSection(),
            createJackpotGamesSection(),
            createTableGamesSection()
        ]
        
        // Setup callbacks for each section
        setupSectionCallbacks()
    }
    
    private func setupSectionCallbacks() {
        // Callbacks will be set up in the view controller when creating CasinoCategorySectionViews
        // This keeps the separation of concerns - ViewModels don't know about UI callbacks directly
    }
    
    private func setupChildViewModelCallbacks() {
        // QuickLinks tab bar callbacks
        quickLinksTabBarViewModel.onTabSelected = { tabId in
            print("Casino Categories: Tab selected: \(tabId)")
            // Handle tab switching if needed
        }
    }
    
    // MARK: - Mock Category Sections
    private func createLiveGamesSection() -> MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "live-001",
                name: "Live Blackjack",
                gameURL: "https://casino.example.com/games/live-blackjack",
                imageURL: "casinoGameDemo",
                rating: 4.9,
                provider: "Evolution Gaming",
                minStake: "XAF 500"
            ),
            CasinoGameCardData(
                id: "live-002",
                name: "Live Roulette",
                gameURL: "https://casino.example.com/games/live-roulette",
                imageURL: "casinoGameDemo",
                rating: 4.8,
                provider: "NetEnt Live",
                minStake: "XAF 100"
            ),
            CasinoGameCardData(
                id: "live-003",
                name: "Live Baccarat",
                gameURL: "https://casino.example.com/games/live-baccarat",
                imageURL: "casinoGameDemo",
                rating: 4.7,
                provider: "Pragmatic Play Live",
                minStake: "XAF 250"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "live-games",
            categoryTitle: "Live Games",
            categoryButtonText: "All 23",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    private func createJackpotGamesSection() -> MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "jackpot-001",
                name: "Mega Fortune",
                gameURL: "https://casino.example.com/games/mega-fortune",
                imageURL: "casinoGameDemo",
                rating: 4.6,
                provider: "NetEnt",
                minStake: "XAF 50"
            ),
            CasinoGameCardData(
                id: "jackpot-002",
                name: "Hall of Gods",
                gameURL: "https://casino.example.com/games/hall-of-gods",
                imageURL: "casinoGameDemo",
                rating: 4.5,
                provider: "NetEnt",
                minStake: "XAF 100"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "jackpot-games",
            categoryTitle: "Jackpot Games",
            categoryButtonText: "All 12",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
    
    private func createTableGamesSection() -> MockCasinoCategorySectionViewModel {
        let games = [
            CasinoGameCardData(
                id: "table-001",
                name: "European Roulette",
                gameURL: "https://casino.example.com/games/european-roulette",
                imageURL: "casinoGameDemo",
                rating: 4.7,
                provider: "NetEnt",
                minStake: "XAF 10"
            ),
            CasinoGameCardData(
                id: "table-002",
                name: "Classic Blackjack",
                gameURL: "https://casino.example.com/games/classic-blackjack",
                imageURL: "casinoGameDemo",
                rating: 4.8,
                provider: "NetEnt",
                minStake: "XAF 50"
            ),
            CasinoGameCardData(
                id: "table-003",
                name: "Punto Banco",
                gameURL: "https://casino.example.com/games/punto-banco",
                imageURL: "casinoGameDemo",
                rating: 4.4,
                provider: "NetEnt",
                minStake: "XAF 25"
            )
        ]
        
        let sectionData = CasinoCategorySectionData(
            id: "table-games",
            categoryTitle: "Table Games",
            categoryButtonText: "All 18",
            games: games
        )
        
        return MockCasinoCategorySectionViewModel(sectionData: sectionData)
    }
}
