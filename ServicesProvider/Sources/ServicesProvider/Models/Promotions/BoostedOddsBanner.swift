//
//  BoostedOddsBanner.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Banner showcasing boosted odds for a sport event
public struct BoostedOddsBanner: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Banner title
    public let title: String
    
    /// Original odds value
    public let originalOdd: Double
    
    /// Boosted odds value
    public let boostedOdd: Double
    
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
    ///   - originalOdd: Original odds value
    ///   - boostedOdd: Boosted odds value
    ///   - sportEventId: Associated sport event ID
    ///   - startDate: Start date when banner should be displayed
    ///   - endDate: End date when banner should stop being displayed
    ///   - status: Status of the banner
    ///   - imageUrl: Image URL for the banner
    ///   - event: Associated event information
    public init(
        id: Int,
        title: String,
        originalOdd: Double,
        boostedOdd: Double,
        sportEventId: Int,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?,
        event: SportEventSummary?
    ) {
        self.id = id
        self.title = title
        self.originalOdd = originalOdd
        self.boostedOdd = boostedOdd
        self.sportEventId = sportEventId
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
        self.event = event
    }
} 