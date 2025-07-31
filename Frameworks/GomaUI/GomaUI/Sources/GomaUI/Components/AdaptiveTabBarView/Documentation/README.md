# AdaptiveTabBarView Component Documentation

Welcome to the documentation for the `AdaptiveTabBarView` component, a highly flexible and ViewModel-driven tab bar solution for iOS applications developed within the GomaUI framework.

## Overview

The `AdaptiveTabBarView` provides a customizable tab bar UI that dynamically adapts its content and appearance based on a state provided by a ViewModel. It's designed to be robust, testable, and easy to integrate.

**Key Features:**

*   **ViewModel-Driven**: All UI state (tab structures, active tabs, appearances) is managed by a ViewModel, making the view itself a passive renderer.
*   **Dynamic Content**: Supports multiple distinct tab bars (e.g., for different sections of an app like "Home," "Casino," "Live Events") and allows switching between them.
*   **Customizable Items**: Each tab item can display an icon and a title, with distinct appearances for active and inactive states.
*   **Inter-Tab Navigation**: Tab items can be configured to trigger a switch to a different tab bar.
*   **Clear Separation of Concerns**: Follows a reactive pattern where the View observes a display state from the ViewModel.

## Documentation Index

To help you understand and use the `AdaptiveTabBarView` effectively, the documentation is organized into the following sections:

*   **[Architecture](./ARCHITECTURE.md)**: Understand the design principles and how the component is structured.
*   **[Usage Guide](./USAGE_GUIDE.md)**: Learn how to integrate and use the component in your application.
*   **[Data Structures](./DATA_STRUCTURES.md)**: Explore the data models that define the state and appearance of the tab bar.
*   **[ViewModel Protocol](./VIEWMODEL_PROTOCOL.md)**: Details on the `AdaptiveTabBarViewModelProtocol` that your ViewModel must conform to.
*   **[View Components](./VIEW_COMPONENTS.md)**: Information about the `AdaptiveTabBarView` and `AdaptiveTabBarItemView` Swift classes.
*   **[Testing and Previews](./TESTING_AND_PREVIEWS.md)**: How to use the mock ViewModel for testing and SwiftUI Previews.

We encourage you to read through these documents to get a comprehensive understanding of the `AdaptiveTabBarView` component.