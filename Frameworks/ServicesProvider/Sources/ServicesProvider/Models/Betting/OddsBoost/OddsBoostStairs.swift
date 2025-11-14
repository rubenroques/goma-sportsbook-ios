
import Foundation

/// Provider-agnostic odds boost stairs response
/// Represents the current and next bonus tiers for a betslip
public struct OddsBoostStairsResponse: Equatable {

    /// Current bonus tier (user currently qualifies for)
    public let currentStair: OddsBoostStair?

    /// Next bonus tier (available by adding more selections)
    /// Nil when user has reached maximum bonus tier
    public let nextStair: OddsBoostStair?

    /// Event IDs that are eligible for the bonus
    public let eligibleEventIds: [String]

    /// UBS Wallet ID required for bet placement
    /// CRITICAL: Must be passed in placeBet request to apply bonus
    public let ubsWalletId: String

    /// Currency for which this bonus applies
    public let currency: String

    /// All available bonus tiers/stairs in the progression
    /// Used to display the complete boost ladder to users
    /// Example: [3→10%, 4→15%, 5→20%]
    public let allStairs: [OddsBoostStair]

    /// Minimum odds requirement per selection to qualify for bonus
    /// Example: 1.1 means each selection must have odds >= 1.1
    /// Nil if no minimum odds requirement exists
    public let minOdds: Double?

    public init(
        currentStair: OddsBoostStair?,
        nextStair: OddsBoostStair?,
        eligibleEventIds: [String],
        ubsWalletId: String,
        currency: String,
        allStairs: [OddsBoostStair],
        minOdds: Double? = nil
    ) {
        self.currentStair = currentStair
        self.nextStair = nextStair
        self.eligibleEventIds = eligibleEventIds
        self.ubsWalletId = ubsWalletId
        self.currency = currency
        self.allStairs = allStairs
        self.minOdds = minOdds
    }

    /// Whether user has reached maximum bonus tier
    public var isMaxTierReached: Bool {
        return currentStair != nil && nextStair == nil
    }

    /// Number of additional selections needed to reach next tier
    /// Returns nil if no next tier exists
    public func selectionsNeededForNextTier(currentSelectionCount: Int) -> Int? {
        guard let nextStair = nextStair else { return nil }
        let needed = nextStair.minSelectionNumber - currentSelectionCount
        return max(0, needed)
    }
}

/// Represents a single bonus tier/stair
public struct OddsBoostStair: Equatable {

    /// Minimum number of selections required for this tier
    public let minSelectionNumber: Int

    /// Bonus percentage as decimal (0.1 = 10%, 0.2 = 20%)
    public let percentage: Double

    /// Maximum bonus amount for user's currency
    /// Formula: min(potentialWinnings × percentage, capAmount)
    public let capAmount: Double

    public init(
        minSelectionNumber: Int,
        percentage: Double,
        capAmount: Double
    ) {
        self.minSelectionNumber = minSelectionNumber
        self.percentage = percentage
        self.capAmount = capAmount
    }

    /// Calculate bonus amount for given potential winnings
    /// - Parameter potentialWinnings: Expected winnings before bonus
    /// - Returns: Bonus amount (capped at capAmount)
    public func calculateBonus(for potentialWinnings: Double) -> Double {
        let rawBonus = potentialWinnings * percentage
        return min(rawBonus, capAmount)
    }

    /// Bonus percentage as display value (10.0 for 10%)
    public var percentageDisplay: Double {
        return percentage * 100.0
    }
}

/// Selection input for odds boost stairs calculation
/// Only contains the minimal data needed to calculate bonus tiers
public struct OddsBoostStairsSelection: Equatable {

    /// Outcome ID (betting offer ID)
    public let outcomeId: String

    /// Event ID (match ID)
    public let eventId: String

    public init(outcomeId: String, eventId: String) {
        self.outcomeId = outcomeId
        self.eventId = eventId
    }
}
