# Testing and SwiftUI Previews

This document outlines how to test the `AdaptiveTabBarView` component and its associated ViewModel, and how to leverage SwiftUI Previews for rapid UI iteration, primarily using the `MockAdaptiveTabBarViewModel`.

## Testing Strategy

Thanks to the ViewModel-driven architecture, testing can be effectively focused on the ViewModel's logic.

### ViewModel Testing

Your primary goal should be to test your ViewModel class (the one conforming to `AdaptiveTabBarViewModelProtocol`).

1.  **Initialization**: Test that the ViewModel initializes correctly and that its `displayStatePublisher` emits the expected initial `AdaptiveTabBarDisplayState`.
2.  **Action Handling (`selectTab`)**: For various scenarios of calling `selectTab(itemID:inTabBarID:)`:
    *   Verify that the ViewModel updates its internal state correctly (though this is an internal detail, the effect should be visible in the emitted display state).
    *   Assert that the `displayStatePublisher` emits a new `AdaptiveTabBarDisplayState` that accurately reflects the changes.
    *   **Scenarios to test for `selectTab`**: 
        *   Selecting a regular item in the currently active tab bar.
        *   Selecting an item in an inactive tab bar (should make that tab bar active).
        *   Selecting an item that has a `switchToTabBar` property set to a *different* tab bar.
            *   Verify the active tab bar changes in the emitted state.
            *   Verify the originally clicked item is selected in its (now potentially inactive) tab bar.
            *   Verify that if a corresponding item (by ID) exists in the *newly active* tab bar, it also becomes selected.
        *   Selecting an item that has `switchToTabBar` set to its *own* tab bar (should just ensure selection and that tab bar is active).
        *   Selecting non-existent itemIDs or tabBarIDs (if your ViewModel has error handling or specific behavior for this, though the mock currently just prints errors).
3.  **Structural Updates (if applicable)**: If your ViewModel supports methods to dynamically change the entire tab bar structure (like `updateTabBarsStructure` in the mock), test that these methods lead to the correct `AdaptiveTabBarDisplayState` being emitted.

**Example (Conceptual Test Case for a ViewModel):**

```swift
import XCTest
import Combine
@testable import GomaUI // Or your app module

class MyCustomTabBarViewModelTests: XCTestCase {
    var viewModel: MyCustomTabBarViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockTabDefinitions: [TabBar]! // Predefined TabBar structures for testing

    override func setUp() {
        super.setUp()
        cancellables = []
        // Define some mockTabDefinitions to initialize your ViewModel
        mockTabDefinitions = /* ... setup your TabBar array ... */
        viewModel = MyCustomTabBarViewModel(tabBars: mockTabDefinitions, activeTabBarIdentifier: .home)
    }

    func testInitialState() {
        let expectation = XCTestExpectation(description: "Initial display state is correct")
        
        viewModel.displayStatePublisher
            .sink { displayState in
                XCTAssertEqual(displayState.activeTabBarID, .home)
                XCTAssertEqual(displayState.tabBars.count, self.mockTabDefinitions.count)
                // ... more assertions on the initial state ...
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 1.0)
    }

    func testSelectTab_ChangesActiveItem() {
        let expectation = XCTestExpectation(description: "Selecting a tab updates active item")
        var emissions = [AdaptiveTabBarDisplayState]()

        viewModel.displayStatePublisher
            .sink { emissions.append($0) }
            .store(in: &cancellables)

        // Assuming first tab bar is .home and has an item "item2"
        viewModel.selectTab(itemID: "item2", inTabBarID: .home)
        
        // Wait for publisher to emit (might need a slight delay or more sophisticated expectation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            XCTAssertGreaterThanOrEqual(emissions.count, 2) // Initial + after selection
            let lastState = emissions.last!
            XCTAssertEqual(lastState.activeTabBarID, .home)
            let homeTabBarDisplay = lastState.tabBars.first(where: { $0.id == .home })
            XCTAssertNotNil(homeTabBarDisplay)
            let selectedItem = homeTabBarDisplay?.items.first(where: { $0.identifier == "item2" })
            XCTAssertTrue(selectedItem?.isActive ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // ... Add more test cases for switching tab bars, etc. ...
}
```

### View Testing

Directly testing the `AdaptiveTabBarView` and `AdaptiveTabBarItemView` can be done via UI tests if necessary, but much of their correctness is ensured if the ViewModel behaves correctly and the rendering logic is sound. Snapshot testing can be very useful here to catch visual regressions.

*   **`AdaptiveTabBarView`**: Verify it renders correctly for different `AdaptiveTabBarDisplayState` inputs (using the `MockAdaptiveTabBarViewModel` to provide these states).
*   **`AdaptiveTabBarItemView`**: Verify it renders correctly for different `TabItemDisplayData` inputs (active, inactive, with/without icon).

## SwiftUI Previews

SwiftUI Previews are invaluable for rapid UI development and visual verification.

### `AdaptiveTabBarView` Previews

The `AdaptiveTabBarView.swift` file includes previews that use `MockAdaptiveTabBarViewModel`:

```swift
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Default Tabs") {
    PreviewUIView { // Helper to wrap UIView in SwiftUI Preview
        AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("Complex and Crazy Mock") { // Example using the more complex mock
    PreviewUIView {
        AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.complexAndCrazyMock)
    }
    .frame(height: 52)
}

#endif
```

*   You can create multiple `#Preview` blocks, each initializing `AdaptiveTabBarView` with different configurations of `MockAdaptiveTabBarViewModel` (e.g., `defaultMock`, `complexAndCrazyMock`, or even custom instances of the mock for specific scenarios).
*   This allows you to see how the tab bar looks and behaves with different numbers of tabs, active states, and tab bar configurations without running the full application.

### `AdaptiveTabBarItemView` Previews

The `AdaptiveTabBarItemView.swift` also contains previews:

```swift
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Adaptive Tab Bar Item States") {
    let activeItemDisplayData = TabItemDisplayData(/* ... active ... */)
    let inactiveItemDisplayData = TabItemDisplayData(/* ... inactive ... */)

    VStack(spacing: 20) {
        Text("Active Item View:")
        PreviewUIView {
            let itemViewActive = AdaptiveTabBarItemView()
            itemViewActive.configure(with: activeItemDisplayData)
            return itemViewActive
        }
        .frame(width: 60, height: 52)
        // ... inactive item view ...
    }
    .padding()
}
#endif
```

*   This preview directly creates `AdaptiveTabBarItemView` instances and configures them with sample `TabItemDisplayData` to show different states (e.g., active vs. inactive).

By utilizing these testing and previewing strategies, you can build and maintain the `AdaptiveTabBarView` component with greater confidence. 