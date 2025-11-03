//
//  CasinoGamePlayViewModel.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import Foundation
import Combine
import ServicesProvider
import WebKit

class CasinoGamePlayViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for CasinoCoordinator
    var onNavigateBack: (() -> Void) = { }
    var onDepositRequested: (() -> Void) = { }
    
    // MARK: - Published Properties
    @Published private(set) var gameURL: URL?
    @Published private(set) var gameTitle: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadingProgress: Double = 0.0
    @Published private(set) var errorMessage: String?
    @Published private(set) var canGoBack: Bool = false
    @Published private(set) var canGoForward: Bool = false
    
    // MARK: - Properties
    private let gameId: String
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    private var casinoGame: CasinoGame?
    
    // WebView reference for navigation control
    weak var webView: WKWebView? {
        didSet {
            setupWebViewObservers()
        }
    }
    
    // MARK: - Initialization

    /// Initialize with CasinoGame object and mode
    init(casinoGame: CasinoGame, mode: CasinoGamePlayMode, servicesProvider: ServicesProvider.Client) {
        self.gameId = casinoGame.id
        self.servicesProvider = servicesProvider
        self.casinoGame = casinoGame

        loadGameDataWithMode(mode: mode)
    }
    
    /// Initialize with gameId only (fallback - uses mock URLs)
    init(gameId: String, servicesProvider: ServicesProvider.Client) {
        self.gameId = gameId
        self.servicesProvider = servicesProvider
        self.casinoGame = nil
        
        loadGameData()
    }
    
    // MARK: - Public Methods

    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func refresh() {
        webView?.reload()
    }
    
    func stopLoading() {
        webView?.stopLoading()
    }
    
    func navigateBack() {
        onNavigateBack()
    }
    
    // MARK: - Private Methods
    private func loadGameData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network call to get game details - replace with real service call later
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let gameData = self.getGameData(for: self.gameId)
            self.gameTitle = gameData.title
            
            if let url = URL(string: gameData.url) {
                self.gameURL = url
            } else {
                self.errorMessage = "Invalid game URL"
            }
            
            self.isLoading = false
        }
    }
    
    /// Load game data with proper session injection
    private func loadGameDataWithMode(mode: CasinoGamePlayMode) {
        guard let casinoGame = casinoGame else {
            errorMessage = "No game data available"
            return
        }

        isLoading = true
        errorMessage = nil

        print("[🎰 VIEWMODEL] ═══════════════════════════════════════")
        print("[🎰 VIEWMODEL] Loading game: \(casinoGame.name)")
        print("[🎰 VIEWMODEL] Play mode: \(mode)")

        gameTitle = casinoGame.name

        // Convert CasinoGamePlayMode to CasinoGameMode
        let casinoGameMode: CasinoGameMode
        let isUserLoggedIn = Env.userSessionStore.isUserLogged()
        print("[🎰 VIEWMODEL] User logged in: \(isUserLoggedIn)")

        switch mode {
        case .practice:
            casinoGameMode = isUserLoggedIn ? .funLoggedIn : .funGuest
            print("[🎰 VIEWMODEL] Practice mode → \(casinoGameMode)")
        case .realMoney:
            casinoGameMode = .realMoney
            print("[🎰 VIEWMODEL] Real money mode → \(casinoGameMode)")
        }

        // ✅ Use buildCasinoGameLaunchUrl to inject session parameters
        print("[🎰 VIEWMODEL] Calling buildCasinoGameLaunchUrl()")
        if
            let urlString = servicesProvider.buildCasinoGameLaunchUrl(for: casinoGame, mode: casinoGameMode, language: "en"),
            let url = URL(string: urlString)
        {
            gameURL = url
            print("[🎰 VIEWMODEL] ✅ Final URL set")
        }
        else {
            errorMessage = "Failed to build game launch URL"
            print("[🎰 VIEWMODEL] ❌ buildCasinoGameLaunchUrl returned nil")
        }

        print("[🎰 VIEWMODEL] ═══════════════════════════════════════")

        isLoading = false
    }
    
    private func setupWebViewObservers() {
        guard let webView = webView else { return }
        
        // Observe loading progress
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.loadingProgress = progress
            }
            .store(in: &cancellables)
        
        // Observe loading state
        webView.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        // Observe navigation state
        webView.publisher(for: \.canGoBack)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoBack in
                self?.canGoBack = canGoBack
            }
            .store(in: &cancellables)
        
        webView.publisher(for: \.canGoForward)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoForward in
                self?.canGoForward = canGoForward
            }
            .store(in: &cancellables)
        
        // Observe title changes
        webView.publisher(for: \.title)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                if !title.isEmpty {
                    self?.gameTitle = title
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Mock Game Data
    private func getGameData(for gameId: String) -> (title: String, url: String) {
        switch gameId {
        case "new-001":
            return ("Dragon's Fortune", "https://demo.pragmaticplay.net/gs2c/openGame.do?lang=en&cur=EUR&gameSymbol=vs25dragonhatch&websiteUrl=https%3A%2F%2Fdemogamesfree.pragmaticplay.net")
        case "new-002":
            return ("Mega Wheel", "https://demo.pragmaticplay.net/gs2c/openGame.do?lang=en&cur=EUR&gameSymbol=lg_megawheel&websiteUrl=https%3A%2F%2Fdemogamesfree.pragmaticplay.net")
        case "popular-001":
            return ("Starburst", "https://www.netent.com/en/games/starburst")
        case "popular-002":
            return ("Book of Dead", "https://demo.playngonetwork.com/casino/BookofDead")
        case "live-001":
            return ("Live Blackjack", "https://www.evolution.com/live-casino/blackjack")
        case "jackpot-001":
            return ("Mega Fortune", "https://www.netent.com/en/games/mega-fortune")
        case "table-001":
            return ("European Roulette", "https://www.netent.com/en/games/european-roulette")
            
        // Add more games as needed
        default:
            return ("Casino Game", "https://demo.pragmaticplay.net/gs2c/openGame.do?lang=en&cur=EUR&gameSymbol=vs20fruitparty&websiteUrl=https%3A%2F%2Fdemogamesfree.pragmaticplay.net")
        }
    }
}

// MARK: - WKNavigationDelegate Methods Support
extension CasinoGamePlayViewModel {
    
    func webViewDidStartProvisionalNavigation() {
        isLoading = true
        errorMessage = nil
    }
    
    func webViewDidFinishNavigation() {
        isLoading = false
    }
    
    func webViewDidFailNavigation(with error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
    }
}
