//
//  EveryMatrix+OddsBoost.swift
//  ServicesProvider
//
//  Created by Claude on 15/10/2025.
//

import Foundation

extension EveryMatrix {

    // MARK: - Odds Boost Wallet Request

    struct OddsBoostWalletRequest: Codable {
        let stakeCurrency: String?
        let stakeAmount: Double?
        let includeVendorConfiguration: Bool
        let includePotentialOddsBoostWallet: Bool
        let terminalType: String?
        let combination: [BetCombinationSelections]
    }

    struct BetCombinationSelections: Codable {
        let selection: [BetSelectionPointer]
    }

    struct BetSelectionPointer: Codable {
        let outcomeId: String
        let eventId: String
    }

    // MARK: - Odds Boost Wallet Response

    struct OddsBoostWalletResponse: Codable {
        let total: Int
        let count: Int
        let lockedRealMoneyAmount: Double
        let items: [BonusWalletItem]
        let pages: PaginationPages
        let success: Bool
        let executionTime: Double
        let requestId: String
    }

    struct PaginationPages: Codable {
        let first: String
        let last: String
    }

    // MARK: - Bonus Wallet Item

    struct BonusWalletItem: Codable {
        let id: Int64
        let bonusID: String
        let type: String
        let status: String
        let currency: String
        let amount: Double
        let lockedAmount: Double
        let grantedBonusAmount: Double
        let fulfilledWR: Double
        let ordinal: Double
        let incompleteBets: Double

        // Only present when combination parameter is provided
        let odds: EventOddsRangeCollection?
        let oddsBoost: OddsBoostInfo?

        let bonusExtension: BonusWalletExtension

        enum CodingKeys: String, CodingKey {
            case id, bonusID, type, status, currency, amount, lockedAmount
            case grantedBonusAmount, fulfilledWR, ordinal, incompleteBets
            case odds, oddsBoost
            case bonusExtension = "extension"
        }
    }

    // MARK: - Event Odds Range Collection

    /// Maps event IDs to their respective odds range requirements for the bonus
    struct EventOddsRangeCollection: Codable {
        /// Dictionary mapping event ID to odds range constraints
        /// Example: { "284443475567742976": { min: 1.1, max: 9999 } }
        private let ranges: [String: OddsRange]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.ranges = try container.decode([String: OddsRange].self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(ranges)
        }

        /// Get odds range for a specific event ID
        func oddsRange(forEventId eventId: String) -> OddsRange? {
            return ranges[eventId]
        }

        /// All event IDs that have odds range constraints
        var eventIds: [String] {
            return Array(ranges.keys)
        }

        /// Check if event ID has odds constraints
        func hasConstraints(forEventId eventId: String) -> Bool {
            return ranges[eventId] != nil
        }
    }

    // MARK: - Odds Range

    /// Represents min/max odds constraints for an event in the bonus
    struct OddsRange: Codable {
        let min: Double?
        let max: Double?
    }

    // MARK: - Odds Boost Info (returned when selections provided)

    struct OddsBoostInfo: Codable {
        let eligibleEventID: [String]
        let currentStair: OddsBoostStair?
        let nextStair: OddsBoostStair?
    }

    // MARK: - Odds Boost Stair (Tier/Step)

    struct OddsBoostStair: Codable {
        let minSelectionNumber: Int
        let percentage: Double
        let capAmount: [String: Double]
    }

    // MARK: - Bonus Wallet Extension

    struct BonusWalletExtension: Codable {
        let id: String
        let ins: String
        let parent: Int
        let bonusWalletID: Int64
        let domainID: Int
        let realm: String
        let bonusID: String
        let userID: String
        let bonus: BonusDetail
        let currency: String
        let totalWR: Int
        let triggerType: String
        let triggerEvent: Int
        let productCategory: Int
    }

    // MARK: - Bonus Detail

    struct BonusDetail: Codable {
        let id: String
        let ins: String
        let version: String
        let code: String
        let status: String
        let type: String
        let domainID: Int
        let realm: String
        let baseCurrency: String
        let wallet: BonusWallet
        let modified: String
    }

    // MARK: - Bonus Wallet Configuration

    struct BonusWallet: Codable {
        let invisible: Bool
        let flags: Int
        let validityDays: Int
        let validityMinutes: Int
        let expiryTime: String
        let debitMethod: String
        let wageringRequirementCoefficient: Double
        let oddsBoost: OddsBoostConfiguration?
    }

    // MARK: - Odds Boost Configuration (All Stairs/Tiers)

    struct OddsBoostConfiguration: Codable {
        let maxBetNumber: Int
        let sportsBoostStairs: [OddsBoostStair]
    }
}
