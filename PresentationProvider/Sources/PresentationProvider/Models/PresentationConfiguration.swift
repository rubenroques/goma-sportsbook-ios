import Foundation

/// Main configuration model for presentation layer
///
/// This struct holds the complete configuration for the presentation layer,
/// including all tab items and navbars.
public struct PresentationConfiguration: Codable {
    /// Array of all available tab items in the application
    public let tabItems: [TabItem]
    
    /// Array of all available navbars in the application
    public let navbars: [NavigationBarLayout]

    private enum CodingKeys: String, CodingKey {
        case tabItems = "tabItems"
        case navbars = "navbars"
    }
    
    /// Initializes a new PresentationConfiguration with the provided values
    ///
    /// - Parameters:
    ///   - tabItems: Array of tab item configurations
    ///   - navbars: Array of navbar configurations
    public init(tabItems: [TabItem], navbars: [NavigationBarLayout]) {
        self.tabItems = tabItems
        self.navbars = navbars
    }
}

public extension PresentationConfiguration {
    /// Find a navbar by its identifier
    ///
    /// - Parameter name: The navbar identifier to search for
    /// - Returns: The matching NavbarConfig or nil if not found
    func navbar(withId id: NavbarIdentifier) -> NavigationBarLayout? {
        return navbars.first { $0.id == id }
    }

    /// Find a tab item by its identifier
    ///
    /// - Parameter id: The tab identifier to search for
    /// - Returns: The matching TabItemConfig or nil if not found
    func tabItem(withId id: TabIdentifier) -> TabItem? {
        return tabItems.first { $0.tabId == id }
    }

    /// Get all tab items for a specific navbar
    ///
    /// - Parameter navbarName: The navbar identifier to get tabs for
    /// - Returns: Array of TabItemConfig objects in the order they appear in the navbar's tabs array
    func tabItems(forNavbar navbarId: NavbarIdentifier) -> [TabItem] {
        guard let navbar = navbar(withId: navbarId) else { return [] }
        return navbar.tabs.compactMap { tabId in
            tabItem(withId: tabId)
        }
    }
    
    /// Validates the integrity of the configuration
    ///
    /// This ensures that all navbar tab references point to valid tab items
    ///
    /// - Returns: True if the configuration is valid, false otherwise
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
