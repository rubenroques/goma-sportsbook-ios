# `AdaptiveTabBarViewModelProtocol`

This document provides a detailed specification for the `AdaptiveTabBarViewModelProtocol`. Any class that acts as a ViewModel for the `AdaptiveTabBarView` must conform to this protocol.

## Protocol Definition

```swift
import Combine
import UIKit // For UIImage if used in TabItemDisplayData directly or indirectly

public protocol AdaptiveTabBarViewModelProtocol {

    /// Publisher for the current display state of the tab bar view.
    /// The ViewModel emits new `AdaptiveTabBarDisplayState` values through this publisher
    /// whenever any aspect of the tab bar's state or structure changes.
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> { get }

    /// Handles the selection of a tab.
    /// This method is called by the `AdaptiveTabBarView` when a user taps on a tab item.
    /// The ViewModel is responsible for processing this selection, updating its internal state,
    /// (which may include changing the active tab, switching tab bars, etc.),
    /// and subsequently emitting a new `AdaptiveTabBarDisplayState`.
    ///
    /// - Parameters:
    ///   - itemID: The `identifier` of the `TabItemDisplayData` (and underlying `TabItem`) that was selected.
    ///   - tabBarID: The `id` of the `TabBarDisplayData` (and underlying `TabBar`) where the selection occurred.
    func selectTab(itemID: String, inTabBarID: TabBarIdentifier)
}
```

## Responsibilities of a Conforming ViewModel

A class implementing `AdaptiveTabBarViewModelProtocol` is the **brain** of the `AdaptiveTabBarView`. Its core responsibilities include:

1.  **State Management**:
    *   Maintaining the internal source of truth for all tab bar data. This typically involves holding an array of `TabBar` structs (which in turn contain `TabItem` structs) and the `TabBarIdentifier` of the currently active tab bar.
    *   Updating this internal state in response to actions, primarily the `selectTab(itemID:inTabBarID:)` method call.

2.  **Logic Execution**:
    *   Determining which tab item is selected within each tab bar.
    *   Deciding if a tab selection should trigger a switch to a different tab bar (based on the `switchToTabBar` property of the selected `TabItem`).
    *   If a switch occurs, ensuring the correct item is selected in the newly active tab bar (e.g., if the item that triggered the switch has a corresponding item ID in the new tab bar).

3.  **Display State Construction**:
    *   Transforming its internal data models (`[TabBar]`, active `TabBarIdentifier`) into the comprehensive `AdaptiveTabBarDisplayState` object.
    *   This involves creating `TabBarDisplayData` for each `TabBar` and `TabItemDisplayData` for each `TabItem`.
    *   Crucially, the ViewModel calculates the `isActive` boolean for each `TabItemDisplayData` based on whether its identifier matches the `selectedTabItemIdentifier` of its parent `TabBar` *and* whether its parent `TabBar` is the currently `activeTabBarID`.

4.  **Publishing Updates**:
    *   Emitting the newly constructed `AdaptiveTabBarDisplayState` through the `displayStatePublisher` whenever its internal state changes due to an action. This reactive emission drives all UI updates in the `AdaptiveTabBarView`.

## `displayStatePublisher`

*   **Type**: `AnyPublisher<AdaptiveTabBarDisplayState, Never>`
*   **Behavior**: This publisher should emit a new `AdaptiveTabBarDisplayState` value whenever there's a change relevant to the tab bar's presentation. This includes:
    *   Initial state emission upon ViewModel initialization.
    *   Changes in the selected item within the active tab bar.
    *   Changes to the active tab bar itself.
    *   Changes in the selected item of an inactive tab bar (if this state is maintained and relevant).
    *   Structural changes to the tab bars (e.g., items added/removed, tab bars added/removed), if the ViewModel supports such dynamic updates.
*   It should be a `Never` failure type, indicating that state updates are not expected to fail.
*   The `AdaptiveTabBarView` will subscribe to this publisher and call its `render(state:)` method with each emitted value.

## `selectTab(itemID: String, inTabBarID: TabBarIdentifier)`

*   **Purpose**: This is the primary action method called by the View when a user interacts with a tab item.
*   **Parameters**:
    *   `itemID: String`: The unique identifier of the `TabItem` that was tapped.
    *   `inTabBarID: TabBarIdentifier`: The identifier of the `TabBar` in which the tapped item resides.
*   **Expected Implementation**: The ViewModel should:
    1.  Use `inTabBarID` and `itemID` to identify the specific `TabItem` from its internal data store.
    2.  Update its internal state to mark this `itemID` as the `selectedTabItemIdentifier` for the `inTabBarID`.
    3.  Check if the identified `TabItem` has a `switchToTabBar` property set.
        *   If `yes`, and it's different from the current `internalActiveTabBarID`, update `internalActiveTabBarID` to this new value. Then, optionally, if `itemID` also exists in this newly active tab bar, set it as selected there too.
        *   If `yes`, and it's the same as `internalActiveTabBarID`, ensure `internalActiveTabBarID` is indeed set to this value (handles cases where an item in an inactive tab bar might point to itself to become active).
        *   If `no` `switchToTabBar` property, but the `inTabBarID` was not the `internalActiveTabBarID`, update `internalActiveTabBarID` to `inTabBarID` (i.e., selecting a tab in an inactive bar makes that bar active).
    4.  After all internal state modifications, construct and emit a new `AdaptiveTabBarDisplayState` via `displayStatePublisher`.

By adhering to this protocol, different ViewModel implementations can be provided for the `AdaptiveTabBarView`, allowing for varied data sources and business logic while maintaining a consistent interface with the View.