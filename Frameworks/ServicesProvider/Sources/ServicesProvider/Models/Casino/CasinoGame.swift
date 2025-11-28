
import Foundation

/// Represents a casino game
public struct CasinoGame: Codable, Hashable, Identifiable {
    
    /// Unique identifier for the game
    public let id: String
    
    /// Display name of the game
    public let name: String
    
    /// URL to launch the game
    public let launchUrl: String
    
    /// Main thumbnail image URL
    public let thumbnail: String
    
    /// Background image URL for the game
    public let backgroundImageUrl: String
    
    /// Game vendor/provider information (optional - not displayed in UI)
    public let vendor: CasinoGameVendor?
    
    /// Game sub-vendor
    public let subVendor: String?
    
    /// Game description
    public let description: String
    
    /// URL slug for the game
    public let slug: String
    
    /// Whether the game supports fun/demo mode
    public let hasFunMode: Bool
    
    /// Whether the game supports anonymous fun mode
    public let hasAnonymousFunMode: Bool
    
    /// Supported platforms (PC, iPhone, iPad, Android)
    public let platforms: [String]
    
    /// Game popularity score
    public let popularity: Double?
    
    /// Whether the game is newly added
    public let isNew: Bool
    
    /// Game dimensions
    public let width: Int?
    public let height: Int?
    
    /// Theoretical payout percentage
    public let theoreticalPayOut: Double?
    
    /// Available game modes
    public let realMode: CasinoGameRealMode?
    
    /// Game icon URLs in different sizes
    public let icons: [String: String]?
    
    /// Game tags for categorization
    public let tags: [String]?
    
    /// Maximum bet restrictions
    public let maxBetRestriction: CasinoGameBetRestriction?
    
    public init(
        id: String,
        name: String,
        launchUrl: String,
        thumbnail: String,
        backgroundImageUrl: String,
        vendor: CasinoGameVendor? = nil,
        subVendor: String? = nil,
        description: String,
        slug: String,
        hasFunMode: Bool,
        hasAnonymousFunMode: Bool,
        platforms: [String],
        popularity: Double? = nil,
        isNew: Bool = false,
        width: Int? = nil,
        height: Int? = nil,
        theoreticalPayOut: Double? = nil,
        realMode: CasinoGameRealMode? = nil,
        icons: [String: String]? = nil,
        tags: [String]? = nil,
        maxBetRestriction: CasinoGameBetRestriction? = nil
    ) {
        self.id = id
        self.name = name
        self.launchUrl = launchUrl
        self.thumbnail = thumbnail
        self.backgroundImageUrl = backgroundImageUrl
        self.vendor = vendor
        self.subVendor = subVendor
        self.description = description
        self.slug = slug
        self.hasFunMode = hasFunMode
        self.hasAnonymousFunMode = hasAnonymousFunMode
        self.platforms = platforms
        self.popularity = popularity
        self.isNew = isNew
        self.width = width
        self.height = height
        self.theoreticalPayOut = theoreticalPayOut
        self.realMode = realMode
        self.icons = icons
        self.tags = tags
        self.maxBetRestriction = maxBetRestriction
    }
}

/// Represents the paginated response for casino games
public struct CasinoGamesResponse: Codable {

    /// Number of games in current response
    public let count: Int

    /// Total number of games available
    public let total: Int

    /// Array of casino games
    public let games: [CasinoGame]

    /// Pagination information
    public let pagination: CasinoPaginationInfo?

    /// Localized category name from API (when fetching games by category)
    public let categoryName: String?

    public init(count: Int, total: Int, games: [CasinoGame], pagination: CasinoPaginationInfo?, categoryName: String? = nil) {
        self.count = count
        self.total = total
        self.games = games
        self.pagination = pagination
        self.categoryName = categoryName
    }
}

/// Computed property to check if more games are available
public extension CasinoGamesResponse {
    var hasMore: Bool {
        return games.count < total
    }
}
