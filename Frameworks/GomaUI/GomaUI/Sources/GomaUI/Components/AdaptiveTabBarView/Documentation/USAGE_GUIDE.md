# Usage Guide

This guide explains how to integrate and use the `AdaptiveTabBarView` component in your iOS application.

## 1. Prepare your ViewModel

First, you need a class that conforms to the `AdaptiveTabBarViewModelProtocol`. This ViewModel will be responsible for managing the state of the tab bar.

```swift
import Combine
import UIKit
// Make sure to import GomaUI or the relevant module where AdaptiveTabBarView components are defined.

class MyCustomTabBarViewModel: AdaptiveTabBarViewModelProtocol {

    private let displayStateSubject: CurrentValueSubject<AdaptiveTabBarDisplayState, Never>
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    // Internal state for your tab bars
    private var internalTabBars: [TabBar] // Using the original TabBar/TabItem for internal logic
    private var internalActiveTabBarID: TabBarIdentifier

    init() {
        // Initialize your internalTabBars and internalActiveTabBarID with your desired default state
        // For example, using a structure similar to MockAdaptiveTabBarViewModel.defaultMock
        self.internalTabBars = /* ... your initial TabBar array ... */
        self.internalActiveTabBarID = /* ... your initial active TabBarIdentifier ... */
        
        let initialState = Self.constructDisplayState(tabBars: internalTabBars, activeTabBarID: internalActiveTabBarID)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    func selectTab(itemID: String, inTabBarID: TabBarIdentifier) {
        // 1. Find the TabBar and TabItem based on IDs from internalTabBars
        guard let selectedTabBarIndex = internalTabBars.firstIndex(where: { $0.id == inTabBarID }),
              let selectedItemIndex = internalTabBars[selectedTabBarIndex].tabs.firstIndex(where: { $0.identifier == itemID }) else {
            print("Error: Tab or item not found during selection.")
            return
        }
        let selectedItem = internalTabBars[selectedTabBarIndex].tabs[selectedItemIndex]

        // 2. Update selected item in the tab bar where selection occurred
        internalTabBars[selectedTabBarIndex].selectedTabItemIdentifier = itemID

        // 3. Handle potential switch to another tab bar
        if let switchToTabBarID = selectedItem.switchToTabBar {
            if switchToTabBarID != internalActiveTabBarID {
                internalActiveTabBarID = switchToTabBarID
                // If switched, also update the selected item in the NEW active tab bar
                // if an item with the same 'itemID' (original selected item's ID) exists there.
                if let newActiveTabBarIndex = internalTabBars.firstIndex(where: { $0.id == switchToTabBarID }) {
                    if internalTabBars[newActiveTabBarIndex].tabs.contains(where: { $0.identifier == itemID }) {
                        internalTabBars[newActiveTabBarIndex].selectedTabItemIdentifier = itemID
                    }
                }
            } else {
                internalActiveTabBarID = switchToTabBarID // Ensure current tab bar is active
            }
        } else {
            // No explicit switchToTabBar: if selection in inactive bar, make it active.
            if inTabBarID != internalActiveTabBarID {
                internalActiveTabBarID = inTabBarID
            }
        }
        
        // 4. Publish the new display state
        publishNewDisplayState()
    }

    private func publishNewDisplayState() {
        let newDisplayState = Self.constructDisplayState(tabBars: internalTabBars, activeTabBarID: internalActiveTabBarID)
        displayStateSubject.send(newDisplayState)
    }

    // Static helper to transform internal model to display state (as in Mock)
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
    
    // Method to update tab bar structure dynamically if needed
    public func updateTabBarStructure(newTabBars: [TabBar], newActiveId: TabBarIdentifier) {
        self.internalTabBars = newTabBars
        self.internalActiveTabBarID = newActiveId
        // Add validation as in MockAdaptiveTabBarViewModel.updateTabBarsStructure if necessary
        publishNewDisplayState()
    }
}
```

(You would adapt the `MockAdaptiveTabBarViewModel`'s logic for `selectTab` and state construction into your custom ViewModel.)

## 2. Instantiate and Add `AdaptiveTabBarView` to Your UI

In your UIViewController or SwiftUI view (using `UIViewRepresentable`), create an instance of your ViewModel and then the `AdaptiveTabBarView`.

```swift
// In a UIViewController

class MyViewController: UIViewController {
    let tabBarViewModel = MyCustomTabBarViewModel() // Or your actual ViewModel
    var adaptiveTabBar: AdaptiveTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adaptiveTabBar = AdaptiveTabBarView(viewModel: tabBarViewModel)
        adaptiveTabBar.translatesAutoresizingMaskIntoConstraints = false // Important for AutoLayout
        
        view.addSubview(adaptiveTabBar)
        
        // Setup constraints for the adaptiveTabBar
        NSLayoutConstraint.activate([
            adaptiveTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adaptiveTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adaptiveTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // The height is managed internally by AdaptiveTabBarView (default 52pts)
            // adaptiveTabBar.heightAnchor.constraint(equalToConstant: 52) // Usually not needed here
        ])
        
        // Handle tab selection callback
        adaptiveTabBar.onTabSelected = { [weak self] selectedTabItem in
            print("Tab selected: \(selectedTabItem.title) (ID: \(selectedTabItem.identifier))")
            // Add your navigation logic or other actions here based on the selectedTabItem
            // For example, switch child view controllers, navigate to a new screen, etc.
        }
    }
}
```

## 3. Handling Tab Selections

The `AdaptiveTabBarView` provides an `onTabSelected` closure. This closure is called whenever a tab item is tapped *after* the ViewModel has processed the selection.

```swift
adaptiveTabBar.onTabSelected = { selectedTabItem_fromView in
    // The `selectedTabItem_fromView` is a `TabItem` struct (reconstructed by the view for this callback).
    // You can use its `identifier`, `title`, etc., to drive UI changes in your main content area.
    // For example:
    // switch selectedTabItem_fromView.identifier {
    // case "home_overview":
    //     showHomeController()
    // case "casino_slots":
    //     showCasinoSlotsController()
    // default:
    //     break
    // }
}
```

## 4. Dynamic Updates

If you need to change the structure of the tab bars or the active tab bar programmatically (e.g., due to user login, feature flags, etc.), you would typically add a method to your ViewModel (like `updateTabBarStructure` shown above). Calling this method would update the ViewModel's internal state and trigger a new `AdaptiveTabBarDisplayState` emission, which the `AdaptiveTabBarView` will automatically render.

That's it! With these steps, you can integrate a powerful and flexible tab bar into your application. 