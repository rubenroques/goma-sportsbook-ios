import Combine
import UIKit

/// Mock implementation of `AdaptiveTabBarViewModelProtocol` for testing.
final public class MockAdaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<AdaptiveTabBarDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // Internal Source of Truth
    private var internalTabBars: [TabBar] // The original TabBar struct model
    private var internalActiveTabBarID: TabBarIdentifier

    // MARK: - Initialization
    public init(tabBars: [TabBar], activeTabBarIdentifier: TabBarIdentifier) {
        self.internalTabBars = tabBars
        self.internalActiveTabBarID = activeTabBarIdentifier

        // Initial display state construction
        let initialState = Self.constructDisplayState(tabBars: internalTabBars, activeTabBarID: internalActiveTabBarID)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - AdaptiveTabBarViewModelProtocol
    public func selectTab(itemID: TabItemIdentifier, inTabBarID: TabBarIdentifier) {
        guard let selectedTabBarIndex = internalTabBars.firstIndex(where: { $0.id == inTabBarID }) else {
            print("Error: Tab bar with ID \(inTabBarID) not found.")
            return
        }

        guard let selectedItemIndex = internalTabBars[selectedTabBarIndex].tabs.firstIndex(where: { $0.identifier == itemID }) else {
            print("Error: Item with ID \(itemID) not found in tab bar \(inTabBarID).")
            return
        }

        let selectedItem = internalTabBars[selectedTabBarIndex].tabs[selectedItemIndex]

        // 1. Update selected item in the tab bar where selection occurred
        internalTabBars[selectedTabBarIndex].selectedTabItemIdentifier = itemID

        // 2. Handle potential switch to another tab bar
        if let switchToTabBarID = selectedItem.switchToTabBar {
            if switchToTabBarID != internalActiveTabBarID {
                internalActiveTabBarID = switchToTabBarID

                // If switched, update the selected item in the NEW active tab bar
                // if an item with the same ID (itemID) exists there.
                if let newActiveTabBarIndex = internalTabBars.firstIndex(where: { $0.id == switchToTabBarID }) {
                    if internalTabBars[newActiveTabBarIndex].tabs.contains(where: { $0.identifier == itemID }) {
                        internalTabBars[newActiveTabBarIndex].selectedTabItemIdentifier = itemID
                    }
                    // If no item with 'itemID' exists, the new tab bar keeps its existing selected item.
                } else {
                     print("Error: Target tab bar \(switchToTabBarID) for switch not found.")
                }
            } else {
                // It's a switch to the same tab bar, effectively just a selection.
                // Ensure this tab bar is active if it wasn't (e.g., selection in an inactive tab bar that points to itself)
                internalActiveTabBarID = switchToTabBarID
            }
        } else {
            // No explicit switchToTabBar defined, so if the selection happened in a currently inactive tab bar,
            // make that tab bar active.
            if inTabBarID != internalActiveTabBarID {
                internalActiveTabBarID = inTabBarID
            }
        }

        // 3. Publish the new display state
        publishNewDisplayState()
    }

    // Helper to explicitly update tab bars if their structure changes
    public func updateTabBarsStructure(with newInternalTabBars: [TabBar]) {
        self.internalTabBars = newInternalTabBars
        // Validate activeTabBarID and selected items or reset them if necessary
        if !internalTabBars.contains(where: { $0.id == internalActiveTabBarID }) {
            internalActiveTabBarID = internalTabBars.first?.id ?? .home // Default if empty
        }
        // Ensure selectedTabItemIdentifiers are valid for each tab bar
        for i in 0..<internalTabBars.count {
            if !internalTabBars[i].tabs.contains(where: { $0.identifier == internalTabBars[i].selectedTabItemIdentifier }) {
                internalTabBars[i].selectedTabItemIdentifier = internalTabBars[i].tabs.first?.identifier ?? .sportsHome
            }
        }
        publishNewDisplayState()
    }

    // MARK: - Private Helper Methods
    private func publishNewDisplayState() {
        let newDisplayState = Self.constructDisplayState(tabBars: internalTabBars, activeTabBarID: internalActiveTabBarID)
        displayStateSubject.send(newDisplayState)
    }

    private static func constructDisplayState(tabBars: [TabBar], activeTabBarID: TabBarIdentifier) -> AdaptiveTabBarDisplayState {
        let displayTabBars = tabBars.map { tabBarModel -> TabBarDisplayData in
            let displayItems = tabBarModel.tabs.map { tabItemModel -> TabItemDisplayData in
                TabItemDisplayData(
                    identifier: tabItemModel.identifier,
                    title: tabItemModel.title,
                    icon: tabItemModel.icon,
                    isActive: (tabItemModel.identifier == tabBarModel.selectedTabItemIdentifier && tabBarModel.id == activeTabBarID),
                    switchToTabBar: tabItemModel.switchToTabBar
                )
            }
            return TabBarDisplayData(id: tabBarModel.id, items: displayItems)
        }
        return AdaptiveTabBarDisplayState(tabBars: displayTabBars, activeTabBarID: activeTabBarID)
    }
}

// MARK: - Preview Provider
extension MockAdaptiveTabBarViewModel {
    public static var defaultMock: MockAdaptiveTabBarViewModel {
        // MARK: - Home Tab Items (Default Mock)
        let homeItems: [TabItem] = [
            TabItem(identifier: .nextUpEvents,
                    title: LocalizationProvider.string("sports"),
                    icon: UIImage(named: "sports_home_bar_icon", in: Bundle.module, with: nil),
                    switchToTabBar: .home),
            TabItem(identifier: .inPlayEvents,
                    title: LocalizationProvider.string("live"),
                    icon: UIImage(named: "live_betting_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .myBets,
                    title: LocalizationProvider.string("my_bets"),
                    icon: UIImage(named: "bet_history_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .sportsSearch,
                    title: LocalizationProvider.string("search"),
                    icon: UIImage(named: "search_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .casinoHome,
                    title: LocalizationProvider.string("casino"),
                    icon: UIImage(named: "casino_bar_icon", in: Bundle.module, with: nil),
                    switchToTabBar: .casino),
        ]

        // MARK: - Casino Tab Items (Default Mock)
        let casinoItems: [TabItem] = [
            TabItem(identifier: .casinoHome,
                    title: LocalizationProvider.string("casino"),
                    icon: UIImage(named: "casino_home_bar_icon", in: Bundle.module, with: nil),
                    switchToTabBar: .casino),
            TabItem(identifier: .casinoVirtualSports,
                    title: LocalizationProvider.string("virtuals"),
                    icon: UIImage(named: "virtual_sports_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .casinoAviatorGame,
                    title: LocalizationProvider.string("aviator"),
                    icon: UIImage(named: "aviator_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .casinoSearch,
                    title: LocalizationProvider.string("search"),
                    icon: UIImage(named: "search_casino_bar_icon", in: Bundle.module, with: nil)),
            TabItem(identifier: .nextUpEvents,
                    title: LocalizationProvider.string("sports"),
                    icon: UIImage(named: "sports_home_bar_icon", in: Bundle.module, with: nil),
                    switchToTabBar: .home),
        ]

        let initialTabBars = [
            TabBar(id: .home, tabs: homeItems, selectedTabItemIdentifier: .nextUpEvents),
            TabBar(id: .casino, tabs: casinoItems, selectedTabItemIdentifier: .casinoHome),
        ]
        return MockAdaptiveTabBarViewModel(tabBars: initialTabBars, activeTabBarIdentifier: .home)
    }
}

