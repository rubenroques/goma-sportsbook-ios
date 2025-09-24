//
//  CasinoLobbyType.swift
//  BetssonCameroonApp
//
//  Created by Claude on 24/09/2025.
//

import Foundation
import ServicesProvider

/// Enum representing different types of casino lobbies in the app layer
enum CasinoLobbyType {
    case casino
    case virtuals

    /// Convert to ServiceProvider enum for API calls
    var serviceProviderType: ServicesProvider.CasinoLobbyType {
        switch self {
        case .casino:
            return .casino
        case .virtuals:
            return .virtuals
        }
    }

    /// User-friendly display name for the lobby type
    var displayName: String {
        switch self {
        case .casino:
            return "Casino"
        case .virtuals:
            return "Virtual Sports"
        }
    }
}