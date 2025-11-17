//
//  EveryMatrix+BalanceUpdateBody.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation

extension EveryMatrix {

    /// BALANCE_UPDATE or BALANCE_UPDATE_V2 message body structure
    /// Represents a wallet transaction event from SSE stream
    struct BalanceUpdateBody: Decodable {

        /// User ID who owns the wallet
        let userId: String

        /// Domain/operator ID
        let domainId: Int

        /// ISO8601 timestamp when the transaction streamed
        let streamingDate: String

        /// Source system (e.g., "GmSlim", "Casino")
        let source: String

        /// Transaction type code (OPTIONAL - not always present in SSE messages)
        /// 0 = Unknown, 1 = Deposit, 2 = Withdrawal, 3 = Win, 4 = Refund,
        /// 5 = Bonus, 6 = Adjustment, 7 = Bet, 8 = Reserve, 9 = Release, 10 = Jackpot
        /// Defaults to .unknown if missing
        let transType: Int?

        /// Currency code (e.g., "XAF", "EUR")
        let currency: String

        /// Operation type
        /// 0 = Debit (money out), 1 = Credit (money in),
        /// 2 = Reserve (hold funds), 3 = Release (release held)
        let operationType: Int

        /// Unique posting/transaction ID for deduplication
        let postingId: String

        /// Balance changes by wallet type
        /// Keys: "Real", "Bonus", etc.
        /// Values: BalanceChangeDetail with amounts
        let balanceChange: [String: BalanceChangeDetail]

        // MARK: - Optional Fields (not used but present in SSE message)

        /// Account vendor ID (optional, not used)
        let accountVendorId: Int?

        /// Account type (optional, not used)
        let accountType: Int?

        /// Wallet type (optional, not used)
        let walletType: Int?

        /// Whether this is a vendor account (optional, not used)
        let vendorAccount: Bool?

        /// Balance change detail for a specific wallet type
        struct BalanceChangeDetail: Decodable {

            /// Amount that changed (e.g., -1000.0 for bet, +5000.0 for win)
            let affectedAmount: Double

            /// New balance after the transaction
            let afterAmount: Double

            /// Product type (e.g., "Sports", "Casino")
            let productType: String?

            /// Wallet account type (e.g., "Ordinary")
            let walletAccountType: String

            // MARK: - Optional Currency Fields

            /// Currency code for affected amount (optional, redundant with parent currency)
            let affectedAmountCurrency: String?

            /// Currency code for after amount (optional, redundant with parent currency)
            let afterAmountCurrency: String?
        }
    }
}
