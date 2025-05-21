//
//  AdaptiveTabBarViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//

import Combine
import UIKit
import PresentationProvider

final class AdaptiveTabBarViewModel {
    // MARK: - Types
    struct TabItem: Equatable, Hashable {
        let identifier: String
        let title: String
        let icon: UIImage?
        let remoteIconURL: String?

        static func == (lhs: TabItem, rhs: TabItem) -> Bool {
            lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }

        init(identifier: String, title: String, icon: UIImage? = nil, remoteIconURL: String? = nil) {
            self.identifier = identifier
            self.title = title
            self.icon = icon
            self.remoteIconURL = remoteIconURL
        }

        // Helper to create from PresentationProvider.TabItem
        init?(from providerTab: PresentationProvider.TabItem) {
            self.identifier = providerTab.tabId.rawValue
            self.title = providerTab.label
            self.icon = UIImage(named: providerTab.icon) // Use the icon name from provider
            self.remoteIconURL = nil // Remote icons not supported in current PresentationProvider
        }

        // Convenience static properties for common tabs
        static let home = TabItem(identifier: "home", title: localized("home"), icon: UIImage(named: "tabbar_home_icon"))
        static let preLive = TabItem(identifier: "prelive", title: localized("sports"), icon: UIImage(named: "tabbar_sports_icon"))
        static let live = TabItem(identifier: "live", title: localized("live"), icon: UIImage(named: "tabbar_live_icon"))
        static let tickets = TabItem(identifier: "mybets", title: localized("my_tickets"), icon: UIImage(named: "tabbar_my_tickets"))
        static let casino = TabItem(identifier: "casino", title: localized("casino"), icon: UIImage(named: "casino_icon"))
    }

    // MARK: - Published Properties
    @Published private(set) var selectedTab: TabItem?
    @Published private(set) var visibleTabs: [TabItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error? = nil

    // New properties for navbar management
    @Published private(set) var selectedNavbarId: NavbarIdentifier
    @Published private(set) var availableNavbars: [NavigationBarLayout] = []

    // MARK: - Private Properties
    private let configStore: PresentationConfigurationStore
    private var cancellables = Set<AnyCancellable>()
    private let initialTabPreference: TabItem? // To remember user's initial choice or default
    private let initialNavbarId: NavbarIdentifier

    // MARK: - Initialization
    init(
        initialTab: TabItem? = .home,
        initialNavbarId: NavbarIdentifier = .sports,
        configStore: PresentationConfigurationStore
    ) {
        self.initialTabPreference = initialTab
        self.selectedTab = initialTab
        self.initialNavbarId = initialNavbarId
        self.selectedNavbarId = initialNavbarId
        self.configStore = configStore

        setupBindings()
        configStore.loadConfiguration() // Trigger loading
    }

    // MARK: - Public Methods
    func selectTab(_ tab: TabItem) {
        guard visibleTabs.contains(tab) else {
            print("Warning: Attempted to select a tab (\(tab.title)) that is not currently visible.")
            return
        }
        selectedTab = tab
    }

    func switchToNavbar(_ navbarId: NavbarIdentifier) {
        guard availableNavbars.contains(where: { $0.id == navbarId }) else {
            print("Warning: Attempted to switch to navbar that is not available: \(navbarId)")
            return
        }
        selectedNavbarId = navbarId
        updateVisibleTabsForCurrentNavbar()
    }

    func refreshConfiguration() {
        configStore.loadConfiguration(forceRefresh: true)
    }

    // MARK: - Private Methods
    private func setupBindings() {
        configStore.loadState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadState in
                guard let self = self else { return }

                self.isLoading = loadState.isLoading
                self.error = loadState.error // Capture error state

                if case .loaded(let presentationConfig) = loadState {
                    self.error = nil // Clear previous error on successful load
                    self.availableNavbars = presentationConfig.navbars

                    // Validate selected navbar
                    if !self.availableNavbars.contains(where: { $0.id == self.selectedNavbarId }) {
                        // If current navbar is invalid, try to use initial navbar
                        if self.availableNavbars.contains(where: { $0.id == self.initialNavbarId }) {
                            self.selectedNavbarId = self.initialNavbarId
                        } else {
                            // Fallback to first available navbar
                            self.selectedNavbarId = self.availableNavbars.first?.id ?? .sports
                        }
                    }

                    self.updateVisibleTabsForCurrentNavbar()
                } else if self.error != nil {
                    // Handle error state explicitly, e.g., by setting empty or default tabs
                    print("Error loading presentation configuration: \(self.error?.localizedDescription ?? "Unknown error")")
                    // self.visibleTabs = [] // Or some default fallback
                    // self.selectedTab = .home // Or clear selected tab
                }
            }
            .store(in: &cancellables)
    }

    private func updateVisibleTabsForCurrentNavbar() {
        guard let currentNavbar = availableNavbars.first(where: { $0.id == selectedNavbarId }) else {
            visibleTabs = []
            selectedTab = nil
            return
        }

        let newVisibleTabs = configStore.tabItems(forNavbar: selectedNavbarId)
            .compactMap { TabItem(from: $0) }

        visibleTabs = newVisibleTabs

        // Update selected tab
        if newVisibleTabs.isEmpty {
            selectedTab = nil
        } else if let currentTab = selectedTab, newVisibleTabs.contains(currentTab) {
            // Current tab is still valid
        } else if let preferredTab = initialTabPreference, newVisibleTabs.contains(preferredTab) {
            selectedTab = preferredTab
        } else {
            selectedTab = newVisibleTabs.first
        }
    }
}

class MockPresentationService: PresentationConfigurationServicing {

    enum MockPresentationServiceError: Error {

    }

    var presentationConfiguration: PresentationConfiguration

    init(presentationConfiguration: PresentationConfiguration) {
        self.presentationConfiguration = presentationConfiguration
    }

    func fetchPresentationConfiguration() -> AnyPublisher<PresentationProvider.PresentationConfiguration, Error> {
        return Just(self.presentationConfiguration).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

}

// MARK: - Preview Helpers
extension AdaptiveTabBarViewModel {
    static func mockViewModel(
        initialTab: TabItem? = .home,
        initialNavbarId: NavbarIdentifier = .sports,
        providerTabs: [PresentationProvider.TabItem],
        navbars: [NavigationBarLayout],
        serviceError: Error? = nil
    ) -> AdaptiveTabBarViewModel {
        let mockPConfig = PresentationConfiguration(
            tabItems: providerTabs,
            navbars: navbars
        )

        let mockService = MockPresentationService(
            presentationConfiguration: mockPConfig
        )
        let store = PresentationConfigurationStore(configurationService: mockService, cacheTimeout: 0)

        return AdaptiveTabBarViewModel(
            initialTab: initialTab,
            initialNavbarId: initialNavbarId,
            configStore: store
        )
    }

    static func mockDefault() -> AdaptiveTabBarViewModel {
        let sportsNavbar = NavigationBarLayout(
            id: .sports,
            route: "/sports",
            tabs: [.sports, .live]
        )

        return self.mockViewModel(
            providerTabs: [
                .init(tabId: .sports, route: "/sports", label: "Sports", icon: "tabbar_sports_icon", context: "sports"),
                .init(tabId: .live, route: "/live", label: "Live", icon: "tabbar_live_icon", context: "sports")
            ],
            navbars: [sportsNavbar]
        )
    }

    static func mockAllFeatures() -> AdaptiveTabBarViewModel {
        let sportsNavbar = NavigationBarLayout(
            id: .sports,
            route: "/sports",
            tabs: [.sports, .live, .mybets]
        )

        let casinoNavbar = NavigationBarLayout(
            id: .casino,
            route: "/casino",
            tabs: [.casino]
        )

        return self.mockViewModel(
            providerTabs: [
                .init(tabId: .sports, route: "/sports", label: "Sports", icon: "tabbar_sports_icon", context: "sports"),
                .init(tabId: .live, route: "/live", label: "Live", icon: "tabbar_live_icon", context: "sports"),
                .init(tabId: .mybets, route: "/tickets", label: "Tickets", icon: "tabbar_my_tickets", context: "sports"),
                .init(tabId: .casino, route: "/casino", label: "Casino", icon: "casino_icon", context: "casino")
            ],
            navbars: [sportsNavbar, casinoNavbar]
        )
    }

    static func mockWithCasinoSelected() -> AdaptiveTabBarViewModel {
        let sportsNavbar = NavigationBarLayout(
            id: .sports,
            route: "/sports",
            tabs: [.sports]
        )

        let casinoNavbar = NavigationBarLayout(
            id: .casino,
            route: "/casino",
            tabs: [.casino]
        )

        return self.mockViewModel(
            initialTab: .casino,
            initialNavbarId: .casino,
            providerTabs: [
                .init(tabId: .sports, route: "/sports", label: "Sports", icon: "tabbar_sports_icon", context: "sports"),
                .init(tabId: .casino, route: "/casino", label: "Casino", icon: "casino_icon", context: "casino")
            ],
            navbars: [sportsNavbar, casinoNavbar]
        )
    }

    static func mockWithError() -> AdaptiveTabBarViewModel {
        return self.mockViewModel(
            providerTabs: [],
            navbars: [],
            serviceError: NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load configuration"])
        )
    }

    static func mockLoading() -> AdaptiveTabBarViewModel {
        class NeverCompletingService: PresentationConfigurationServicing {
            func fetchPresentationConfiguration() -> AnyPublisher<PresentationConfiguration, Error> {
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
        }
        let store = PresentationConfigurationStore(configurationService: NeverCompletingService(), cacheTimeout: 0)
        return AdaptiveTabBarViewModel(configStore: store)
    }
}
