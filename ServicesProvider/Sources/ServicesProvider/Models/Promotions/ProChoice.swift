//
//  ProChoice.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Expert betting tip
public struct ProChoice: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Tip title
    public let title: String
    
    /// Information about the tipster
    public let tipster: Tipster
    
    /// Information about the event
    public let event: EventSummary
    
    /// Information about the selection
    public let selection: Selection
    
    /// Reasoning for the tip
    public let reasoning: String
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Tip title
    ///   - tipster: Information about the tipster
    ///   - event: Information about the event
    ///   - selection: Information about the selection
    ///   - reasoning: Reasoning for the tip
    public init(
        id: Int,
        title: String,
        tipster: Tipster,
        event: EventSummary,
        selection: Selection,
        reasoning: String
    ) {
        self.id = id
        self.title = title
        self.tipster = tipster
        self.event = event
        self.selection = selection
        self.reasoning = reasoning
    }
}

/// Information about a tipster
public struct Tipster: Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Tipster name
    public let name: String
    
    /// Win rate percentage
    public let winRate: Double
    
    /// Avatar image URL
    public let avatar: URL?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - name: Tipster name
    ///   - winRate: Win rate percentage
    ///   - avatar: Avatar image URL
    public init(
        id: Int,
        name: String,
        winRate: Double,
        avatar: URL?
    ) {
        self.id = id
        self.name = name
        self.winRate = winRate
        self.avatar = avatar
    }
}

/// Summary information about an event
public struct EventSummary: Equatable {
    /// Event identifier
    public let id: Int
    
    /// Home team name
    public let homeTeam: String
    
    /// Away team name
    public let awayTeam: String
    
    /// Event date and time
    public let dateTime: Date
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Event identifier
    ///   - homeTeam: Home team name
    ///   - awayTeam: Away team name
    ///   - dateTime: Event date and time
    public init(
        id: Int,
        homeTeam: String,
        awayTeam: String,
        dateTime: Date
    ) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.dateTime = dateTime
    }
}

/// Information about a betting selection
public struct Selection: Equatable {
    /// Market name
    public let marketName: String
    
    /// Outcome name
    public let outcomeName: String
    
    /// Odds value
    public let odds: Double
    
    /// Public initializer
    /// - Parameters:
    ///   - marketName: Market name
    ///   - outcomeName: Outcome name
    ///   - odds: Odds value
    public init(
        marketName: String,
        outcomeName: String,
        odds: Double
    ) {
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odds = odds
    }
} 