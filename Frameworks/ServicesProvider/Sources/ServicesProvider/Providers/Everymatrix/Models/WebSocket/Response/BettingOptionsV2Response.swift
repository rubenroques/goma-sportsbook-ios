
import Foundation

extension EveryMatrix {

    /// Response model for /sports#bettingOptionsV2 RPC call
    /// This endpoint validates bet selections and returns betting constraints,
    /// odds calculations, and available bonuses/promotions
    struct BettingOptionsV2Response: Codable {
        let success: Bool?
        let minStake: Double?
        let maxStake: Double?
        let priceValueFactor: Double?
        let freeBets: [FreeBet]?
        let oddsBoosts: [OddsBoost]?
        let stakeBacks: [StakeBack]?
        let betBuilder: [BetBuilder]?
        let forbiddenCombinations: [ForbiddenCombination]?
        let availableForManualBetRequest: Bool?
        let maxWinningAndTaxes: MaxWinningAndTaxes?

        /// Free bet information
        struct FreeBet: Codable {
            let id: String?
            let amount: Double?
            let minOdds: Double?
            let maxOdds: Double?
            let currency: String?
            let expiryDate: String?
        }

        /// Odds boost information
        struct OddsBoost: Codable {
            let walletId: String?
            let percentage: Double?
            let capAmount: Double?
            let minSelections: Int?
            let maxSelections: Int?
            let minOddsPerSelection: Double?
        }

        /// Stake back information
        struct StakeBack: Codable {
            let percentage: Double?
            let amount: Double?
            let currency: String?
            let minStake: Double?
            let maxStake: Double?
        }

        /// Bet builder information
        struct BetBuilder: Codable {
            let selections: [BetBuilderSelection]?
            let betBuilderOdds: Double?
        }

        /// Bet builder selection information
        struct BetBuilderSelection: Codable {
            let bettingOfferId: String?
            let outcomeId: String?
            let bettingTypeId: String?
            let priceValue: Double?
            let banker: Bool?
        }

        /// Forbidden combination information
        struct ForbiddenCombination: Codable {
            let selections: [ForbiddenCombinationSelection]?
        }

        /// Forbidden combination selection information
        struct ForbiddenCombinationSelection: Codable {
            let bettingOfferId: String?
            let outcomeId: String?
            let bettingTypeId: String?
            let priceValue: Double?
            let banker: Bool?
        }

        /// Tax and maximum winning information
        struct MaxWinningAndTaxes: Codable {
            let maxWinning: Double?
            let taxEnabled: Bool?
            let stakeTax: Double?
            let stakeTaxPercentage: Double?
            let winningTax: Double?
            let winningTaxPercentage: Double?
        }
    }
}
