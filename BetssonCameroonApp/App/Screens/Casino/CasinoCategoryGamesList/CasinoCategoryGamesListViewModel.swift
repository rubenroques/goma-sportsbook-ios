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

enum LoadingState {
    case idle
    case initialLoading    // First time loading or reload (shows full screen spinner)
    case loadingMore      // Loading additional pages (shows button spinner)
}

class CasinoCategoryGamesListViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for CasinoCoordinator
    var onGameSelected: ((String) -> Void) = { _ in }
    var onNavigateBack: (() -> Void) = { }
    var onSportsQuickLinkSelected: ((QuickLinkType) -> Void)?

    private static let gamesPlatform = "PC"
    
    // MARK: - Published Properties
    @Published private(set) var games: [MockCasinoGameCardViewModel] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var categoryTitle: String
    
    // MARK: - Pagination Properties
    @Published private(set) var hasMoreGames: Bool = false
    
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var totalGames: Int = 0
    
    // MARK: - Computed Properties for UI
    var isShowingFullScreenLoader: Bool { loadingState == .initialLoading }
    var isLoadingMore: Bool { loadingState == .loadingMore }
    var isAnyLoading: Bool { loadingState != .idle }
    
    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModel
    // multiWidgetToolbarViewModel is now managed by TopBarContainerController
    
    // MARK: - Properties
    private let categoryId: String
    private let casinoCacheProvider: CasinoCacheProvider
    private let lobbyType: ServicesProvider.CasinoLobbyType?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(categoryId: String, categoryTitle: String, casinoCacheProvider: CasinoCacheProvider, lobbyType: ServicesProvider.CasinoLobbyType? = nil) {
        self.categoryId = categoryId
        self.categoryTitle = categoryTitle
        self.casinoCacheProvider = casinoCacheProvider
        self.lobbyType = lobbyType
        self.quickLinksTabBarViewModel = QuickLinksTabBarViewModel.forCasinoScreens()
        // multiWidgetToolbarViewModel is now managed by TopBarContainerController

        setupChildViewModelCallbacks()
        setupCacheUpdateSubscriptions()
        loadInitialGames()
    }
    
    // MARK: - Public Methods
    func reloadGames() {
        // Reset pagination state and reload from beginning
        currentPage = 0
        games.removeAll()
        totalGames = 0
        hasMoreGames = false
        loadInitialGames()
    }
    
    func loadMoreGames() {
        guard loadingState == .idle && hasMoreGames else { return }
        
        loadingState = .loadingMore
        currentPage += 1
        
        loadGamesFromAPI(isLoadingMore: true)
    }
    
    func gameSelected(_ gameId: String) {
        onGameSelected(gameId)
    }
    
    func navigateBack() {
        onNavigateBack()
    }
    
    // MARK: - Private Methods - API Integration

    /// Setup subscriptions to cache update publishers for silent background updates
    private func setupCacheUpdateSubscriptions() {
        // Subscribe to background game list updates from cache provider
        // Filter for updates matching this category
        casinoCacheProvider.gamesUpdatePublisher
            .filter { [weak self] updateData in
                updateData.categoryId == self?.categoryId
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateData in
                self?.handleSilentGamesUpdate(updateData.response, offset: updateData.offset)
            }
            .store(in: &cancellables)
    }

    /// Load initial games for the category (first page)
    private func loadInitialGames() {
        currentPage = 0
        loadGamesFromAPI(isLoadingMore: false)
    }
    
    /// Load games from API with pagination support
    private func loadGamesFromAPI(isLoadingMore: Bool) {
        if !isLoadingMore {
            loadingState = .initialLoading
            games.removeAll()
        }
        
        errorMessage = nil
        
        let pagination = CasinoPaginationParams(
            offset: currentPage * pageSize,
            limit: pageSize
        )
        
        let language = localized("current_language_code")

        casinoCacheProvider.getGamesByCategory(
            categoryId: categoryId,
            language: language,
            platform: Self.gamesPlatform,
            lobbyType: lobbyType,
            pagination: pagination
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.handleAPICompletion(completion, isLoadingMore: isLoadingMore)
            },
            receiveValue: { [weak self] gamesResponse in
                self?.handleGamesResponse(gamesResponse, isLoadingMore: isLoadingMore)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Handle API response with games data
    private func handleGamesResponse(_ gamesResponse: CasinoGamesResponse, isLoadingMore: Bool) {
        // Convert CasinoGame[] to CasinoGameCardData[] using ServiceProviderModelMapper
        let newGameCardData = gamesResponse.games.map {
            ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: $0)
        }
        
        // Convert to ViewModels
        let newGameViewModels = newGameCardData.map { gameData in
            let viewModel = MockCasinoGameCardViewModel(gameData: gameData)
            viewModel.onGameSelected = { [weak self] gameId in
                self?.gameSelected(gameId)
            }
            return viewModel
        }
        
        // Update games list
        if isLoadingMore {
            games.append(contentsOf: newGameViewModels)
        } else {
            games = newGameViewModels
        }
        
        // Reset loading state
        loadingState = .idle
        
        // Update pagination state
        totalGames = gamesResponse.total
        hasMoreGames = games.count < totalGames
    }
    
    /// Handle API completion (success or failure)
    private func handleAPICompletion(_ completion: Subscribers.Completion<ServiceProviderError>, isLoadingMore: Bool) {
        // Reset loading state on any completion
        loadingState = .idle
        
        switch completion {
        case .finished:
            break
        case .failure(let error):
            errorMessage = mapServiceProviderErrorToDisplayMessage(error)
            
            // Reset pagination state on error
            if !isLoadingMore {
                totalGames = 0
                hasMoreGames = false
            } else {
                // Revert page increment on load more failure
                currentPage = max(0, currentPage - 1)
            }
        }
    }
    
    /// Handle silent game list updates from background cache refresh
    /// Updates UI without showing loading spinner
    private func handleSilentGamesUpdate(_ gamesResponse: CasinoGamesResponse, offset: Int) {
        // Only process updates for offset 0 (first page) to avoid complexity
        guard offset == 0 else { return }

        // Convert to game card data
        let newGameCardData = gamesResponse.games.map {
            ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: $0)
        }

        // Convert to ViewModels
        let newGameViewModels = newGameCardData.map { gameData in
            let viewModel = MockCasinoGameCardViewModel(gameData: gameData)
            viewModel.onGameSelected = { [weak self] gameId in
                self?.gameSelected(gameId)
            }
            return viewModel
        }

        // Update games list silently (only first page to keep it simple)
        if currentPage == 0 && !games.isEmpty {
            games = newGameViewModels
            totalGames = gamesResponse.total
            hasMoreGames = games.count < totalGames
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
    
    private func setupChildViewModelCallbacks() {
        // QuickLinks tab bar callbacks
        quickLinksTabBarViewModel.onQuickLinkSelected = { [weak self] quickLinkType in
            self?.onSportsQuickLinkSelected?(quickLinkType)
        }
    }
}
