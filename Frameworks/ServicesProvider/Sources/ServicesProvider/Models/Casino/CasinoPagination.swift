//
//  CasinoPagination.swift
//  ServicesProvider
//
//  Created by Claude on 29/01/2025.
//

import Foundation

/// Represents pagination information for casino API responses
public struct CasinoPaginationInfo: Codable, Hashable {
    
    /// URL for the first page
    public let first: String?
    
    /// URL for the next page (nil if no more pages)
    public let next: String?
    
    /// URL for the previous page (nil if on first page)
    public let previous: String?
    
    /// URL for the last page
    public let last: String?
    
    public init(first: String? = nil, next: String? = nil, previous: String? = nil, last: String? = nil) {
        self.first = first
        self.next = next
        self.previous = previous
        self.last = last
    }
}

/// Generic paginated response structure for casino APIs
public struct CasinoPaginatedResponse<T: Codable>: Codable {
    
    /// Number of items in current response
    public let count: Int
    
    /// Total number of items available
    public let total: Int
    
    /// Array of items
    public let items: [T]
    
    /// Pagination information
    public let pagination: CasinoPaginationInfo?
    
    public init(count: Int, total: Int, items: [T], pagination: CasinoPaginationInfo? = nil) {
        self.count = count
        self.total = total
        self.items = items
        self.pagination = pagination
    }
}

/// Computed properties for pagination logic
public extension CasinoPaginatedResponse {
    
    /// Whether more items are available
    var hasMore: Bool {
        return pagination?.next != nil
    }
    
    /// Whether this is the first page
    var isFirstPage: Bool {
        return pagination?.previous == nil
    }
    
    /// Whether this is the last page
    var isLastPage: Bool {
        return pagination?.next == nil
    }
}

/// Pagination parameters for API requests
public struct CasinoPaginationParams {
    
    /// Starting offset for pagination
    public let offset: Int
    
    /// Number of items to fetch
    public let limit: Int
    
    public init(offset: Int = 0, limit: Int = 10) {
        self.offset = offset
        self.limit = limit
    }
    
    /// Calculate if there are more items based on current response
    public func hasMore(currentCount: Int, total: Int) -> Bool {
        return (offset + currentCount) < total
    }
    
    /// Get parameters for the next page
    public func nextPage() -> CasinoPaginationParams {
        return CasinoPaginationParams(offset: offset + limit, limit: limit)
    }
    
    /// Get parameters for the previous page
    public func previousPage() -> CasinoPaginationParams {
        let newOffset = max(0, offset - limit)
        return CasinoPaginationParams(offset: newOffset, limit: limit)
    }
}