//
//  CasinoCacheConfiguration.swift
//  BetssonCameroonApp
//
//  Created by Claude Code on 25/11/2025.
//

import Foundation

/// Configuration for casino cache behavior including TTL and pagination limits
struct CasinoCacheConfiguration {
    /// Time-to-live for cached data (in seconds)
    /// Purpose: Cache provides instant UI while background refresh happens
    /// Aggressive refresh strategy ensures data is never more than 10min old
    let ttl: TimeInterval

    /// Maximum number of game list pages to cache per category
    let maxCachedPagesPerCategory: Int

    /// Whether to use bundled data as fallback
    let useBundledDataFallback: Bool

    /// Default configuration for production use
    /// 10 minute TTL: Cache shows instantly, background refresh ensures freshness
    static let `default` = CasinoCacheConfiguration(
        ttl: 60 * 3,  // 10 minutes
        maxCachedPagesPerCategory: 5,
        useBundledDataFallback: true
    )

    /// Debug configuration with very short TTL for testing stale cache behavior
    static let debug = CasinoCacheConfiguration(
        ttl: 60 * 1,  // 1 minute
        maxCachedPagesPerCategory: 3,
        useBundledDataFallback: true
    )
}
