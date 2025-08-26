
import Foundation

/// Represents a casino game category (e.g., Video Slots, Table Games)
public struct CasinoCategory: Codable, Hashable, Identifiable {
    
    /// Unique identifier for the category
    public let id: String
    
    /// Display name of the category
    public let name: String
    
    /// API href for fetching more details about the category
    public let href: String
    
    /// Total number of games in this category
    public let gamesTotal: Int
    
    public init(id: String, name: String, href: String, gamesTotal: Int) {
        self.id = id
        self.name = name
        self.href = href
        self.gamesTotal = gamesTotal
    }
}

/// Represents the paginated response for casino categories
public struct CasinoCategoriesResponse: Codable {
    
    /// Number of categories in current response
    public let count: Int
    
    /// Total number of categories available
    public let total: Int
    
    /// Array of casino categories
    public let items: [CasinoCategory]
    
    /// Pagination information
    public let pagination: CasinoPaginationInfo?
    
    public init(count: Int, total: Int, items: [CasinoCategory], pagination: CasinoPaginationInfo?) {
        self.count = count
        self.total = total
        self.items = items
        self.pagination = pagination
    }
}
