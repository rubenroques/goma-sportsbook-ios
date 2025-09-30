//
//  BankingTransactionStatus.swift
//  BetssonCameroonApp
//
//  Created by Transaction History Enhancement on 30/09/2025.
//

import Foundation

enum BankingTransactionStatus: Hashable {
    case cancelled
    case pending
    case success  // Represents completed/successful transactions (empty string in web)

    enum BadgeType {
        case `default`
        case success
        case error
    }

    var badgeType: BadgeType {
        switch self {
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
        case .cancelled:
            return "Cancelled"
        case .pending:
            return "Pending"
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

        // Cancelled/Failed cases
        case "Failed", "DebitFailed", "CreditFailed", "Cancelled", "RollBack":
            return .cancelled

        default:
            return .success  // Default to success for unknown statuses
        }
    }
}