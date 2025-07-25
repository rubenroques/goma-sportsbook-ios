//
//  ScreenType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/06/2025.
//

import UIKit
import Combine
import LocalAuthentication
import ServicesProvider
import GomaUI

class RootTabBarViewModel: ObservableObject {

    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    var adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol
    var floatingOverlayViewModel: FloatingOverlayViewModelProtocol

    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    private var lastActiveTabBarID: TabBarIdentifier?
    
    // MARK: - Authentication Publishers
    
    /// Publisher that emits user profile changes (for UI updates)
    var userProfilePublisher: AnyPublisher<UserProfile?, Never> {
        return userSessionStore.userProfilePublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that emits loading session state
    var isLoadingUserSessionPublisher: AnyPublisher<Bool, Never> {
        return userSessionStore.isLoadingUserSessionPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that emits whether authentication should be shown
    var shouldShowAuthenticationPublisher: AnyPublisher<Bool, Never> {
        return userSessionStore.isLoadingUserSessionPublisher
            .map { !$0 } // Show authentication UI when NOT loading
            .eraseToAnyPublisher()
    }

    init(userSessionStore: UserSessionStore,
         multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol = MockMultiWidgetToolbarViewModel.defaultMock,
         adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol = MockAdaptiveTabBarViewModel.defaultMock,
         floatingOverlayViewModel: FloatingOverlayViewModelProtocol = MockFloatingOverlayViewModel())
    {
        self.userSessionStore = userSessionStore
        self.multiWidgetToolbarViewModel = multiWidgetToolbarViewModel
        self.adaptiveTabBarViewModel = adaptiveTabBarViewModel
        self.floatingOverlayViewModel = floatingOverlayViewModel

        setupTabBarBinding()
    }
    
    func logoutUser() {
        userSessionStore.logout()
    }
    
    // MARK: - Authentication Business Logic
    
    /// Returns true if user authentication is required
    func shouldAuthenticateUser() -> Bool {
        return userSessionStore.shouldAuthenticateUser
    }
    
    /// Returns true if biometric authentication should be requested
    func shouldRequestBiometrics() -> Bool {
        return userSessionStore.shouldRequestBiometrics()
    }
    
    /// Returns true if user is logged in
    func isUserLogged() -> Bool {
        return userSessionStore.isUserLogged()
    }
    
    /// Unlocks app with authenticated user
    func unlockAppWithUser() {
        userSessionStore.startUserSession()
    }
    
    /// Unlocks app in anonymous mode
    func unlockAppAnonymous() {
        userSessionStore.logout()
    }
    
    /// Triggers biometric authentication check on app foreground
    func handleAppWillEnterForeground() -> Bool {
        return userSessionStore.shouldRequestBiometrics()
    }

    // MARK: - Private Methods
    private func setupTabBarBinding() {
        // Listen to tab bar active bar id changes
        adaptiveTabBarViewModel.displayStatePublisher
            .sink { [weak self] displayState in
                if self?.lastActiveTabBarID != nil && self?.lastActiveTabBarID != displayState.activeTabBarID {
                    switch displayState.activeTabBarID {
                    case .home:
                        // Switched to Sportsbook
                        self?.floatingOverlayViewModel.show(mode: .sportsbook, duration: 3.0)
                    case .casino:
                        // Switched to Casino
                        self?.floatingOverlayViewModel.show(mode: .casino, duration: 3.0)
                    }
                }
                self?.lastActiveTabBarID = displayState.activeTabBarID
            }
            .store(in: &cancellables)

    }

}
