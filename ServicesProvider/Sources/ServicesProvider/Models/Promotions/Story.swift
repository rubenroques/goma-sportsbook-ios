//
//  Story.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Ephemeral promotional story (similar to social media stories)
public struct Story: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// Story title
    public let title: String
    
    /// Story content (may contain HTML)
    public let content: String
    
    /// Type of action when story is tapped
    public let actionType: String
    
    /// Target URL or deep link for the action
    public let actionTarget: String
    
    /// Start date when story should be displayed
    public let startDate: Date
    
    /// End date when story should stop being displayed
    public let endDate: Date
    
    /// Status of the story
    public let status: String
    
    /// Image URL for the story
    public let imageUrl: URL?
    
    /// Duration in seconds for automatic progression
    public let duration: Int
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Story title
    ///   - content: Story content (may contain HTML)
    ///   - actionType: Type of action when story is tapped
    ///   - actionTarget: Target URL or deep link for the action
    ///   - startDate: Start date when story should be displayed
    ///   - endDate: End date when story should stop being displayed
    ///   - status: Status of the story
    ///   - imageUrl: Image URL for the story
    ///   - duration: Duration in seconds for automatic progression
    public init(
        id: Int,
        title: String,
        content: String,
        actionType: String,
        actionTarget: String,
        startDate: Date,
        endDate: Date,
        status: String,
        imageUrl: URL?,
        duration: Int
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.actionType = actionType
        self.actionTarget = actionTarget
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
        self.duration = duration
    }
} 