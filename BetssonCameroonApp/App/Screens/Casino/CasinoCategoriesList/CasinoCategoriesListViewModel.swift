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
    var onGameSelected: ((String) -> Void) = { _ in }
    var onBannerGameSelected: ((String) -> Void) = { _ in }
    var onBannerURLSelected: ((String) -> Void) = { _ in }
    var onSportsQuickLinkSelected: ((QuickLinkType) -> Void)?
    var onCasinoQuickLinkSelected: ((QuickLinkType) -> Void)?
    
    private static let gamesPlatform = "PC"

    // MARK: - Lobby Configuration
    let lobbyType: ServicesProvider.CasinoLobbyType
    let showTopBanner: Bool

    // MARK: - Published Properties
    @Published private(set) var categorySections: [MockCasinoCategorySectionViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModel
    let topBannerSliderViewModel: TopBannerSliderViewModelProtocol?
    private(set) var recentlyPlayedGamesViewModel: MockRecentlyPlayedGamesViewModel
    
    // MARK: - Properties
    private let casinoCacheProvider: CasinoCacheProvider
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(casinoCacheProvider: CasinoCacheProvider, servicesProvider: ServicesProvider.Client, lobbyType: ServicesProvider.CasinoLobbyType = .casino, showTopBanner: Bool? = nil) {
        self.casinoCacheProvider = casinoCacheProvider
        self.servicesProvider = servicesProvider
        self.lobbyType = lobbyType
        self.showTopBanner = showTopBanner ?? (lobbyType == .casino)
        self.quickLinksTabBarViewModel = QuickLinksTabBarViewModel.forCasinoScreens()

        // Initialize production casino banner viewModel only if banners are enabled
        if self.showTopBanner {
            let casinoBannerViewModel = CasinoTopBannerSliderViewModel(servicesProvider: servicesProvider)
            self.topBannerSliderViewModel = casinoBannerViewModel
        } else {
            self.topBannerSliderViewModel = nil
        }

        // Initialize with empty recently played - will be populated when categories load
        self.recentlyPlayedGamesViewModel = MockRecentlyPlayedGamesViewModel.emptyRecentlyPlayed

        setupChildViewModelCallbacks()
        setupCacheUpdateSubscriptions()
        loadCategoriesFromAPI()
    }
    
    // MARK: - Public Methods
    func reloadCategories() {
        loadCategoriesFromAPI()
    }
    
    func categoryButtonTapped(categoryId: String, categoryTitle: String) {
        onCategorySelected(categoryId, categoryTitle)
    }
    
    func gameSelected(_ gameId: String) {
        onGameSelected(gameId)
    }
    
    // MARK: - Private Methods - API Integration
    
    /// Setup subscriptions to cache update publishers for silent background updates
    private func setupCacheUpdateSubscriptions() {
        // Subscribe to background category updates from cache provider
        casinoCacheProvider.categoriesUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedCategories in
                self?.handleSilentCategoriesUpdate(updatedCategories)
            }
            .store(in: &cancellables)
    }

    /// Main method to load casino categories and their preview games from API
    private func loadCategoriesFromAPI() {
        isLoading = true
        errorMessage = nil

        let language = localized("current_language_code")

        casinoCacheProvider.getCasinoCategories(language: language, platform: Self.gamesPlatform, lobbyType: lobbyType)
            .map { categories in
                // Filter categories with games available
                categories.filter { $0.gamesTotal > 0 }
            }
            .flatMap { validCategories in
                self.loadPreviewGamesForAllCategories(validCategories)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleAPICompletion(completion)
                },
                receiveValue: { [weak self] sectionViewModels in
                    self?.categorySections = sectionViewModels
                    self?.updateRecentlyPlayedFromCategories()
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    /// Load preview games for all categories concurrently while preserving order
    private func loadPreviewGamesForAllCategories(_ categories: [CasinoCategory]) -> AnyPublisher<[MockCasinoCategorySectionViewModel], ServiceProviderError> {
        let indexedPublishers = categories.enumerated().map { index, category in
            loadPreviewGamesForCategory(category)
                .map { sectionViewModel in
                    (index: index, sectionViewModel: sectionViewModel)
                }
        }
        
        return Publishers.MergeMany(indexedPublishers)
            .collect()
            .map { indexedResults in
                // Sort by original index to restore category order
                indexedResults
                    .sorted { $0.index < $1.index }
                    .map { $0.sectionViewModel }
            }
            .eraseToAnyPublisher()
    }
    
    /// Load preview games for a single category (10 games + See More card if needed)
    private func loadPreviewGamesForCategory(_ category: CasinoCategory) -> AnyPublisher<MockCasinoCategorySectionViewModel, ServiceProviderError> {
        let pagination = CasinoPaginationParams(offset: 0, limit: 10) // Load 10 games as requested
        
        let language = localized("current_language_code")

        return casinoCacheProvider.getGamesByCategory(
            categoryId: category.id,
            language: language,
            platform: Self.gamesPlatform,
            lobbyType: lobbyType,
            pagination: pagination
        )
        .map { gamesResponse in
            // Convert CasinoGame[] to CasinoGameCardData[]
            let gameCardData = gamesResponse.games.map { 
                ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: $0)
            }
            
            // Add "See More" card if there are more games available
            let gamesWithSeeMore = self.addSeeMoreCardIfNeeded(
                games: gameCardData,
                category: category,
                totalGames: gamesResponse.total
            )
            
            // Create section data using mapping
            let sectionData = ServiceProviderModelMapper.casinoCategorySectionData(
                fromCasinoCategory: category,
                games: gamesWithSeeMore
            )
            
            // Create section ViewModel
            return MockCasinoCategorySectionViewModel(sectionData: sectionData)
        }
        .eraseToAnyPublisher()
    }
    
    /// Add "See More" card if there are additional games beyond the loaded ones
    private func addSeeMoreCardIfNeeded(
        games: [CasinoGameCardData],
        category: CasinoCategory,
        totalGames: Int
    ) -> [CasinoGameCardData] {
        guard games.count < totalGames else {
            return games // No more games available
        }
        
        let remainingGamesCount = totalGames - games.count
        let seeMoreCard = ServiceProviderModelMapper.seeMoreCard(
            categoryId: category.id,
            remainingGamesCount: remainingGamesCount
        )
        
        return games + [seeMoreCard]
    }
    
    /// Handle API completion (success or failure)
    private func handleAPICompletion(_ completion: Subscribers.Completion<ServiceProviderError>) {
        isLoading = false
        
        switch completion {
        case .finished:
            break
        case .failure(let error):
            errorMessage = mapServiceProviderErrorToDisplayMessage(error)
            
            // Fallback to minimal mock data if API fails completely
            if categorySections.isEmpty {
                setupFallbackCategories()
            }
        }
    }
    
    /// Map ServiceProviderError to user-friendly display messages
    private func mapServiceProviderErrorToDisplayMessage(_ error: ServiceProviderError) -> String {
        switch error {
        case .casinoProviderNotFound:
            return localized("casino_service_unavailable")
        case .unauthorized:
            return localized("casino_authentication_required")
        default:
            return localized("casino_unable_to_load_games")
        }
    }
    
    /// Minimal fallback categories if API fails completely
    private func setupFallbackCategories() {
        categorySections = [MockCasinoCategorySectionViewModel.emptySection]
    }
    
    /// Handle silent category updates from background cache refresh
    /// Updates UI without showing loading spinner
    private func handleSilentCategoriesUpdate(_ categories: [CasinoCategory]) {
        // Filter categories with games available
        let validCategories = categories.filter { $0.gamesTotal > 0 }

        // Reload preview games for updated categories
        loadPreviewGamesForAllCategories(validCategories)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Silent update failed: \(error)")
                    }
                },
                receiveValue: { [weak self] sectionViewModels in
                    self?.categorySections = sectionViewModels
                    self?.updateRecentlyPlayedFromCategories()
                }
            )
            .store(in: &cancellables)
    }

    /// Update recently played games with first game from each loaded category
    private func updateRecentlyPlayedFromCategories() {
        // Extract first game from each category section (excluding "See More" cards)
        let recentGames = categorySections.compactMap { section -> RecentlyPlayedGameData? in
            // Get first real game (not a "See More" card)
            guard let firstGame = section.sectionData.games.first(where: { !$0.id.contains("see-more") }) else {
                return nil
            }
            
            // Convert CasinoGameCardData to RecentlyPlayedGameData
            return ServiceProviderModelMapper.recentlyPlayedGameData(fromCasinoGameCardData: firstGame)
        }
        
        // Take up to 5 games to avoid overcrowding the recently played section
        let limitedGames = Array(recentGames.prefix(5))
        
        // Update the recently played games ViewModel
        recentlyPlayedGamesViewModel.updateGames(limitedGames)
    }

    /// Handle banner action from casino banner tap
    private func handleBannerAction(_ action: CasinoBannerAction) {
        switch action {
        case .launchGame(let gameId):
            onBannerGameSelected(gameId)
        case .openURL(let url):
            onBannerURLSelected(url)
        case .none:
            print("Casino banner tapped with no action")
        }
    }

    private func setupChildViewModelCallbacks() {
        // QuickLinks tab bar callbacks
        quickLinksTabBarViewModel.onQuickLinkSelected = { [weak self] quickLinkType in
            if quickLinkType == .lite {
                self?.onCasinoQuickLinkSelected?(quickLinkType)
            }
            else {
                self?.onSportsQuickLinkSelected?(quickLinkType)
            }
        }

        // Casino banner callbacks - only setup if banner is enabled
        if let casinoBannerViewModel = topBannerSliderViewModel as? CasinoTopBannerSliderViewModel {
            casinoBannerViewModel.onBannerAction = { [weak self] action in
                self?.handleBannerAction(action)
            }
        }
    }
}
