# PresentationProvider

## Overview

`PresentationProvider` is a Swift Package designed to provide dynamic presentation layer configurations to the GOMA Sportsbook iOS application. It abstracts the source of these configurations, allowing the app to define UI elements like tab bars, navigation bars, and home screen layouts based on settings retrieved at runtime or from local fallbacks.

The primary goal is to enable a flexible and adaptable user interface that can be modified without requiring a full app update, catering to different client needs, A/B testing scenarios, or evolving feature sets.

## Key Design Principles

-   **Protocol-Oriented**: Core functionality is defined by protocols, facilitating testability and enabling different configuration sources (e.g., local JSON, remote API) to be used interchangeably.
-   **Modularity**: Encapsulates all logic related to fetching and parsing presentation configurations, keeping the main application's codebase cleaner.
-   **Flexibility**: Designed to support various types of presentation configurations beyond just tab bars in the future.

## Core Components

### 1. Protocols

-   **`PresentationConfigurationFetching`**:
    -   Defines the contract for any object that can fetch the presentation configuration.
    -   Key method: `fetchPresentationConfiguration(completion: @escaping (Result<PresentationConfiguration, Error>) -> Void)`

-   **`PresentationConfigurationServicing`**:
    -   A type alias for `PresentationConfigurationFetching`, representing the service interface provided by this package.

### 2. Data Models

-   **`PresentationConfiguration` (Struct, Codable)**:
    -   The main container for all presentation-related settings.
    -   Currently includes:
        -   `tabBarItems: [TabBarItemConfig]`

-   **`TabBarItemConfig` (Struct, Codable, Identifiable)**:
    -   Represents the configuration for a single item in the tab bar.
    -   Properties:
        -   `id: String` (Unique identifier for the tab)
        -   `title: String` (Display title for the tab)
        -   `iconName: String` (System icon name or custom asset name)
        -   `viewControllerIdentifier: String` (A string used by the main app to map to a specific `UIViewController` type)
        -   `order: Int` (Determines the display order in the tab bar)

### 3. Implementations

-   **`LocalJSONPresentationFetcher` (Class)**:
    -   An initial implementation of `PresentationConfigurationFetching`.
    -   Reads presentation configurations from a local JSON file bundled with the main application (or within this package, if configured).
    -   **Initializer**: `init(fileName: String = "presentation_config.json", bundle: Bundle = .main)`
    -   **Errors**: Defines a `FetchError` enum for issues like file not found, data corruption, or decoding errors.

## Usage

### 1. Adding the Package Dependency

Add `PresentationProvider` to your main application project:

-   In Xcode: `File > Add Packages...`
-   Select your project, then the app target.
-   Under "Frameworks, Libraries, and Embedded Content", click "+".
-   Choose "Add Other..." > "Add Package (Local)..." and select the `PresentationProvider` directory.

### 2. Setting up the Local Configuration File

For the `LocalJSONPresentationFetcher` to work, you need a JSON file (e.g., `presentation_config.json`) in your main application's bundle.

**Example `presentation_config.json`:**

```json
{
  "tabItems": [
    {
      "id": "sports",
      "route": "sports",
      "label": "Sports",
      "icon": "sports",
      "context": "sports",
      "switchToNavbar": "sports"
    },
    {
      "id": "live",
      "route": "sports/live",
      "label": "Live",
      "icon": "live",
      "context": "sports"
    },
    {
      "id": "mybets",
      "route": "sports/mybets",
      "label": "My Bets",
      "icon": "my_bets",
      "context": "sports"
    },
    {
      "id": "searchSports",
      "route": "sports/search",
      "label": "Search",
      "icon": "Search",
      "context": "sports"
    },
    {
      "id": "casino",
      "route": "casino",
      "label": "Casino",
      "icon": "casino",
      "context": "casino",
      "switchToNavbar": "casino"
    },
    {
      "id": "virtuals",
      "route": "casino/virtuals",
      "label": "Virtuals",
      "icon": "virtuals",
      "context": "casino"
    },
    {
      "id": "aviator",
      "route": "casino/aviator",
      "label": "Aviator",
      "icon": "aviator",
      "context": "casino"
    },
    {
      "id": "searchCasino",
      "route": "casino/search",
      "label": "Search",
      "icon": "search",
      "context": "casino"
    }
  ],
  "navbars": [
    {
      "id": "sports",
      "route": "sports",
      "tabs": [
        "sports",
        "live",
        "mybets",
        "searchSports",
        "casino"
      ]
    },
    {
      "id": "casino",
      "route": "casino",
      "tabs": [
        "sports",
        "virtuals",
        "aviator",
        "searchCasino",
        "casino"
      ]
    }
  ]
}
```

Ensure this file is included in the "Copy Bundle Resources" build phase of your app target.

### 3. Integrating with the Application (e.g., in `Environment.swift`)

```swift
import PresentationProvider

// In your application's Environment setup (e.g., Core/App/Environment.swift)
class Environment {
    // ... other properties

    public let presentationConfigurationService: PresentationConfigurationServicing

    init() {
        // Initialize with the local JSON fetcher
        self.presentationConfigurationService = LocalJSONPresentationFetcher(fileName: "presentation_config.json", bundle: .main)

        // ... other initializations
    }
}

// Global accessor (if you have one)
// let Env = Environment()
```

### 4. Fetching and Using Configuration

In the relevant part of your application (e.g., `RootViewController` or a dedicated presentation manager):

```swift
// Assuming 'Env' is your global Environment instance
Env.presentationConfigurationService.fetchPresentationConfiguration { result in
    DispatchQueue.main.async { // Ensure UI updates are on the main thread
        switch result {
        case .success(let config):
            // Use config.tabBarItems to build your tab bar dynamically
            // Use other configurations as they are added
            print("Successfully fetched presentation config: \(config.tabBarItems.count) tab items")
            // Example: self.dynamicTabBar.setup(with: config.tabBarItems)
        case .failure(let error):
            print("Error fetching presentation config: \(error)")
            // Handle error (e.g., load default/fallback UI)
        }
    }
}
```

## Future Development

-   **API-based Fetcher**: An `APIPresentationFetcher` class will be implemented to fetch configurations from a remote API. This will allow for true dynamic updates without app releases.
-   **Expanded Configuration**: The `PresentationConfiguration` model will be extended to include settings for:
    -   Navigation bar appearance and elements.
    -   Home screen widget layouts.
    -   Client-specific theming overrides.
-   **Caching**: Implement caching strategies for remotely fetched configurations to improve performance and provide offline fallbacks.
-   **Error Handling & Fallbacks**: Enhance error handling and provide more robust fallback mechanisms if configuration fetching fails.

## Contribution

To contribute or extend this package:

1.  Define new configuration properties within `PresentationConfiguration` or nested models.
2.  If adding a new source, create a new class conforming to `PresentationConfigurationFetching`.
3.  Update tests and documentation accordingly.
