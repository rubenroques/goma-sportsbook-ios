//
//  SportBanner.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Sport-related promotional banner
public struct SportBanner: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Banner title
    public let title: String
    
    /// Optional subtitle
    public let subtitle: String?
    
    /// Associated sport event ID
    public let sportEventId: Int
    
    /// Start date when banner should be displayed
    public let startDate: Date
    
    /// End date when banner should stop being displayed
    public let endDate: Date
    
    /// Status of the banner
    public let status: String
    
    /// Image URL for the banner
    public let imageUrl: URL?
    
    /// Associated event information
    public let event: SportEventSummary?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Banner title
    ///   - subtitle: Optional subtitle
    ///   - sportEventId: Associated sport event ID
    ///   - startDate: Start date when banner should be displayed
    ///   - endDate: End date when banner should stop being displayed
    ///   - status: Status of the banner
    ///   - imageUrl: Image URL for the banner
    ///   - event: Associated event information
    public init(
        id: Int,
        title: String,
        subtitle: String?,
        sportEventId: Int,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?,
        event: SportEventSummary?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.sportEventId = sportEventId
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
        self.event = event
    }
}

/// Summary information about a sport event
public struct SportEventSummary: Equatable {
    /// Event identifier
    public let id: Int
    
    /// Sport identifier
    public let sportId: Int
    
    /// Home team identifier
    public let homeTeamId: Int
    
    /// Away team identifier
    public let awayTeamId: Int
    
    /// Event date and time
    public let dateTime: Date
    
    /// Home team name
    public let homeTeam: String
    
    /// Away team name
    public let awayTeam: String
    
    /// Home team logo URL
    public let homeTeamLogo: URL?
    
    /// Away team logo URL
    public let awayTeamLogo: URL?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Event identifier
    ///   - sportId: Sport identifier
    ///   - homeTeamId: Home team identifier
    ///   - awayTeamId: Away team identifier
    ///   - dateTime: Event date and time
    ///   - homeTeam: Home team name
    ///   - awayTeam: Away team name
    ///   - homeTeamLogo: Home team logo URL
    ///   - awayTeamLogo: Away team logo URL
    public init(
        id: Int,
        sportId: Int,
        homeTeamId: Int,
        awayTeamId: Int,
        dateTime: Date,
        homeTeam: String,
        awayTeam: String,
        homeTeamLogo: URL?,
        awayTeamLogo: URL?
    ) {
        self.id = id
        self.sportId = sportId
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.dateTime = dateTime
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeTeamLogo = homeTeamLogo
        self.awayTeamLogo = awayTeamLogo
    }
} 