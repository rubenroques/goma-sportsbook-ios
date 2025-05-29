import Foundation

/// Mapper for transforming raw EveryMatrix API sport data into Sport models
public struct SportMapper {
    
    /// Maps raw API sport data to a Sport model
    /// - Parameters:
    ///   - rawSport: Raw sport data from the API
    ///   - context: Context for the sport (e.g., "live", "popular")
    ///   - existingSports: Array of existing sports to check for duplicates
    /// - Returns: Mapped Sport model
    public static func mapSport(
        from rawSport: [String: Any],
        context: String = "popular",
        existingSports: inout [Sport]
    ) -> Sport? {
        guard let id = rawSport["id"] as? String ?? (rawSport["id"] as? Int).map(String.init) else {
            return nil
        }
        
        // Check if sport already exists
        if let existingIndex = existingSports.firstIndex(where: { $0.id == id }) {
            // Update existing sport with new context
            let updatedSport = existingSports[existingIndex].withContext(context)
            existingSports[existingIndex] = updatedSport
            return updatedSport
        }
        
        // Create new sport
        let sport = Sport(
            id: id,
            originalId: rawSport["id"] as? String ?? id,
            boNavigationId: rawSport["id"] as? String ?? id,
            name: rawSport["name"] as? String ?? "",
            shortName: rawSport["shortName"] as? String,
            iconId: {
                if let iconId = rawSport["iconId"] as? String {
                    return iconId
                } else if let numericId = Int(id) {
                    return String(numericId)
                } else {
                    return "noicon"
                }
            }(),
            isVirtual: rawSport["isVirtual"] as? Bool ?? false,
            numberOfEvents: rawSport["numberOfEvents"] as? Int ?? 0,
            numberOfOutrightsEvents: rawSport["numberOfOutrightsEvents"] as? Int ?? 0,
            numberOfMarkets: rawSport["numberOfMarkets"] as? Int ?? 0,
            numberOfOutrightsMarkets: rawSport["numberOfOutrightsMarkets"] as? Int ?? 0,
            numberOfBettingOffers: rawSport["numberOfBettingOffers"] as? Int ?? 0,
            numberOfMarketGroups: rawSport["numberOfMarketGroups"] as? Int ?? 0,
            numberOfLiveMarkets: rawSport["numberOfLiveMarkets"] as? Int ?? 0,
            numberOfLiveBettingOffers: rawSport["numberOfLiveBettingOffers"] as? Int ?? 0,
            numberOfLiveEvents: rawSport["numberOfLiveEvents"] as? Int ?? 0,
            numberOfUpcomingMatches: rawSport["numberOfUpcomingMatches"] as? Int ?? 0,
            numberOfMatchesWhichWillHaveLiveOdds: rawSport["numberOfMatchesWhichWillHaveLiveOdds"] as? Int ?? 0,
            childrenIds: rawSport["childrenIds"] as? [String] ?? [],
            displayChildren: rawSport["displayChildren"] as? Bool ?? false,
            showEventCategory: rawSport["showEventCategory"] as? Bool ?? false,
            isTopSport: rawSport["isTopSport"] as? Bool ?? false,
            hasMatches: rawSport["hasMatches"] as? Bool ?? false,
            hasOutrights: rawSport["hasOutrights"] as? Bool ?? false,
            contexts: [context: 1]
        )
        
        existingSports.append(sport)
        return sport
    }
    
    /// Maps an array of raw sports data
    /// - Parameters:
    ///   - rawSports: Array of raw sport data from the API
    ///   - context: Context for the sports
    ///   - existingSports: Array of existing sports to merge with
    /// - Returns: Array of mapped Sport models
    public static func mapSports(
        from rawSports: [[String: Any]],
        context: String = "popular",
        existingSports: inout [Sport]
    ) -> [Sport] {
        return rawSports.compactMap { rawSport in
            mapSport(from: rawSport, context: context, existingSports: &existingSports)
        }
    }
}

/// Extension for handling EveryMatrix socket responses
extension SportMapper {
    
    /// Maps sports from EveryMatrix socket response format
    /// - Parameters:
    ///   - socketResponse: Raw socket response containing sports data
    ///   - context: Context for the sports
    ///   - existingSports: Array of existing sports to merge with
    /// - Returns: Array of mapped Sport models
    public static func mapSportsFromSocketResponse(
        _ socketResponse: [String: Any],
        context: String = "popular",
        existingSports: inout [Sport]
    ) -> [Sport] {
        // Handle different response formats from EveryMatrix
        if let kwargs = socketResponse["kwargs"] as? [String: Any],
           let records = kwargs["records"] as? [[String: Any]] {
            return mapSports(from: records, context: context, existingSports: &existingSports)
        } else if let records = socketResponse["records"] as? [[String: Any]] {
            return mapSports(from: records, context: context, existingSports: &existingSports)
        } else if let sportsArray = socketResponse as? [[String: Any]] {
            return mapSports(from: sportsArray, context: context, existingSports: &existingSports)
        }
        
        return []
    }
} 