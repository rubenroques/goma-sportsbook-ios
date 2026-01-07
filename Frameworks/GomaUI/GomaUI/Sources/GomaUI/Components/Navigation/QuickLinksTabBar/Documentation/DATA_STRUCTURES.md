# Data Structures

This document details the primary data structures used by the `QuickLinksTabBar` component. The component uses a minimal set of data structures, making it straightforward to understand and implement.

## Core Data Structures

### 1. `QuickLinkType`

* **Purpose**: An enum that identifies different types of quick links that can be displayed in the bar.
* **Swift Definition**:
```swift
public enum QuickLinkType: String, Hashable {
    // Gaming related links
    case aviator
    case virtual
    case slots 
    case crash
    case promos
    
    // Sports related links
    case football
    case basketball
    case tennis
    case golf
    
    // Account related links
    case deposit
    case withdraw
    case help
    case settings
}
```
* **Features**:
  * Conforms to `String` and `Hashable` for easy string conversion and use in collections.
  * Organized into logical groups for different contexts (gaming, sports, account).
  * Can be extended in your application to add custom link types if needed.
  * Using an enum provides compile-time type safety compared to string identifiers.

### 2. `QuickLinkItem`

* **Purpose**: Represents a single quick link item to be displayed in the quick links bar.
* **Swift Definition**:
```swift
public struct QuickLinkItem: Equatable, Hashable {
    public let type: QuickLinkType
    public let title: String
    public let icon: UIImage?
    
    public init(type: QuickLinkType, title: String, icon: UIImage? = nil) {
        self.type = type
        self.title = title
        self.icon = icon
    }
}
```
* **Fields**:
  * `type: QuickLinkType`: The enum case identifying this link type.
  * `title: String`: The text label to be displayed for the item.
  * `icon: UIImage?`: An optional image (icon) for the item.
* **Features**:
  * Conforms to `Equatable` and `Hashable` for comparison and use in collections.
  * Immutable (all fields are constants) to avoid unintended state changes.
  * Provides a convenience initializer with a default `nil` value for the icon.

## View Model Protocol

### `QuickLinksTabBarViewModelProtocol`

* **Purpose**: Defines the contract that view models must fulfill to work with the `QuickLinksTabBarView`.
* **Swift Definition**:
```swift
public protocol QuickLinksTabBarViewModelProtocol {
    /// Publisher for the current quick links to be displayed
    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> { get }
    
    /// Optional method to handle when a quick link is tapped.
    /// Implementations may use this to track analytics or perform other actions.
    func didTapQuickLink(type: QuickLinkType)
}
```
* **Requirements**:
  * `quickLinksPublisher`: A Combine publisher that emits arrays of `QuickLinkItem` objects whenever the quick links change.
  * `didTapQuickLink(type:)`: A method called when a quick link is tapped, allowing the view model to track or respond to the tap.

## Usage in the Component

1. **In the ViewModel**:
   * Typically, a ViewModel maintains an internal array of `QuickLinkItem` objects.
   * When this array changes, the ViewModel emits the new array through `quickLinksPublisher`.
   * When a user taps a quick link, the ViewModel receives the tap through `didTapQuickLink(type:)`.

2. **In the View**:
   * `QuickLinksTabBarView` subscribes to `quickLinksPublisher` and renders the `QuickLinkItem` objects as horizontal items.
   * Each `QuickLinkTabBarItemView` displays a single `QuickLinkItem`.
   * When a user taps an item, the view forwards the tap to both the ViewModel (via `didTapQuickLink(type:)`) and to any registered callback (via `onQuickLinkSelected`).

This minimal set of data structures keeps the component simple while providing all the necessary functionality for a flexible quick links bar. 