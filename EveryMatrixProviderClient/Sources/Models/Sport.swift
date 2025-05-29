import Foundation

/// Represents a sport/discipline in the EveryMatrix system
public struct Sport: Codable, Hashable, Identifiable {
    /// The entity type identifier
    public let entityType: String = "SPORT"
    
    /// Unique identifier for the sport
    public let id: String
    
    /// Original ID from the API
    public let originalId: String
    
    /// Navigation ID for back office
    public let boNavigationId: String
    
    /// Display name of the sport
    public let name: String
    
    /// Short display name
    public let shortName: String?
    
    /// Icon identifier for the sport
    public let iconId: String
    
    /// Whether this is a virtual sport
    public let isVirtual: Bool
    
    /// Number of events available
    public let numberOfEvents: Int
    
    /// Number of outright events
    public let numberOfOutrightsEvents: Int
    
    /// Number of markets available
    public let numberOfMarkets: Int
    
    /// Number of outright markets
    public let numberOfOutrightsMarkets: Int
    
    /// Number of betting offers
    public let numberOfBettingOffers: Int
    
    /// Number of market groups
    public let numberOfMarketGroups: Int
    
    /// Number of live markets
    public let numberOfLiveMarkets: Int
    
    /// Number of live betting offers
    public let numberOfLiveBettingOffers: Int
    
    /// Number of live events
    public let numberOfLiveEvents: Int
    
    /// Number of upcoming matches
    public let numberOfUpcomingMatches: Int
    
    /// Number of matches that will have live odds
    public let numberOfMatchesWhichWillHaveLiveOdds: Int
    
    /// Child sport IDs
    public let childrenIds: [String]
    
    /// Whether to display children
    public let displayChildren: Bool
    
    /// Whether to show event category
    public let showEventCategory: Bool
    
    /// Whether this is a top sport
    public let isTopSport: Bool
    
    /// Whether this sport has matches
    public let hasMatches: Bool
    
    /// Whether this sport has outrights
    public let hasOutrights: Bool
    
    /// Context information (live, popular, etc.)
    public var contexts: [String: Int]
    
    /// Whether this sport is available in live context
    public var isLive: Bool {
        return contexts["live"] != nil
    }
    
    /// Whether this sport is available in popular/pre-live context
    public var isPopular: Bool {
        return contexts["popular"] != nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, originalId, boNavigationId, name, shortName, iconId, isVirtual
        case numberOfEvents, numberOfOutrightsEvents, numberOfMarkets, numberOfOutrightsMarkets
        case numberOfBettingOffers, numberOfMarketGroups, numberOfLiveMarkets, numberOfLiveBettingOffers
        case numberOfLiveEvents, numberOfUpcomingMatches, numberOfMatchesWhichWillHaveLiveOdds
        case childrenIds, displayChildren, showEventCategory, isTopSport, hasMatches, hasOutrights
        case contexts
    }
    
    public init(
        id: String,
        originalId: String? = nil,
        boNavigationId: String? = nil,
        name: String,
        shortName: String? = nil,
        iconId: String? = nil,
        isVirtual: Bool = false,
        numberOfEvents: Int = 0,
        numberOfOutrightsEvents: Int = 0,
        numberOfMarkets: Int = 0,
        numberOfOutrightsMarkets: Int = 0,
        numberOfBettingOffers: Int = 0,
        numberOfMarketGroups: Int = 0,
        numberOfLiveMarkets: Int = 0,
        numberOfLiveBettingOffers: Int = 0,
        numberOfLiveEvents: Int = 0,
        numberOfUpcomingMatches: Int = 0,
        numberOfMatchesWhichWillHaveLiveOdds: Int = 0,
        childrenIds: [String] = [],
        displayChildren: Bool = false,
        showEventCategory: Bool = false,
        isTopSport: Bool = false,
        hasMatches: Bool = false,
        hasOutrights: Bool = false,
        contexts: [String: Int] = [:]
    ) {
        self.id = id
        self.originalId = originalId ?? id
        self.boNavigationId = boNavigationId ?? id
        self.name = name
        self.shortName = shortName
        self.iconId = iconId ?? (Int(id) != nil ? id : "noicon")
        self.isVirtual = isVirtual
        self.numberOfEvents = numberOfEvents
        self.numberOfOutrightsEvents = numberOfOutrightsEvents
        self.numberOfMarkets = numberOfMarkets
        self.numberOfOutrightsMarkets = numberOfOutrightsMarkets
        self.numberOfBettingOffers = numberOfBettingOffers
        self.numberOfMarketGroups = numberOfMarketGroups
        self.numberOfLiveMarkets = numberOfLiveMarkets
        self.numberOfLiveBettingOffers = numberOfLiveBettingOffers
        self.numberOfLiveEvents = numberOfLiveEvents
        self.numberOfUpcomingMatches = numberOfUpcomingMatches
        self.numberOfMatchesWhichWillHaveLiveOdds = numberOfMatchesWhichWillHaveLiveOdds
        self.childrenIds = childrenIds
        self.displayChildren = displayChildren
        self.showEventCategory = showEventCategory
        self.isTopSport = isTopSport
        self.hasMatches = hasMatches
        self.hasOutrights = hasOutrights
        self.contexts = contexts
    }
}

extension Sport {
    /// Updates the sport with new context information
    public func withContext(_ context: String) -> Sport {
        var updatedContexts = self.contexts
        updatedContexts[context] = 1
        
        return Sport(
            id: id,
            originalId: originalId,
            boNavigationId: boNavigationId,
            name: name,
            shortName: shortName,
            iconId: iconId,
            isVirtual: isVirtual,
            numberOfEvents: numberOfEvents,
            numberOfOutrightsEvents: numberOfOutrightsEvents,
            numberOfMarkets: numberOfMarkets,
            numberOfOutrightsMarkets: numberOfOutrightsMarkets,
            numberOfBettingOffers: numberOfBettingOffers,
            numberOfMarketGroups: numberOfMarketGroups,
            numberOfLiveMarkets: numberOfLiveMarkets,
            numberOfLiveBettingOffers: numberOfLiveBettingOffers,
            numberOfLiveEvents: numberOfLiveEvents,
            numberOfUpcomingMatches: numberOfUpcomingMatches,
            numberOfMatchesWhichWillHaveLiveOdds: numberOfMatchesWhichWillHaveLiveOdds,
            childrenIds: childrenIds,
            displayChildren: displayChildren,
            showEventCategory: showEventCategory,
            isTopSport: isTopSport,
            hasMatches: hasMatches,
            hasOutrights: hasOutrights,
            contexts: updatedContexts
        )
    }
} 