//
//  AdaptiveTabBarViewModelProtocol.swift
//  GomaUI
//
//  Created by Ruben Roques on 19/05/2025.
//


//
//  AdaptiveTabBarViewModelProtocol.swift
//  WidgetAdaptiveKit
//
//  Created by Ruben Roques on 19/05/2025.
//
import Combine
import UIKit

// MARK: - Display State Structures

/// Represents the complete visual state for the AdaptiveTabBarView.
public struct AdaptiveTabBarDisplayState: Equatable {
    public let tabBars: [TabBarDisplayData]
    public let activeTabBarID: TabBarIdentifier
    // Add an initializer for easier construction
    public init(tabBars: [TabBarDisplayData], activeTabBarID: TabBarIdentifier) {
        self.tabBars = tabBars
        self.activeTabBarID = activeTabBarID
    }
}

/// Represents how a single TabBar (a set of tabs) should be displayed.
public struct TabBarDisplayData: Equatable, Hashable {
    public let id: TabBarIdentifier
    public let items: [TabItemDisplayData]
    // Add an initializer for easier construction
    public init(id: TabBarIdentifier, items: [TabItemDisplayData]) {
        self.id = id
        self.items = items
    }
}

/// Represents how a single TabItem should be displayed.
public struct TabItemDisplayData: Equatable, Hashable {
    public let identifier: TabItemIdentifier
    public let title: String
    public let icon: UIImage?
    public let isActive: Bool
    public let switchToTabBar: TabBarIdentifier? // For tap handling
    // Add an initializer for easier construction
    public init(identifier: TabItemIdentifier, title: String, icon: UIImage?, isActive: Bool, switchToTabBar: TabBarIdentifier?) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.switchToTabBar = switchToTabBar
    }
}


// MARK: - View Model Protocol

/// Protocol defining the essential requirements for a view model powering `AdaptiveTabBarView`.
public protocol AdaptiveTabBarViewModelProtocol {

    /// Publisher for the current display state of the tab bar view.
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> { get }

    /// Handles the selection of a tab.
    /// - Parameters:
    ///   - itemID: The identifier of the tab item that was selected.
    ///   - tabBarID: The ID of the tab bar where the selection occurred.
    func selectTab(itemID: TabItemIdentifier, inTabBarID: TabBarIdentifier)

}

// MARK: - Original Data Structures (can be kept for ViewModel's internal use or if needed elsewhere)
public enum TabBarIdentifier: String, Hashable {
    case home
    case casino
}

/// Identifies specific tab items within tab bars
public enum TabItemIdentifier: String, Hashable {
    // Home tab items
    case sportsHome
    case liveEvents
    case promotions
    case casinoLobby
    case myProfile
    case myBets
    case sportsSearch

    case nextUpEvents
    case inPlayEvents

    // Casino tab items
    case casinoHome
    case casinoSlots
    case casinoVirtualSports
    case casinoAviatorGame
    case casinoNewReleases
    case casinoExclusive
    case casinoSearch

    // Live tab items
    case live
    case liveHighlights
    case liveUpcoming
    case liveFootball
    case liveBasketball
    case liveTennis
    case liveResults

    // Promotions tab items
    case promoSpecial
    case promoDailyDeals
    case promoTournaments
    case promoWelcomeBonus

    // Profile tab items
    case profile
    case profileBonuses
    case profileHistory
    case profileSettings
}

public struct TabItem: Equatable, Hashable {
    public let identifier: TabItemIdentifier
    public let title: String
    public let icon: UIImage?
    public let switchToTabBar: TabBarIdentifier?

    public init(identifier: TabItemIdentifier, title: String, icon: UIImage? = nil, switchToTabBar: TabBarIdentifier? = nil) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.switchToTabBar = switchToTabBar
    }
}

public struct TabBar: Hashable {
    public var id: TabBarIdentifier // Made public for easier access if needed by VM
    public var tabs: [TabItem]      // Made public
    public var selectedTabItemIdentifier: TabItemIdentifier // Made public

    public init(id: TabBarIdentifier, tabs: [TabItem], selectedTabItemIdentifier: TabItemIdentifier) {
        self.id = id
        self.tabs = tabs
        self.selectedTabItemIdentifier = selectedTabItemIdentifier
    }
}

