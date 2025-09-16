//
//  TopBarContainerViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 16/09/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

class TopBarContainerViewModel: ObservableObject {

    // MARK: - Child ViewModels
    let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModel
    let walletStatusViewModel: WalletStatusViewModel

    // MARK: - Private Properties
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Authentication State
    @Published var isAuthenticated: Bool = false

    // MARK: - Initialization
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore

        // Create child ViewModels
        self.multiWidgetToolbarViewModel = MultiWidgetToolbarViewModel()
        self.walletStatusViewModel = WalletStatusViewModel(userSessionStore: userSessionStore)

        setupReactiveWalletChain()
    }

    // MARK: - Reactive Wallet Chain Setup
    private func setupReactiveWalletChain() {
        // Step 1: Set up base authentication state
        userSessionStore.userProfilePublisher
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)

        // Step 2: Reactive chain - Authentication state drives wallet UI updates
        $isAuthenticated
            .combineLatest(userSessionStore.userWalletPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated, wallet in
                guard let self = self else { return }

                if isAuthenticated {
                    // User is logged in - show logged in state and wallet data
                    let layoutState: LayoutState = .loggedIn
                    self.multiWidgetToolbarViewModel.setLayoutState(layoutState)

                    // Update wallet balance if available
                    if let walletBalance = wallet?.total {
                        self.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                        print("💰 TopBarContainer: Wallet balance updated - total: \(walletBalance)")
                    }

                    // Wallet status view model will update automatically via its own binding

                    print("🔐 TopBarContainer: User authenticated with wallet data")
                } else {
                    // User is logged out - show logged out state
                    let layoutState: LayoutState = .loggedOut
                    self.multiWidgetToolbarViewModel.setLayoutState(layoutState)

                    print("🔐 TopBarContainer: User logged out")
                }
            }
            .store(in: &cancellables)

        // Step 3: Additional wallet balance sync
        setupMultiWidgetToolbarBinding()
    }

    private func setupMultiWidgetToolbarBinding() {
        // Subscribe to wallet updates to keep the toolbar wallet widget in sync
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                if let walletBalance = wallet?.total {
                    self?.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                    print("💰 TopBarContainer: Toolbar wallet balance updated - total: \(walletBalance)")
                }
            }
            .store(in: &cancellables)
    }
}