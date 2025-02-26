//
//  AlertBanner.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Banner alert that appears at the top of the app
public struct AlertBanner: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Alert title
    public let title: String
    
    /// Alert message content
    public let content: String
    
    /// Background color in hex format (e.g. "#FF0000")
    public let backgroundColor: String
    
    /// Text color in hex format (e.g. "#FFFFFF")
    public let textColor: String
    
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
    
    /// Optional image URL for the banner
    public let imageUrl: URL?
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Alert title
    ///   - content: Alert message content
    ///   - backgroundColor: Background color in hex format
    ///   - textColor: Text color in hex format
    ///   - actionType: Type of action when banner is tapped
    ///   - actionTarget: Target URL or deep link for the action
    ///   - startDate: Start date when banner should be displayed
    ///   - endDate: End date when banner should stop being displayed
    ///   - status: Status of the banner
    ///   - imageUrl: Optional image URL for the banner
    public init(
        id: Int,
        title: String,
        content: String,
        backgroundColor: String,
        textColor: String,
        actionType: String,
        actionTarget: String,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.actionType = actionType
        self.actionTarget = actionTarget
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
    }
} 