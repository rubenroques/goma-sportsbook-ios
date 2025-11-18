//
//  PerformanceFeature.swift
//  GomaPerformanceKit
//
//  Represents the business feature being measured
//

import Foundation

/// Represents a specific business feature or flow being tracked
public enum PerformanceFeature: String, Codable, CaseIterable {
    /// Deposit flow
    case deposit

    /// Withdraw flow
    case withdraw

    /// User authentication/login
    case login

    /// User registration
    case register

    /// Sports data loading (matches, odds, etc.)
    case sportsData
}
