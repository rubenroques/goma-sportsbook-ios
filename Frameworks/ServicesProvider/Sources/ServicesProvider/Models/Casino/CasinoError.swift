//
//  CasinoError.swift
//  ServicesProvider
//
//  Created by Claude on 29/01/2025.
//

import Foundation

/// Casino-specific error types
public enum CasinoError: Error, Hashable {
    
    /// Authentication-related errors
    case invalidSession
    case expiredSession
    case missingAuthentication
    case insufficientPermissions
    
    /// Resource not found errors
    case categoryNotFound(String)
    case gameNotFound(String)
    case playerNotFound(String)
    
    /// API-related errors
    case invalidAPIResponse
    case malformedData
    case unsupportedPlatform(String)
    case rateLimitExceeded
    
    /// Game launch errors
    case gameLaunchFailed(String)
    case unsupportedGameMode(CasinoGameMode)
    case gameNotAvailable(String)
    
    /// Network errors
    case networkError
    case timeout
    case noInternetConnection
    
    /// Generic error with message
    case unknown(String)
}

extension CasinoError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidSession:
            return "Invalid session. Please log in again."
        case .expiredSession:
            return "Session has expired. Please log in again."
        case .missingAuthentication:
            return "Authentication required to access this feature."
        case .insufficientPermissions:
            return "Insufficient permissions to perform this action."
            
        case .categoryNotFound(let categoryId):
            return "Casino category '\(categoryId)' not found."
        case .gameNotFound(let gameId):
            return "Casino game '\(gameId)' not found."
        case .playerNotFound(let playerId):
            return "Player '\(playerId)' not found."
            
        case .invalidAPIResponse:
            return "Invalid response from casino API."
        case .malformedData:
            return "Received malformed data from casino API."
        case .unsupportedPlatform(let platform):
            return "Platform '\(platform)' is not supported."
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
            
        case .gameLaunchFailed(let reason):
            return "Failed to launch game: \(reason)"
        case .unsupportedGameMode(let mode):
            return "Game mode '\(mode.rawValue)' is not supported for this game."
        case .gameNotAvailable(let reason):
            return "Game is not available: \(reason)"
            
        case .networkError:
            return "Network error"
        case .timeout:
            return "Request timed out. Please try again."
        case .noInternetConnection:
            return "No internet connection available."
            
        case .unknown(let message):
            return message
        }
    }
}
