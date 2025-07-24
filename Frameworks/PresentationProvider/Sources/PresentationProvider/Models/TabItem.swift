import Foundation

/// Configuration for a single tab item in the application
///
/// This struct represents a tab in the UI, including its identifier, route, display label,
/// and optional navbar to switch to when selected.
public struct TabItem: Codable, Identifiable {
    /// Unique identifier for the tab, used to satisfy Identifiable protocol
    public var id: TabIdentifier { tabId }
    
    /// The identifier for this tab
    public let tabId: TabIdentifier
    
    /// The route/path associated with this tab for navigation
    public let route: String
    
    /// The display label shown in the UI for this tab
    public let label: String

    /// The name of the icon to be displayed for this tab
    public let icon: String

    /// The context associated with this tab (e.g., "sports", "casino")
    public let context: String
    
    /// Optional navbar identifier to switch to when this tab is selected
    /// If nil, selecting this tab doesn't change the navbar
    public let switchToNavbar: NavbarIdentifier?

    private enum CodingKeys: String, CodingKey {
        case tabId = "id"
        case route
        case label
        case icon
        case context
        case switchToNavbar
    }
    
    /// Initializes a new TabItemConfig with the provided values
    ///
    /// - Parameters:
    ///   - tabId: The identifier for this tab
    ///   - route: The route/path for this tab
    ///   - label: The display label for this tab
    ///   - icon: The name of the icon for this tab
    ///   - context: The context for this tab
    ///   - switchToNavbar: The optional navbar to switch to (default: nil)
    public init(tabId: TabIdentifier, route: String, label: String, icon: String, context: String, switchToNavbar: NavbarIdentifier? = nil) {
        self.tabId = tabId
        self.route = route
        self.label = label
        self.icon = icon
        self.context = context
        self.switchToNavbar = switchToNavbar
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tabId = try container.decode(TabIdentifier.self, forKey: .tabId)
        route = try container.decode(String.self, forKey: .route)
        label = try container.decode(String.self, forKey: .label)
        icon = try container.decode(String.self, forKey: .icon)
        context = try container.decode(String.self, forKey: .context)
        switchToNavbar = try container.decodeIfPresent(NavbarIdentifier.self, forKey: .switchToNavbar)
    }
} 
