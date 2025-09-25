# View Components

This document describes the Swift UIView subclasses that form the visual part of the `AdaptiveTabBarView` component: `AdaptiveTabBarView` itself and `AdaptiveTabBarItemView`.

## 1. `AdaptiveTabBarView.swift`

*   **Inherits from**: `UIView`
*   **Purpose**: This is the main container view for the entire tab bar system. It orchestrates the display of multiple tab bars (each represented by a `UIStackView`) and their constituent `AdaptiveTabBarItemView`s.

### Key Responsibilities and Behavior:

*   **Initialization**: 
    *   Takes an object conforming to `AdaptiveTabBarViewModelProtocol` in its initializer.
    *   Stores this ViewModel to interact with.
*   **Subscription to ViewModel**: 
    *   In its `setupBindings()` method, it subscribes to the `viewModel.displayStatePublisher`.
*   **Rendering Logic (`render(state: AdaptiveTabBarDisplayState)`)**: 
    *   This method is called whenever a new `AdaptiveTabBarDisplayState` is emitted by the ViewModel.
    *   **Manages Tab Bar StackViews**: It maintains a dictionary `stackViewMap: [TabBarIdentifier: UIStackView]`. 
        *   It compares the `TabBarIdentifier`s from the incoming `state.tabBars` with the keys in `stackViewMap`.
        *   Unneeded `UIStackView`s (for tab bars no longer present in the state) are removed from the view hierarchy and the map.
        *   New `UIStackView`s are created for new tab bars, added to the hierarchy (via `addStackViewBar`), and stored in the map.
        *   Each `UIStackView` is configured to display items horizontally with equal distribution.
    *   **Manages Tab Item Views**: For each `TabBarDisplayData` in the received state:
        *   It retrieves or identifies the corresponding `UIStackView`.
        *   It **clears all existing `arrangedSubviews`** from this stack view. This means `AdaptiveTabBarItemView` instances are currently recreated on each state update that affects their parent tab bar.
        *   For each `TabItemDisplayData` in the `tabBarDisplayData.items`:
            *   A new `AdaptiveTabBarItemView` instance is created.
            *   The `itemView.configure(with: itemDisplayData)` method is called to set its appearance (icon, title, active state).
            *   An `onTap` closure is assigned to the `itemView`. This closure, when executed, calls `viewModel.selectTab(itemID: itemDisplayData.identifier, inTabBarID: tabBarDisplayData.id)`.
            *   It also triggers the `AdaptiveTabBarView`'s own `onTabSelected` callback, providing a reconstructed `TabItem` for the host application.
            *   The configured `itemView` is added as an arranged subview to the `UIStackView`.
    *   **Activates Correct Tab Bar**: After processing all tab bars and items, it iterates through `stackViewMap` and sets the `isHidden` property of each `UIStackView` based on whether its `TabBarIdentifier` matches the `state.activeTabBarID`.
*   **Layout**: 
    *   Has a default height of 52 points, established by constraints in `initConstraints()`.
    *   `UIStackView`s are constrained to fill the `AdaptiveTabBarView` bounds.
*   **`onTabSelected` Callback**: 
    *   `var onTabSelected: ((TabItem) -> Void)`: A public closure that client code can set to be notified when a tab item is successfully selected and processed by the ViewModel.

## 2. `AdaptiveTabBarItemView.swift`

*   **Inherits from**: `UIView`
*   **Purpose**: Represents a single, tappable tab item within a tab bar. It displays an icon and a title.

### Key Responsibilities and Behavior:

*   **UI Elements**: 
    *   `iconImageView: UIImageView`: Displays the item's icon.
    *   `titleLabel: UILabel`: Displays the item's title.
    *   `containerStackView: UIStackView`: A vertical stack view that arranges the icon above the title.
*   **Initialization**: 
    *   Sets up its subviews and gesture recognizers.
*   **Configuration (`configure(with: TabItemDisplayData)`)**: 
    *   This is the sole method for setting the view's content and appearance.
    *   It takes a `TabItemDisplayData` struct.
    *   Sets `self.itemIdentifier` (for potential debugging or identification).
    *   Sets `iconImageView.image` and `titleLabel.text` from the display data.
    *   Calls `updateAppearance(isActive: displayData.isActive)` to style the view based on its active state.
*   **Appearance (`updateAppearance(isActive: Bool)`)**: 
    *   If `isActive` is true:
        *   Sets title and icon colors to `StyleProvider.Color.highlightPrimary`.
        *   Sets view alpha to `1.0`.
    *   If `isActive` is false:
        *   Sets title and icon colors to `StyleProvider.Color.highlightSecondary`.
        *   Sets view alpha to `0.3` (for a dimmed appearance).
*   **Tap Handling**: 
    *   A `UITapGestureRecognizer` is attached to the view.
    *   When tapped, it executes its `onTap: (() -> Void)?` closure. This closure is provided by the parent `AdaptiveTabBarView` and is responsible for notifying the ViewModel.
*   **Layout**: 
    *   Internal constraints position the icon and title within the `containerStackView`, and the `containerStackView` within the bounds of the `AdaptiveTabBarItemView` (with some padding).
    *   Icons and titles have predefined size constraints.

These two view components work together, orchestrated by the `AdaptiveTabBarDisplayState` from the ViewModel, to present a fully reactive and dynamic tab bar experience. 
