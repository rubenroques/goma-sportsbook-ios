//
//  CasinoGameMode.swift
//  ServicesProvider
//
//  Created by Claude on 29/01/2025.
//

import Foundation

/// Represents different modes for launching a casino game
public enum CasinoGameMode: String, Codable, Hashable, CaseIterable {
    
    /// Demo mode for non-authenticated users
    case funGuest = "fun_guest"
    
    /// Demo mode for authenticated users
    case funLoggedIn = "fun_logged_in"
    
    /// Real money mode for authenticated users
    case realMoney = "real_money"
    
    /// Display name for the game mode
    public var displayName: String {
        switch self {
        case .funGuest:
            return "Demo"
        case .funLoggedIn:
            return "Demo (Logged In)"
        case .realMoney:
            return "Real Money"
        }
    }
    
    /// Whether this mode requires authentication
    public var requiresAuthentication: Bool {
        switch self {
        case .funGuest:
            return false
        case .funLoggedIn, .realMoney:
            return true
        }
    }
}

/// Represents available real money modes for a game
public struct CasinoGameRealMode: Codable, Hashable {
    
    /// Whether fun mode is available
    public let fun: Bool
    
    /// Whether anonymous play is available
    public let anonymity: Bool
    
    /// Whether real money mode is available
    public let realMoney: Bool
    
    public init(fun: Bool, anonymity: Bool, realMoney: Bool) {
        self.fun = fun
        self.anonymity = anonymity
        self.realMoney = realMoney
    }
}

/// Represents betting restrictions for a game
public struct CasinoGameBetRestriction: Codable, Hashable {
    
    /// Default maximum bet amounts by currency
    public let defaultMaxBet: [String: Double]?
    
    /// Default maximum win amounts by currency
    public let defaultMaxWin: [String: Double]?
    
    /// Default maximum multiplier
    public let defaultMaxMultiplier: Double?
    
    public init(
        defaultMaxBet: [String: Double]? = nil,
        defaultMaxWin: [String: Double]? = nil,
        defaultMaxMultiplier: Double? = nil
    ) {
        self.defaultMaxBet = defaultMaxBet
        self.defaultMaxWin = defaultMaxWin
        self.defaultMaxMultiplier = defaultMaxMultiplier
    }
}
