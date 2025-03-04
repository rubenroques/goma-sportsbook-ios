//
//  NewsItem.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// News article
public typealias NewsItems = [NewsItem]
///
public struct NewsItem: Codable, Identifiable, Equatable, Hashable {
    /// Unique identifier
    public let id: String

    /// News article title
    public let title: String

    /// Optional subtitle
    public let subtitle: String?

    /// Article content
    public let content: String

    /// Article author
    public let author: String?

    /// Date when the article was published
    public let publishedDate: Date?

    /// Status of the article
    public let status: String?

    /// Featured image URL for the article
    public let imageUrl: String?

    /// Tags associated with the article
    public let tags: [String]

    public init(id: String,
                title: String,
                subtitle: String?,
                content: String,
                author: String?,
                publishedDate: Date?,
                status: String?,
                imageUrl: String?,
                tags: [String]) {
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
