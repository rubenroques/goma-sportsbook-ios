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
    
    /// Load game data with proper session injection
    private func loadGameDataWithMode(mode: CasinoGamePlayMode) {
        guard let casinoGame = casinoGame else {
            errorMessage = localized("casino_no_game_data")
            return
        }

        isLoading = true
        errorMessage = nil

        gameTitle = casinoGame.name

        // Convert CasinoGamePlayMode to CasinoGameMode
        let casinoGameMode: CasinoGameMode
        let isUserLoggedIn = Env.userSessionStore.isUserLogged()

        switch mode {
        case .practice:
            casinoGameMode = isUserLoggedIn ? .funLoggedIn : .funGuest
        case .realMoney:
            casinoGameMode = .realMoney
        }

        let language = LanguageManager.shared.currentLanguageCode
        
        if let urlString = servicesProvider.buildCasinoGameLaunchUrl(for: casinoGame, mode: casinoGameMode, language: language), let url = URL(string: urlString) {
            gameURL = url
        }
        else {
            errorMessage = localized("casino_failed_build_url")
        }

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
