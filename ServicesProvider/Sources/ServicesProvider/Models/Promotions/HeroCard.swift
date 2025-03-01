//
//  HeroCard.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Feature card displayed prominently in the app
public struct HeroCard: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Card title
    public let title: String
    
    /// Optional subtitle
    public let subtitle: String?
    
    /// Type of action when card is tapped
    public let actionType: String
    
    /// Target URL or deep link for the action
    public let actionTarget: String
    
    /// Start date when card should be displayed
    public let startDate: Date
    
    /// End date when card should stop being displayed
    public let endDate: Date
    
    /// Status of the card
    public let status: String
    
    /// Image URL for the card
    public let imageUrl: URL?
    
    /// Optional associated event ID
    public let eventId: Int?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Card title
    ///   - subtitle: Optional subtitle
    ///   - actionType: Type of action when card is tapped
    ///   - actionTarget: Target URL or deep link for the action
    ///   - startDate: Start date when card should be displayed
    ///   - endDate: End date when card should stop being displayed
    ///   - status: Status of the card
    ///   - imageUrl: Image URL for the card
    ///   - eventId: Optional associated event ID
    public init(
        id: Int,
        title: String,
        subtitle: String?,
        actionType: String,
        actionTarget: String,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?,
        eventId: Int?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.actionType = actionType
        self.actionTarget = actionTarget
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
        self.eventId = eventId
    }
} 