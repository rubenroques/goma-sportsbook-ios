import Foundation

/// Configuration for a navigation bar in the application
///
/// This struct represents a navbar section, including its identifier, route,
/// and the tabs that should be displayed when this navbar is active.
public struct NavigationBarLayout: Codable, Identifiable {
    /// The identifier for this navbar
    public let id: NavbarIdentifier
    
    /// The route/path associated with this navbar for navigation
    public let route: String
    
    /// Array of tab identifiers that should be displayed when this navbar is active
    public let tabs: [TabIdentifier]

    private enum CodingKeys: String, CodingKey {
        case id
        case route
        case tabs
    }
    
    /// Initializes a new NavbarConfig with the provided values
    ///
    /// - Parameters:
    ///   - id: The identifier for this navbar
    ///   - route: The route/path for this navbar
    ///   - tabs: The array of tab identifiers to display
    public init(id: NavbarIdentifier, route: String, tabs: [TabIdentifier]) {
        self.id = id
        self.route = route
        self.tabs = tabs
    }
} 
