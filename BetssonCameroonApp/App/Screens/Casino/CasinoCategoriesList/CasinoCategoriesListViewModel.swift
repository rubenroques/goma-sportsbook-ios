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
    
    private static let gamesPlatform = "PC"
    
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
        
        setupChildViewModelCallbacks()
        loadCategoriesFromAPI()
    }
    
    // MARK: - Public Methods
    func reloadCategories() {
        loadCategoriesFromAPI()
    }
    
    func categoryButtonTapped(categoryId: String, categoryTitle: String) {
        onCategorySelected(categoryId, categoryTitle)
    }
    
    // MARK: - Private Methods - API Integration
    
    /// Main method to load casino categories and their preview games from API
    private func loadCategoriesFromAPI() {
        isLoading = true
        errorMessage = nil
        
        servicesProvider.getCasinoCategories(language: "en", platform: Self.gamesPlatform)
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
        
        return servicesProvider.getGamesByCategory(
            categoryId: category.id,
            language: "en",
            platform: Self.gamesPlatform,
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
            return "Casino service not available"
        case .unauthorized:
            return "Authentication required"
        default:
            return "Unable to load casino games. Please try again."
        }
    }
    
    /// Minimal fallback categories if API fails completely
    private func setupFallbackCategories() {
        categorySections = [MockCasinoCategorySectionViewModel.emptySection]
    }
    
    private func setupChildViewModelCallbacks() {
        // QuickLinks tab bar callbacks
        quickLinksTabBarViewModel.onTabSelected = { tabId in
            print("Casino Categories: Tab selected: \(tabId)")
            // Handle tab switching if needed
        }
    }
}
