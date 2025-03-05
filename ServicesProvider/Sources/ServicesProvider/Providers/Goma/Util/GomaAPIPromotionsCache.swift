//
//  GomaAPIPromotionsCache.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 05/03/2025.
//

import Foundation
import Combine

class GomaAPIPromotionsCache {
    
    private let queue = DispatchQueue(label: "com.goma.promotions.cache", attributes: .concurrent)
    private let cacheExpirationInterval: TimeInterval

    private struct CacheEntry<T> {
        let value: T
        let timestamp: Date
        let expirationInterval: TimeInterval

        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > expirationInterval
        }
    }

    private var homeTemplateCache: CacheEntry<GomaModels.HomeTemplate>?
    private var initialDumpCache: CacheEntry<GomaModels.InitialDump>?

    init(expirationInterval: TimeInterval = 5 * 60) {
        self.cacheExpirationInterval = expirationInterval
    }

    // MARK: - Public Methods
    func cacheInitialDump(_ dump: GomaModels.InitialDump) {
        queue.async(flags: .barrier) {
            self.initialDumpCache = CacheEntry(value: dump, timestamp: Date(), expirationInterval: self.cacheExpirationInterval)
            // Also cache the home template since it's part of the initial dump
            self.homeTemplateCache = CacheEntry(value: dump.homeTemplate, timestamp: Date(), expirationInterval: self.cacheExpirationInterval)
        }
    }

    func getCachedInitialDump() -> GomaModels.InitialDump? {
        var result: GomaModels.InitialDump?
        queue.sync {
            guard let cache = initialDumpCache, !cache.isExpired else { return }
            result = cache.value
        }
        return result
    }

    func getCachedHomeTemplate() -> GomaModels.HomeTemplate? {
        var result: GomaModels.HomeTemplate?
        queue.sync {
            guard let cache = homeTemplateCache, !cache.isExpired else { return }
            result = cache.value
        }
        return result
    }

    func clearCache() {
        queue.async(flags: .barrier) {
            self.homeTemplateCache = nil
            self.initialDumpCache = nil
        }
    }
}
