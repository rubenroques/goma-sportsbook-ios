# Testing and SwiftUI Previews

This document outlines how to test the `QuickLinksTabBar` component and its associated ViewModel, and how to leverage SwiftUI Previews for rapid UI iteration.

## Testing Strategy

The ViewModel-driven architecture of the component makes it easy to test in isolation.

### ViewModel Testing

You should focus on testing your custom ViewModel class (the one conforming to `QuickLinksTabBarViewModelProtocol`).

1. **Initialization**: Test that the ViewModel initializes correctly and its `quickLinksPublisher` emits the expected initial links.

2. **Link Tap Handling**: Test that the `didTapQuickLink(type:)` method behaves as expected (e.g., logging analytics, updating internal state).

3. **Dynamic Updates**: If your ViewModel supports updating the quick links (like `MockQuickLinksTabBarViewModel.updateQuickLinks(_:)`), test that these updates are correctly emitted through the publisher.

**Example (Conceptual Test Case for a ViewModel):**

```swift
import XCTest
import Combine
@testable import GomaUI // Or your app module

class MyQuickLinksViewModelTests: XCTestCase {
    var viewModel: MyQuickLinksViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        viewModel = MyQuickLinksViewModel()
    }

    func testInitialLinks() {
        let expectation = XCTestExpectation(description: "Initial quick links are correct")
        
        viewModel.quickLinksPublisher
            .sink { quickLinks in
                XCTAssertEqual(quickLinks.count, 4) // Assuming 4 default links
                XCTAssertEqual(quickLinks[0].type, .aviator)
                XCTAssertEqual(quickLinks[1].type, .slots)
                // More assertions as needed
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 1.0)
    }

    func testDidTapQuickLink() {
        // This could test analytics tracking or other side effects
        // For example, if tapping updates a property:
        viewModel.didTapQuickLink(type: .aviator)
        XCTAssertEqual(viewModel.lastTappedLink, .aviator)
    }
    
    func testUpdateQuickLinks() {
        let expectation = XCTestExpectation(description: "Quick links update correctly")
        var emissions = [[QuickLinkItem]]()
        
        viewModel.quickLinksPublisher
            .sink { emissions.append($0) }
            .store(in: &cancellables)
        
        // Create new sports links
        let sportsLinks = [
            QuickLinkItem(type: .football, title: "Football", icon: nil),
            QuickLinkItem(type: .basketball, title: "Basketball", icon: nil)
        ]
        
        // Update links
        viewModel.updateQuickLinks(sportsLinks)
        
        // Wait a moment for the publisher to emit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(emissions.count, 2) // Initial + after update
            XCTAssertEqual(emissions[1].count, 2) // 2 sports links
            XCTAssertEqual(emissions[1][0].type, .football)
            XCTAssertEqual(emissions[1][1].type, .basketball)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### View Testing

If needed, you can test the `QuickLinksTabBarView` directly, focusing on:

1. **Rendering**: Verify it correctly renders the quick link items provided by the view model.
2. **Interaction**: Verify it forwards tap events to the view model and executes callbacks.

This can be done through UI tests or through unit tests that interact directly with the view and verify its behavior.

## The Mock ViewModel

The `MockQuickLinksTabBarViewModel` is provided for testing and previewing the `QuickLinksTabBarView`. It offers several conveniences:

### Key Features

1. **Default Configurations**: The mock provides several predefined configurations:
   * `gamingMockViewModel`: Gaming-related quick links (aviator, slots, etc.)
   * `sportsMockViewModel`: Sports-related quick links (football, basketball, etc.)
   * `accountMockViewModel`: Account-related quick links (deposit, withdraw, etc.)

2. **Dynamic Updates**: The mock includes an `updateQuickLinks(_:)` method to change the quick links at runtime.

3. **Tap Tracking**: The mock logs taps to the console via `didTapQuickLink(type:)`.

### Using the Mock for Testing

```swift
// Create a mock with default gaming links
let mockViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel

// Or create a mock with custom links
let customLinks = [
    QuickLinkItem(type: .aviator, title: "Custom Aviator", icon: customIcon),
    QuickLinkItem(type: .slots, title: "Custom Slots", icon: customIcon)
]
let customMockViewModel = MockQuickLinksTabBarViewModel(quickLinks: customLinks)

// Test dynamic updates
mockViewModel.updateQuickLinks(MockQuickLinksTabBarViewModel.sportsQuickLinks)
```

## SwiftUI Previews

SwiftUI Previews are valuable for rapid UI iteration and visual verification.

### `QuickLinkTabBarItemView` Previews

The component includes previews for individual items:

```swift
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Quick Link Item") {
    let item = QuickLinkItem(
        type: .aviator,
        title: "Aviator",
        icon: UIImage(systemName: "airplane")
    )

    return PreviewUIView {
        let itemView = QuickLinkTabBarItemView()
        itemView.configure(with: item)
        return itemView
    }
    .frame(width: 70, height: 40)
    .border(Color.gray)
    .padding()
}
#endif
```

### `QuickLinksTabBarView` Previews

The component includes previews for the complete bar with different configurations:

```swift
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Gaming Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}

@available(iOS 17.0, *)
#Preview("Sports Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}

@available(iOS 17.0, *)
#Preview("Account Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.accountMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}
#endif
```

### Creating Custom Previews

You can create your own previews to visualize the component with custom configurations:

```swift
@available(iOS 17.0, *)
#Preview("Custom Quick Links") {
    let customLinks = [
        QuickLinkItem(type: .aviator, title: "My Aviator", icon: UIImage(systemName: "airplane.circle")),
        QuickLinkItem(type: .slots, title: "Premium Slots", icon: UIImage(systemName: "dollarsign.circle")),
        QuickLinkItem(type: .promos, title: "Hot Deals", icon: UIImage(systemName: "flame"))
    ]
    let customViewModel = MockQuickLinksTabBarViewModel(quickLinks: customLinks)
    
    return PreviewUIView {
        let quickLinksView = QuickLinksTabBarView(viewModel: customViewModel)
        quickLinksView.onQuickLinkSelected = { linkType in
            print("Preview selected: \(linkType)")
        }
        return quickLinksView
    }
    .frame(height: 40)
    .previewDisplayName("Custom Quick Links")
}
```

By utilizing these testing and previewing strategies, you can build and maintain the `QuickLinksTabBar` component with greater confidence and efficiency. 