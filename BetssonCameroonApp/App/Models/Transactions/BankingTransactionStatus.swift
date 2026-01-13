//
//  BankingTransactionStatus.swift
//  BetssonCameroonApp
//
//  Created by Transaction History Enhancement on 30/09/2025.
//

import Foundation

enum BankingTransactionStatus: Hashable {
    case failed     // System/auth failures (AuthFailed, Failed, DebitFailed, CreditFailed)
    case cancelled  // User-initiated cancellations (Cancelled, RollBack)
    case pending
    case success    // Represents completed/successful transactions (empty string in web)

    enum BadgeType {
        case `default`
        case success
        case error
    }

    var badgeType: BadgeType {
        switch self {
        case .failed:
            return .error
        case .cancelled:
            return .default
        case .pending:
            return .default
        case .success:
            return .success
        }
    }

    var displayName: String {
        switch self {
        case .failed:
            return localized("failed")
        case .cancelled:
            return localized("cancelled")
        case .pending:
            return localized("pending")
        case .success:
            return ""  // Success doesn't show a status label
        }
    }

    /// Maps raw EveryMatrix API status strings to normalized status
    /// Based on web implementation: bankingTransactionStatuses
    static func from(rawStatus: String) -> BankingTransactionStatus {
        switch rawStatus {
        // Success cases (no status badge)
        case "Setup", "Success":
            return .success

        // Pending cases
        case "Processing", "Pending", "ProcessingDebit", "ProcessingCredit", "PendingNotification", "PendingApproval":
            return .pending

        // Failed cases (system/auth failures) - SPOR-7118
        case "AuthFailed", "Failed", "DebitFailed", "CreditFailed":
            return .failed

        // Cancelled cases (user-initiated)
        case "Cancelled", "RollBack":
            return .cancelled

        default:
            return .success  // Default to success for unknown statuses
        }
    }
}