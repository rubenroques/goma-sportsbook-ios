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

enum ScreenType {
    // Sportsbook tab items
    case home
    case nextUpEvents
    case inPlayEvents
    case myBets
    case search

    // Casino tab items
    case casinoHome
    case casinoVirtualSports
    case casinoAviatorGame
    case casinoSearch
}

class RootAdaptiveScreenViewModel: ObservableObject {

    @Published var currentScreen: ScreenType?

    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    var adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol
    var floatingOverlayViewModel: FloatingOverlayViewModelProtocol

    private var cancellables = Set<AnyCancellable>()
    private var lastActiveTabBarID: TabBarIdentifier?

    init(multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol = MockMultiWidgetToolbarViewModel.defaultMock,
         adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol = MockAdaptiveTabBarViewModel.defaultMock,
         floatingOverlayViewModel: FloatingOverlayViewModelProtocol = MockFloatingOverlayViewModel())
    {
        self.multiWidgetToolbarViewModel = multiWidgetToolbarViewModel
        self.adaptiveTabBarViewModel = adaptiveTabBarViewModel
        self.floatingOverlayViewModel = floatingOverlayViewModel

        setupTabBarBinding()
    }

    // MARK: - Screen Management
    func presentScreen(_ screenType: ScreenType) {
        currentScreen = screenType
    }

    func hideCurrentScreen() {
        currentScreen = nil
    }
    
    func logoutUser() {
        Env.userSessionStore.logout()
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
