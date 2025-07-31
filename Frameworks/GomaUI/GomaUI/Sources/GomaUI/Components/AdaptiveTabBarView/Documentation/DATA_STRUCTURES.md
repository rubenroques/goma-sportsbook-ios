# Data Structures

This document details the primary data structures used by the `AdaptiveTabBarView` component, particularly those involved in defining its state and appearance. Understanding these structures is key to working with the ViewModel and interpreting the data it provides.

## Core Display State Structures

These structures are used by the ViewModel to communicate the complete state of the tab bar to the `AdaptiveTabBarView` via the `displayStatePublisher`.

### 1. `AdaptiveTabBarDisplayState`

*   **Purpose**: Represents the entire state required by `AdaptiveTabBarView` to render itself.
*   **Swift Definition**:
    ```swift
    public struct AdaptiveTabBarDisplayState: Equatable {
        public let tabBars: [TabBarDisplayData]
        public let activeTabBarID: TabBarIdentifier
    }
    ```
*   **Fields**:
    *   `tabBars: [TabBarDisplayData]`: An array describing each tab bar (a collection of tabs) that *could* be displayed.
    *   `activeTabBarID: TabBarIdentifier`: An enum case indicating which of the `tabBars` is currently the active (visible) one.

### 2. `TabBarDisplayData`

*   **Purpose**: Describes a single tab bar (a set of tabs) within the `AdaptiveTabBarDisplayState`.
*   **Swift Definition**:
    ```swift
    public struct TabBarDisplayData: Equatable, Hashable {
        public let id: TabBarIdentifier
        public let items: [TabItemDisplayData]
    }
    ```
*   **Fields**:
    *   `id: TabBarIdentifier`: The unique identifier for this tab bar (e.g., `.home`, `.casino`).
    *   `items: [TabItemDisplayData]`: An array describing each individual tab item within this tab bar.

### 3. `TabItemDisplayData`

*   **Purpose**: Describes a single, individual tab item to be displayed within a `TabBarDisplayData`.
*   **Swift Definition**:
    ```swift
    public struct TabItemDisplayData: Equatable, Hashable {
        public let identifier: String
        public let title: String
        public let icon: UIImage?
        public let isActive: Bool
        public let switchToTabBar: TabBarIdentifier? // For tap handling
    }
    ```
*   **Fields**:
    *   `identifier: String`: A unique string identifier for this specific tab item (e.g., "home_overview", "casino_slots").
    *   `title: String`: The text label to be displayed for the tab item.
    *   `icon: UIImage?`: An optional image (icon) for the tab item.
    *   `isActive: Bool`: A boolean indicating whether this tab item is currently the selected/active one within its tab bar *and* if its tab bar is the active one overall.
    *   `switchToTabBar: TabBarIdentifier?`: If not `nil`, tapping this item will instruct the ViewModel to attempt to switch to the tab bar specified by this identifier.

## ViewModel Internal Data Structures

While the View primarily interacts with the "Display State" structures above, the ViewModel internally manages its source of truth typically using these original, more foundational structures:

### 1. `TabBarIdentifier`

*   **Purpose**: A Swift `enum` used to uniquely identify different tab bars (e.g., for different sections of an application).
*   **Swift Definition**:
    ```swift
    public enum TabBarIdentifier: String, Hashable {
        case home
        case casino
        case live
        case promotions
        case profile
        // ... and any other identifiers you define
    }
    ```

### 2. `TabItem`

*   **Purpose**: Represents the underlying data model for a single tab within a tab bar. This is distinct from `TabItemDisplayData` as it doesn't contain UI-specific state like `isActive` (which is derived by the ViewModel when creating `TabItemDisplayData`).
*   **Swift Definition**:
    ```swift
    public struct TabItem: Equatable, Hashable {
        public let identifier: String
        public let title: String
        public let icon: UIImage?
        public let switchToTabBar: TabBarIdentifier?
    }
    ```
*   **Fields**:
    *   `identifier: String`: Unique ID for this tab item.
    *   `title: String`: The default title for this item.
    *   `icon: UIImage?`: The icon for this item.
    *   `switchToTabBar: TabBarIdentifier?`: If set, indicates that selecting this item should trigger a switch to the specified tab bar.

### 3. `TabBar`

*   **Purpose**: Represents the underlying data model for a complete tab bar, containing a collection of `TabItem`s and its currently selected item.
*   **Swift Definition**:
    ```swift
    public struct TabBar: Hashable {
        public var id: TabBarIdentifier
        public var tabs: [TabItem]
        public var selectedTabItemIdentifier: String
    }
    ```
*   **Fields**:
    *   `id: TabBarIdentifier`: The unique identifier for this specific tab bar.
    *   `tabs: [TabItem]`: An array of `TabItem` structs that belong to this tab bar.
    *   `selectedTabItemIdentifier: String`: The `identifier` of the `TabItem` that is currently selected within this tab bar.

By maintaining a distinction between internal data models (`TabBar`, `TabItem`) and display-specific data models (`AdaptiveTabBarDisplayState`, etc.), the ViewModel can encapsulate the logic of transforming its core state into a representation suitable for direct rendering by the View. 