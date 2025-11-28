//
//  CasinoCacheStore.swift
//  BetssonCameroonApp
//
//  Created by Claude Code on 25/11/2025.
//

import Foundation
import ServicesProvider

/// Thread-safe cache store for casino data with memory + disk persistence
final class CasinoCacheStore {

    // MARK: - Cache Result Types

    /// Represents the state and data of a cache lookup
    enum CacheResult<T> {
        case fresh(T)        // Data within TTL, use immediately
        case stale(T)        // Data expired but available, trigger refresh
        case bundled(T)      // Bundled placeholder data
        case miss            // No cached data available

        var data: T? {
            switch self {
            case .fresh(let data), .stale(let data), .bundled(let data):
                return data
            case .miss:
                return nil
            }
        }

        var needsRefresh: Bool {
            switch self {
            case .stale, .bundled, .miss:
                return true
            case .fresh:
                return false
            }
        }
    }

    // MARK: - Private Types

    /// Cache entry wrapper with metadata
    private struct CacheEntry<T: Codable>: Codable {
        let data: T
        let timestamp: Date
        let version: Int

        func isValid(ttl: TimeInterval) -> Bool {
            return Date().timeIntervalSince(timestamp) < ttl
        }

        func isStale(ttl: TimeInterval) -> Bool {
            return !isValid(ttl: ttl)
        }
    }

    /// Cache keys for different data types
    private enum CacheKey {
        static func categories(lobbyType: String) -> String {
            return "casino_categories_\(lobbyType)"
        }

        static func gameList(categoryId: String, offset: Int, lobbyType: String) -> String {
            return "casino_games_\(categoryId)_offset_\(offset)_\(lobbyType)"
        }
    }

    // MARK: - Properties

    private let configuration: CasinoCacheConfiguration
    private let queue = DispatchQueue(label: "com.betsson.casino.cache", attributes: .concurrent)

    /// Current cache version - increment to invalidate old cache
    private let currentCacheVersion = 1

    /// In-memory cache for fast access
    private var memoryCache: [String: Any] = [:]

    /// Disk cache directory
    private lazy var cacheDirectory: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheDir = documentsDirectory.appendingPathComponent("CasinoCache", isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)

        return cacheDir
    }()

    // MARK: - Initialization

    init(configuration: CasinoCacheConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public Methods - Categories Cache

    /// Get cached casino categories
    func getCachedCategories(lobbyType: String) -> CacheResult<[CasinoCategory]> {
        let cacheKey = CacheKey.categories(lobbyType: lobbyType)

        return queue.sync {
            // 1. Check memory cache first (fastest)
            if let entry = memoryCache[cacheKey] as? CacheEntry<[CasinoCategory]> {
                return evaluateCacheEntry(entry)
            }

            // 2. Check disk cache
            if let entry = loadCategoriesFromDisk(lobbyType: lobbyType) {
                // Store in memory for next time
                memoryCache[cacheKey] = entry
                return evaluateCacheEntry(entry)
            }

            // 3. Fall back to bundled data
            if configuration.useBundledDataFallback, let bundledCategories = loadBundledCategories() {
                return .bundled(bundledCategories)
            }

            // 4. Cache miss
            return .miss
        }
    }

    /// Save casino categories to cache
    func saveCachedCategories(_ categories: [CasinoCategory], lobbyType: String) {
        let cacheKey = CacheKey.categories(lobbyType: lobbyType)

        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            let entry = CacheEntry(data: categories, timestamp: Date(), version: self.currentCacheVersion)

            // Save to memory cache
            self.memoryCache[cacheKey] = entry

            // Save to disk cache
            self.saveCategoriesToDisk(entry, lobbyType: lobbyType)
        }
    }

    // MARK: - Public Methods - Game List Cache

    /// Get cached game list for a specific category and offset
    func getCachedGameList(categoryId: String, offset: Int, lobbyType: String) -> CacheResult<CasinoGamesResponse> {
        let cacheKey = CacheKey.gameList(categoryId: categoryId, offset: offset, lobbyType: lobbyType)

        return queue.sync {
            // 1. Check memory cache first (fastest)
            if let entry = memoryCache[cacheKey] as? CacheEntry<CasinoGamesResponse> {
                return evaluateCacheEntry(entry)
            }

            // 2. Check disk cache
            if let entry = loadGameListFromDisk(categoryId: categoryId, offset: offset, lobbyType: lobbyType) {
                // Store in memory for next time
                memoryCache[cacheKey] = entry
                return evaluateCacheEntry(entry)
            }

            // 3. Fall back to bundled data (only for offset 0)
            if offset == 0 && configuration.useBundledDataFallback,
               let bundledGames = loadBundledGameList(categoryId: categoryId) {
                return .bundled(bundledGames)
            }

            // 4. Cache miss
            return .miss
        }
    }

    /// Save game list to cache for a specific category and offset
    func saveCachedGameList(_ gamesResponse: CasinoGamesResponse, categoryId: String, offset: Int, lobbyType: String) {
        // Only cache within the configured page limit
        let pageIndex = offset / 10  // Assuming 10 games per page
        guard pageIndex < configuration.maxCachedPagesPerCategory else {
            return  // Don't cache beyond limit
        }

        let cacheKey = CacheKey.gameList(categoryId: categoryId, offset: offset, lobbyType: lobbyType)

        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            let entry = CacheEntry(data: gamesResponse, timestamp: Date(), version: self.currentCacheVersion)

            // Save to memory cache
            self.memoryCache[cacheKey] = entry

            // Save to disk cache
            self.saveGameListToDisk(entry, categoryId: categoryId, offset: offset, lobbyType: lobbyType)
        }
    }

    // MARK: - Public Methods - Cache Management

    /// Clear all cached data (memory + disk)
    func clearCache() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            // Clear memory cache
            self.memoryCache.removeAll()

            // Clear disk cache
            try? FileManager.default.removeItem(at: self.cacheDirectory)

            // Recreate directory
            try? FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    // MARK: - Private Methods - Cache Evaluation

    /// Evaluate cache entry and determine if fresh, stale, or invalid
    private func evaluateCacheEntry<T>(_ entry: CacheEntry<T>) -> CacheResult<T> {
        // Check version first
        guard entry.version == currentCacheVersion else {
            return .miss  // Invalid version, treat as miss
        }

        // Check TTL
        if entry.isValid(ttl: configuration.ttl) {
            return .fresh(entry.data)
        } else {
            return .stale(entry.data)
        }
    }

    // MARK: - Private Methods - Disk Persistence (Categories)

    private func loadCategoriesFromDisk(lobbyType: String) -> CacheEntry<[CasinoCategory]>? {
        let cacheKey = CacheKey.categories(lobbyType: lobbyType)
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).json")

        guard let data = try? Data(contentsOf: fileURL),
              let entry = try? JSONDecoder().decode(CacheEntry<[CasinoCategory]>.self, from: data) else {
            return nil
        }

        return entry
    }

    private func saveCategoriesToDisk(_ entry: CacheEntry<[CasinoCategory]>, lobbyType: String) {
        let cacheKey = CacheKey.categories(lobbyType: lobbyType)
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).json")

        guard let data = try? JSONEncoder().encode(entry) else {
            print("Failed to encode categories cache entry")
            return
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to write categories cache to disk: \(error)")
        }
    }

    // MARK: - Private Methods - Disk Persistence (Game Lists)

    private func loadGameListFromDisk(categoryId: String, offset: Int, lobbyType: String) -> CacheEntry<CasinoGamesResponse>? {
        let cacheKey = CacheKey.gameList(categoryId: categoryId, offset: offset, lobbyType: lobbyType)
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).json")

        guard let data = try? Data(contentsOf: fileURL),
              let entry = try? JSONDecoder().decode(CacheEntry<CasinoGamesResponse>.self, from: data) else {
            return nil
        }

        return entry
    }

    private func saveGameListToDisk(_ entry: CacheEntry<CasinoGamesResponse>, categoryId: String, offset: Int, lobbyType: String) {
        let cacheKey = CacheKey.gameList(categoryId: categoryId, offset: offset, lobbyType: lobbyType)
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).json")

        guard let data = try? JSONEncoder().encode(entry) else {
            print("Failed to encode game list cache entry for \(categoryId) offset \(offset)")
            return
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to write game list cache to disk: \(error)")
        }
    }

    // MARK: - Private Methods - Bundled Data

    /// Load bundled placeholder categories from app bundle
    private func loadBundledCategories() -> [CasinoCategory]? {
        guard let url = Bundle.main.url(forResource: "bundled_casino_categories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let categories = try? JSONDecoder().decode([CasinoCategory].self, from: data) else {
            return nil
        }
        return categories
    }

    /// Load bundled placeholder game list for a category
    private func loadBundledGameList(categoryId: String) -> CasinoGamesResponse? {
        let resourceName = "bundled_casino_games_\(categoryId)"

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let gamesResponse = try? JSONDecoder().decode(CasinoGamesResponse.self, from: data) else {
            return nil
        }
        return gamesResponse
    }
}
