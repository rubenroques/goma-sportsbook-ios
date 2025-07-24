# PresentationConfigurationKit Implementation Tasks

This document outlines the tasks required to implement the `PresentationConfigurationKit` Swift Package. These tasks are designed to be followed by a junior iOS programmer.

## Phase 1: Setting up the Package Structure and Core Protocols

### Task 1.1: Understand Package Structure
-   **Subtask 1.1.1**: Open the `PresentationConfigurationKit` package in Xcode (or ensure it's correctly added to your workspace).
-   **Subtask 1.1.2**: Familiarize yourself with the default structure: `Package.swift`, `README.md`, and the `Sources` directory (which should contain `PresentationConfigurationKit/PresentationConfigurationKit.swift` initially) and `Tests` directory.

### Task 1.2: Define Core Protocols
-   **Subtask 1.2.1**: Create a new Swift file named `PresentationService.swift` inside `Sources/PresentationConfigurationKit/`.
-   **Subtask 1.2.2**: Open `PresentationService.swift`.
-   **Subtask 1.2.3**: Add `import Foundation` at the top.
-   **Subtask 1.2.4**: Define the `PresentationConfigurationFetching` protocol:
    ```swift
    public protocol PresentationConfigurationFetching {
        func fetchPresentationConfiguration(completion: @escaping (Result<PresentationConfiguration, Error>) -> Void)
    }
    ```
    *Action: Ensure the protocol and its method are `public`.*
-   **Subtask 1.2.5**: Define the `PresentationConfigurationServicing` type alias below the protocol:
    ```swift
    public typealias PresentationConfigurationServicing = PresentationConfigurationFetching
    ```
    *Action: Ensure the type alias is `public`.*

## Phase 2: Defining Data Models

### Task 2.1: Create Data Model Files
-   **Subtask 2.1.1**: Create a new Swift file named `PresentationModels.swift` inside `Sources/PresentationConfigurationKit/`.

### Task 2.2: Define Tab Item Enums
-   **Subtask 2.2.1**: Create a new Swift file named `TabIdentifiers.swift` inside `Sources/PresentationConfigurationKit/`.
-   **Subtask 2.2.2**: Define the tab identifiers enum:
    ```swift
    public enum TabIdentifier: String, Codable {
        case sports
        case live
        case mybets
        case searchSports
        case casino
        case virtuals
        case aviator
        case searchCasino

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            guard let value = TabIdentifier(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid tab identifier: \(rawValue)"
                )
            }
            self = value
        }
    }
    ```

### Task 2.3: Define Navbar Enums
-   **Subtask 2.3.1**: In the same file, define the navbar identifiers enum:
    ```swift
    public enum NavbarIdentifier: String, Codable {
        case sports
        case casino

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            guard let value = NavbarIdentifier(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid navbar identifier: \(rawValue)"
                )
            }
            self = value
        }
    }
    ```

### Task 2.4: Implement Tab Item Models
-   **Subtask 2.4.1**: Open `PresentationModels.swift`.
-   **Subtask 2.4.2**: Add `import Foundation` at the top.
-   **Subtask 2.4.3**: Define the `TabItemConfig` struct:
    ```swift
    public struct TabItemConfig: Codable, Identifiable {
        public var id: TabIdentifier { tabId }
        public let tabId: TabIdentifier
        public let route: String
        public let label: String
        public let switchToNavbar: NavbarIdentifier?

        private enum CodingKeys: String, CodingKey {
            case tabId = "id"
            case route
            case label
            case switchToNavbar
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            tabId = try container.decode(TabIdentifier.self, forKey: .tabId)
            route = try container.decode(String.self, forKey: .route)
            label = try container.decode(String.self, forKey: .label)
            switchToNavbar = try container.decodeIfPresent(NavbarIdentifier.self, forKey: .switchToNavbar)
        }
    }
    ```

### Task 2.5: Implement Navigation Bar Models
-   **Subtask 2.5.1**: In the same file, define the `NavbarConfig` struct:
    ```swift
    public struct NavbarConfig: Codable {
        public let name: NavbarIdentifier
        public let route: String
        public let tabs: [TabIdentifier]

        private enum CodingKeys: String, CodingKey {
            case name
            case route
            case tabs
        }
    }
    ```

### Task 2.6: Implement Main Configuration Struct
-   **Subtask 2.6.1**: Define the main `PresentationConfiguration` struct:
    ```swift
    public struct PresentationConfiguration: Codable {
        public let tabItems: [TabItemConfig]
        public let navbars: [NavbarConfig]

        private enum CodingKeys: String, CodingKey {
            case tabItems = "tabItems"
            case navbars = "navbars"
        }
    }
    ```

### Task 2.7: Add Convenience Methods
-   **Subtask 2.7.1**: Add helper methods to `PresentationConfiguration`:
    ```swift
    public extension PresentationConfiguration {
        func navbar(named name: NavbarIdentifier) -> NavbarConfig? {
            return navbars.first { $0.name == name }
        }

        func tabItem(withId id: TabIdentifier) -> TabItemConfig? {
            return tabItems.first { $0.tabId == id }
        }

        func tabItems(forNavbar navbarName: NavbarIdentifier) -> [TabItemConfig] {
            guard let navbar = navbar(named: navbarName) else { return [] }
            return navbar.tabs.compactMap { tabId in
                tabItem(withId: tabId)
            }
        }
    }
    ```

## Phase 3: Implementing the Local JSON Fetcher

### Task 3.1: Create Fetcher File
-   **Subtask 3.1.1**: Create a new Swift file named `LocalJSONPresentationFetcher.swift` inside `Sources/PresentationConfigurationKit/`.

### Task 3.2: Define `LocalJSONPresentationFetcher` Class
-   **Subtask 3.2.1**: Open `LocalJSONPresentationFetcher.swift`.
-   **Subtask 3.2.2**: Add `import Foundation` at the top.
-   **Subtask 3.2.3**: Define the `LocalJSONPresentationFetcher` class conforming to `PresentationConfigurationFetching`:
    ```swift
    public class LocalJSONPresentationFetcher: PresentationConfigurationFetching {
        // Properties will be added next
        // Initializer will be added next
        // Method implementation will be added next
    }
    ```
    *Action: Ensure the class is `public`.*

### Task 3.3: Define Fetcher Error Enum
-   **Subtask 3.3.1**: Inside the `LocalJSONPresentationFetcher` class, define a public `FetchError` enum:
    ```swift
    public enum FetchError: Error {
        case fileNotFound
        case dataCorrupted(description: String)
        case decodingError(Error)
        case unknown(Error)
    }
    ```

### Task 3.4: Add Properties and Initializer
-   **Subtask 3.4.1**: Add private properties for `fileName` and `bundle` to `LocalJSONPresentationFetcher`:
    ```swift
    private let fileName: String
    private let bundle: Bundle
    ```
-   **Subtask 3.4.2**: Add the public initializer:
    ```swift
    public init(fileName: String = "presentation_config.json", bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }
    ```

### Task 3.5: Implement `fetchPresentationConfiguration` Method
-   **Subtask 3.5.1**: Implement the method with enum validation:
    ```swift
    public func fetchPresentationConfiguration(completion: @escaping (Result<PresentationConfiguration, Error>) -> Void) {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            completion(.failure(FetchError.fileNotFound))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let configuration = try decoder.decode(PresentationConfiguration.self, from: data)

            // Validation happens automatically through enum decoding
            completion(.success(configuration))
        } catch let error as DecodingError {
            completion(.failure(FetchError.decodingError(error)))
        } catch {
            completion(.failure(FetchError.unknown(error)))
        }
    }
    ```

## Phase 4: Preparing Sample JSON Configuration File

### Task 4.1: Create the Sample JSON File
-   **Subtask 4.1.1**: Create `presentation_config.json` with the new structure:
    ```json
    {
        "tabItems": [
            {
                "id": "sports",
                "route": "sports",
                "label": "Sports",
                "switchToNavbar": "sports"
            },
            {
                "id": "live",
                "route": "sports/live",
                "label": "Live"
            },
            {
                "id": "mybets",
                "route": "sports/mybets",
                "label": "My Bets"
            },
            {
                "id": "searchSports",
                "route": "sports/search",
                "label": "Search"
            },
            {
                "id": "casino",
                "route": "casino",
                "label": "Casino",
                "switchToNavbar": "casino"
            },
            {
                "id": "virtuals",
                "route": "casino/virtuals",
                "label": "Virtuals"
            },
            {
                "id": "aviator",
                "route": "casino/aviator",
                "label": "Aviator"
            },
            {
                "id": "searchCasino",
                "route": "casino/search",
                "label": "Search"
            }
        ],
        "navbars": [
            {
                "name": "sports",
                "route": "sports",
                "tabs": ["sports", "live", "mybets", "searchSports", "casino"]
            },
            {
                "name": "casino",
                "route": "casino",
                "tabs": ["sports", "virtuals", "aviator", "searchCasino", "casino"]
            }
        ]
    }
    ```

## Phase 5: Building and Verifying the Package

### Task 5.1: Build the Package
-   **Subtask 5.1.1**: In Xcode, select the `PresentationConfigurationKit` scheme (if it exists, or build the project that includes it).
-   **Subtask 5.1.2**: Build the package (Cmd+B).
-   **Subtask 5.1.3**: Ensure there are no compilation errors.

### Task 5.2: (Optional but Recommended) Add Basic Unit Tests
-   **Subtask 5.2.1**: Navigate to the `Tests/PresentationConfigurationKitTests` directory.
-   **Subtask 5.2.2**: Create a test case for `LocalJSONPresentationFetcher`.
-   **Subtask 5.2.3**: Write a test to verify successful decoding of a valid sample JSON.
    *Hint: You'll need to include a sample JSON file in your test target or create mock data.*
-   **Subtask 5.2.4**: Write a test to verify correct error handling for a missing file.
-   **Subtask 5.2.5**: Write a test to verify correct error handling for a malformed JSON file.
-   **Subtask 5.2.6**: Write a test to verify enum decoding for both `TabIdentifier` and `NavbarIdentifier`.
-   **Subtask 5.2.7**: Write a test to verify convenience methods work correctly with enums:
    - Test `navbar(named:)` with `NavbarIdentifier`
    - Test `tabItem(withId:)` with `TabIdentifier`
    - Test `tabItems(forNavbar:)` with `NavbarIdentifier`
-   **Subtask 5.2.8**: Write a test to verify proper handling of optional fields (`switchToNavbar`).
-   **Subtask 5.2.9**: Write a test to verify error handling for invalid enum values in JSON.

## Additional Tasks

### Task 6.1: Add Documentation
-   **Subtask 6.1.1**: Add documentation comments to all public types and methods.
-   **Subtask 6.1.2**: Include usage examples in the documentation.
-   **Subtask 6.1.3**: Document the relationship between navbars and tab items.

### Task 6.2: Add Validation Methods
-   **Subtask 6.2.1**: Add methods to validate configuration integrity:
    ```swift
    public extension PresentationConfiguration {
        func validate() -> Bool {
            // Check for duplicate IDs (not needed anymore as we use enums)

            // Check for duplicate navbar names (not needed anymore as we use enums)

            // Validate all navbar tab references
            for navbar in navbars {
                for tabId in navbar.tabs {
                    guard tabItem(withId: tabId) != nil else { return false }
                }
            }

            return true
        }
    }
    ```

---

Once completed, this implementation will provide a type-safe foundation for managing configurable tab bars and navigation bars in your application, with compile-time checking for valid identifiers.