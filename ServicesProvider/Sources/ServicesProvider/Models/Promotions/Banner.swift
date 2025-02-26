//
//  Banner.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Promotional banner displayed in the app
public struct Banner: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Banner title
    public let title: String
    
    /// Optional subtitle
    public let subtitle: String?
    
    /// Type of action when banner is tapped
    public let actionType: String
    
    /// Target URL or deep link for the action
    public let actionTarget: String
    
    /// Start date when banner should be displayed
    public let startDate: Date
    
    /// End date when banner should stop being displayed
    public let endDate: Date
    
    /// Status of the banner
    public let status: String
    
    /// Image URL for the banner
    public let imageUrl: URL?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Banner title
    ///   - subtitle: Optional subtitle
    ///   - actionType: Type of action when banner is tapped
    ///   - actionTarget: Target URL or deep link for the action
    ///   - startDate: Start date when banner should be displayed
    ///   - endDate: End date when banner should stop being displayed
    ///   - status: Status of the banner
    ///   - imageUrl: Image URL for the banner
    public init(
        id: Int,
        title: String,
        subtitle: String?,
        actionType: String,
        actionTarget: String,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?
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
    }
} 