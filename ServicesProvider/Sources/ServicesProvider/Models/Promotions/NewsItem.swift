//
//  NewsItem.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// News article
public struct NewsItem: Identifiable, Equatable {
    /// Unique identifier
    public let id: Int
    
    /// News article title
    public let title: String
    
    /// Optional subtitle
    public let subtitle: String?
    
    /// Article content (may contain HTML)
    public let content: String
    
    /// Article author
    public let author: String
    
    /// Date when the article was published
    public let publishedDate: Date
    
    /// Status of the article
    public let status: String
    
    /// Featured image URL for the article
    public let imageUrl: URL?
    
    /// Tags associated with the article
    public let tags: [String]
    
    /// Public initializer
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: News article title
    ///   - subtitle: Optional subtitle
    ///   - content: Article content (may contain HTML)
    ///   - author: Article author
    ///   - publishedDate: Date when the article was published
    ///   - status: Status of the article
    ///   - imageUrl: Featured image URL for the article
    ///   - tags: Tags associated with the article
    public init(
        id: Int,
        title: String,
        subtitle: String?,
        content: String,
        author: String,
        publishedDate: Date,
        status: String,
        imageUrl: URL?,
        tags: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.author = author
        self.publishedDate = publishedDate
        self.status = status
        self.imageUrl = imageUrl
        self.tags = tags
    }
} 