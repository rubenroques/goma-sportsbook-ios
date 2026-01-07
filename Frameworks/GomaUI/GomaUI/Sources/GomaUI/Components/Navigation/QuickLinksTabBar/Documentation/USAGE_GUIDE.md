# Usage Guide

This guide explains how to integrate and use the `QuickLinksTabBar` component in your iOS application.

## 1. Prepare your ViewModel

First, you need a class that conforms to the `QuickLinksTabBarViewModelProtocol`. This ViewModel will be responsible for providing the quick link items.

```swift
import Combine
import UIKit


class MyQuickLinksViewModel: QuickLinksTabBarViewModelProtocol {
    
    private let quickLinksSubject: CurrentValueSubject<[QuickLinkItem], Never>
    
    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> {
        return quickLinksSubject.eraseToAnyPublisher()
    }
    
    init() {
        // Initialize with your default quick links
        let defaultLinks = [
            QuickLinkItem(type: .aviator, title: "Aviator", icon: UIImage(systemName: "airplane")),
            QuickLinkItem(type: .slots, title: "Slots", icon: UIImage(systemName: "square.grid.3x3")),
            QuickLinkItem(type: .crash, title: "Crash", icon: UIImage(systemName: "chart.line.uptrend.xyaxis")),
            QuickLinkItem(type: .promos, title: "Promos", icon: UIImage(systemName: "gift"))
        ]
        
        self.quickLinksSubject = CurrentValueSubject(defaultLinks)
    }
    
    func didTapQuickLink(type: QuickLinkType) {
        // Handle the tap, such as logging analytics
        print("Quick link tapped: \(type)")
        
        // You can also perform other actions here, like updating state
        // or triggering other events in your application
    }
    
    // Optional: Method to update quick links if needed
    func updateQuickLinks(_ newLinks: [QuickLinkItem]) {
        quickLinksSubject.send(newLinks)
    }
}
```

## 2. Instantiate and Add `QuickLinksTabBarView` to Your UI

In your UIViewController, create an instance of your ViewModel and then the `QuickLinksTabBarView`.

```swift
// In a UIViewController

class MyViewController: UIViewController {
    let quickLinksViewModel = MyQuickLinksViewModel() // Or your actual ViewModel
    var quickLinksTabBar: QuickLinksTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the quick links bar
        quickLinksTabBar = QuickLinksTabBarView(viewModel: quickLinksViewModel)
        quickLinksTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(quickLinksTabBar)
        
        // Setup constraints for the quickLinksTabBar
        NSLayoutConstraint.activate([
            quickLinksTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // The height (40pts) is set internally by the component
        ])
        
        // Handle quick link selection
        quickLinksTabBar.onQuickLinkSelected = { [weak self] linkType in
            self?.handleQuickLinkSelection(linkType)
        }
    }
    
    private func handleQuickLinkSelection(_ linkType: QuickLinkType) {
        // Handle the selection based on the link type
        switch linkType {
        case .aviator:
            // Navigate to Aviator screen
            navigateToAviator()
        case .slots:
            // Show slots section
            showSlots()
        case .crash:
            // Open crash game
            openCrashGame()
        case .promos:
            // Display promotions
            showPromotions()
        default:
            // Handle other link types
            break
        }
    }
    
    // Navigation methods would be implemented here
    private func navigateToAviator() { /* ... */ }
    private func showSlots() { /* ... */ }
    private func openCrashGame() { /* ... */ }
    private func showPromotions() { /* ... */ }
}
```

## 3. Dynamic Updates

If you need to update the quick links shown in the bar (for example, based on user preferences or app state), you can use the `updateQuickLinks` method in your ViewModel:

```swift
// Create new set of links
let sportsLinks = [
    QuickLinkItem(type: .football, title: "Football", icon: UIImage(systemName: "soccerball")),
    QuickLinkItem(type: .basketball, title: "Basketball", icon: UIImage(systemName: "basketball")),
    QuickLinkItem(type: .tennis, title: "Tennis", icon: UIImage(systemName: "tennisball")),
    QuickLinkItem(type: .golf, title: "Golf", icon: UIImage(systemName: "figure.golf"))
]

// Update the quick links in the ViewModel
quickLinksViewModel.updateQuickLinks(sportsLinks)
```

The `QuickLinksTabBarView` will automatically update to reflect the new links.

## 4. Adding Custom Link Types

If you need additional link types beyond what's provided in the `QuickLinkType` enum, you can extend it in your application:

```swift
extension QuickLinkType {
    // Gaming specific links
    case poker
    case blackjack
    
    // Account specific links
    case vip
    case rewards
}
```

Then you can use these custom types in your quick link items.

## 5. Testing with the Mock ViewModel

For testing or quick prototyping, you can use the provided `MockQuickLinksTabBarViewModel`:

```swift
// Use one of the predefined mock configurations
let mockViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
// or
let mockViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
// or
let mockViewModel = MockQuickLinksTabBarViewModel.accountMockViewModel

let quickLinksTabBar = QuickLinksTabBarView(viewModel: mockViewModel)
```

## 6. SwiftUI Integration

If you're using SwiftUI, you can wrap the `QuickLinksTabBarView` using `UIViewRepresentable`:

```swift
struct QuickLinksTabBarViewRepresentable: UIViewRepresentable {
    let viewModel: QuickLinksTabBarViewModelProtocol
    let onLinkSelected: (QuickLinkType) -> Void
    
    func makeUIView(context: Context) -> QuickLinksTabBarView {
        let view = QuickLinksTabBarView(viewModel: viewModel)
        view.onQuickLinkSelected = onLinkSelected
        return view
    }
    
    func updateUIView(_ uiView: QuickLinksTabBarView, context: Context) {
        // Updates happen through the ViewModel's publisher
    }
}

// Usage in SwiftUI
struct ContentView: View {
    let viewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
    
    var body: some View {
        VStack {
            QuickLinksTabBarViewRepresentable(
                viewModel: viewModel,
                onLinkSelected: { linkType in
                    print("Selected: \(linkType)")
                }
            )
            .frame(height: 40)
            
            // Rest of your SwiftUI view
            Text("Content goes here")
                .padding()
            
            Spacer()
        }
    }
}
```

That's it! With these steps, you can integrate a flexible and responsive quick links bar into your application. 
