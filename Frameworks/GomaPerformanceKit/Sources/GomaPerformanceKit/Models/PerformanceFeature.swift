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

    /// Socket sports data loading
    case sportsData

    /// App initialization/boot
    case appBoot

    /// CMS/Managed content loading
    case cms

    /// Casino home page load (categories, games, banners)
    case casinoHome

    /// Sports home screen (NextUpEvents) loading
    case homeScreen

    /// External third-party SDK initialization (Firebase, XtremePush, Phrase, etc.)
    case externalDependencies
}
