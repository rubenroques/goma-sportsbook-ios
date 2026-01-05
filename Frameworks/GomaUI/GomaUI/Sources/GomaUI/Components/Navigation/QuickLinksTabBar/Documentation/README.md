# QuickLinksTabBar Component Documentation

Welcome to the documentation for the `QuickLinksTabBar` component, a simple and flexible horizontal bar of actionable links for iOS applications developed within the GomaUI framework.

## Overview

The `QuickLinksTabBar` provides a customizable horizontal bar of tappable items, each consisting of an icon and a title. It's designed for quick access to common features or destinations within your app.

**Key Features:**

* **ViewModel-Driven**: All UI state (link items) is managed by a ViewModel, making the view itself a passive renderer.
* **Simple Structure**: A straightforward horizontal layout of identical items, each with an icon and title.
* **Type-Safe Actions**: Uses an enum-based approach for item types, ensuring type safety when handling tap actions.
* **Flexible Content**: Easily customizable with different sets of quick links for various contexts.
* **Lightweight Design**: Fixed height of 40pts and minimal complexity, perfect for space-efficient navigation.
* **Callback-Based Interaction**: Simple callback mechanism for handling user taps on links.

## Documentation Index

To help you understand and use the `QuickLinksTabBar` effectively, the documentation is organized into the following sections:

* **[Architecture](./ARCHITECTURE.md)**: Understand the design principles and structure of the component.
* **[Usage Guide](./USAGE_GUIDE.md)**: Learn how to integrate and use the component in your application.
* **[Data Structures](./DATA_STRUCTURES.md)**: Explore the data models that define the links and their behavior.
* **[View Components](./VIEW_COMPONENTS.md)**: Information about the `QuickLinksTabBarView` and `QuickLinkTabBarItemView` Swift classes.
* **[Testing and Previews](./TESTING_AND_PREVIEWS.md)**: How to use the mock ViewModel for testing and SwiftUI Previews.

## When to Use

The `QuickLinksTabBar` is ideal for:

* Providing access to frequently used features at the top of a screen
* Creating category shortcuts in a browsing interface
* Building a compact navigation row for related sections
* Implementing feature highlights or promotional links

Unlike the more complex `AdaptiveTabBarView`, the `QuickLinksTabBar` is not designed for primary app navigation or for maintaining selected states. It's a simple action bar where each item triggers a callback when tapped.