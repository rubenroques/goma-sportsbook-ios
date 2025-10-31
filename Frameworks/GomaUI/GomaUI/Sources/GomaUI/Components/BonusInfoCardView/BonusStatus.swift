//
//  BonusStatus.swift
//  GomaUI
//
//  Created by Claude on October 24, 2025.
//

import Foundation

/// Represents the status of a bonus
public enum BonusStatus {
    case active
    case released
    
    /// Display text for the status
    var displayText: String {
        switch self {
        case .active:
            return "Active"
        case .released:
            return "Released"
        }
    }
}

