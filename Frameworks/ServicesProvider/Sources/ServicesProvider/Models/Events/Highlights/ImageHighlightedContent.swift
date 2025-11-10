//
//  ImageHighlightedContent.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

// Generic wrapper for any content that needs to be highlighted with an image
public typealias ImageHighlightedContents<T> = [ImageHighlightedContent<T>] where T: Codable, T: Hashable, T: Identifiable, T.ID == String

public class ImageHighlightedContent<T>: Codable, Hashable, Identifiable where T: Codable, T: Hashable, T: Identifiable, T.ID == String {
    public var content: T
    public var promotedChildCount: Int
    public var imageURL: String?

    // Forward the ID from the wrapped content
    public var id: String {
        return content.id
    }

    public init(content: T, promotedChildCount: Int, imageURL: String?) {
        self.content = content
        self.promotedChildCount = promotedChildCount
        self.imageURL = imageURL
    }

    public static func == (lhs: ImageHighlightedContent<T>, rhs: ImageHighlightedContent<T>) -> Bool {
        return lhs.content == rhs.content &&
               lhs.promotedChildCount == rhs.promotedChildCount &&
               lhs.imageURL == rhs.imageURL
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(promotedChildCount)
        hasher.combine(imageURL ?? "")
    }
}
