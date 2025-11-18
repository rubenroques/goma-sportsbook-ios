//
//  PerformanceTracker.swift
//  GomaPerformanceKit
//
//  Main singleton for performance tracking
//

import Foundation

/// Central performance tracking singleton
/// Thread-safe, destination-based performance monitoring system
public final class PerformanceTracker {

    // MARK: - Singleton

    public static let shared = PerformanceTracker()

    // MARK: - Properties

    private var destinations: [PerformanceDestination] = []
    private var pendingSessions: [String: PendingSession] = [:]
    private var inMemoryCache: [PerformanceEntry] = []
    private var deviceContext: DeviceContext?
    private var userID: String?
    private var enabled: Bool = false

    private let queue = DispatchQueue(label: "com.goma.performance", qos: .utility)
    private let maxCacheSize = 1000

    // MARK: - Initialization

    private init() {
        // Private initializer for singleton
        setupCleanupTimer()
    }

    // MARK: - Configuration

    /// Configure the tracker with device context and optional user ID
    /// - Parameters:
    ///   - deviceContext: Static device and app information
    ///   - userID: Optional user ID (hashed, can be nil)
    public func configure(deviceContext: DeviceContext, userID: String? = nil) {
        queue.async { [weak self] in
            self?.deviceContext = deviceContext
            self?.userID = userID
        }
    }

    /// Update user ID (e.g., on login/logout)
    /// - Parameter userID: New user ID (hashed, nil for logged out)
    public func updateUserID(_ userID: String?) {
        queue.async { [weak self] in
            self?.userID = userID
        }
    }

    /// Enable performance tracking
    public func enable() {
        queue.async { [weak self] in
            self?.enabled = true
        }
    }

    /// Disable performance tracking
    public func disable() {
        queue.async { [weak self] in
            self?.enabled = false
        }
    }

    /// Check if tracking is enabled
    public var isEnabled: Bool {
        var result = false
        queue.sync {
            result = enabled
        }
        return result
    }

    // MARK: - Destination Management

    /// Add a performance destination
    /// - Parameter destination: Destination to add (console, file, analytics, etc.)
    public func addDestination(_ destination: PerformanceDestination) {
        queue.async { [weak self] in
            self?.destinations.append(destination)
        }
    }

    /// Remove a specific destination
    /// - Parameter destination: Destination to remove
    public func removeDestination(_ destination: PerformanceDestination) {
        queue.async { [weak self] in
            self?.destinations.removeAll { $0 === destination }
        }
    }

    /// Remove all destinations
    public func removeAllDestinations() {
        queue.async { [weak self] in
            self?.destinations.removeAll()
        }
    }

    // MARK: - Tracking

    /// Start tracking a performance operation
    /// - Parameters:
    ///   - feature: Business feature being measured
    ///   - layer: Technical layer being measured
    ///   - metadata: Optional metadata (URLs, params, etc.)
    public func start(
        feature: PerformanceFeature,
        layer: PerformanceLayer,
        metadata: [String: String] = [:]
    ) {
        queue.async { [weak self] in
            guard let self = self, self.enabled else { return }

            let key = self.generateKey(feature: feature, layer: layer)
            let session = PendingSession(
                feature: feature,
                layer: layer,
                startTime: Date(),
                metadata: metadata
            )

            self.pendingSessions[key] = session
        }
    }

    /// End tracking a performance operation
    /// - Parameters:
    ///   - feature: Business feature being measured (must match start)
    ///   - layer: Technical layer being measured (must match start)
    ///   - metadata: Optional metadata (status, errors, etc.)
    public func end(
        feature: PerformanceFeature,
        layer: PerformanceLayer,
        metadata: [String: String] = [:]
    ) {
        queue.async { [weak self] in
            guard let self = self, self.enabled else { return }

            // Find oldest matching session (FIFO)
            let prefix = "\(feature.rawValue)_\(layer.rawValue)_"
            let matchingKey = self.pendingSessions.keys
                .filter { $0.hasPrefix(prefix) }
                .sorted()
                .first

            guard let key = matchingKey,
                  let session = self.pendingSessions[key] else {
                print("[Performance] Warning: end() called for \(feature.rawValue).\(layer.rawValue) without matching start()")
                return
            }

            // Remove from pending
            self.pendingSessions.removeValue(forKey: key)

            // Create entry
            guard let context = self.deviceContext else {
                print("[Performance] Warning: DeviceContext not configured")
                return
            }

            // Merge metadata from start and end
            var combinedMetadata = session.startMetadata
            for (key, value) in metadata {
                combinedMetadata[key] = value
            }

            let entry = PerformanceEntry(
                id: key,
                feature: feature,
                layer: layer,
                startTime: session.startTime,
                endTime: Date(),
                metadata: combinedMetadata,
                context: context,
                userID: self.userID
            )

            // Store in cache
            self.addToCache(entry)

            // Send to destinations
            self.sendToDestinations(entry)
        }
    }

    // MARK: - Querying

    /// Get all logged performance entries
    /// - Returns: Array of performance entries
    public func getAllLogs() -> [PerformanceEntry] {
        var result: [PerformanceEntry] = []
        queue.sync {
            result = inMemoryCache
        }
        return result
    }

    /// Get performance entries for a specific feature
    /// - Parameter feature: Feature to filter by
    /// - Returns: Filtered array of performance entries
    public func getLogs(feature: PerformanceFeature) -> [PerformanceEntry] {
        var result: [PerformanceEntry] = []
        queue.sync {
            result = inMemoryCache.filter { $0.feature == feature }
        }
        return result
    }

    /// Get performance entries for a specific layer
    /// - Parameter layer: Layer to filter by
    /// - Returns: Filtered array of performance entries
    public func getLogs(layer: PerformanceLayer) -> [PerformanceEntry] {
        var result: [PerformanceEntry] = []
        queue.sync {
            result = inMemoryCache.filter { $0.layer == layer }
        }
        return result
    }

    /// Get performance entries for a specific feature and layer
    /// - Parameters:
    ///   - feature: Feature to filter by
    ///   - layer: Layer to filter by
    /// - Returns: Filtered array of performance entries
    public func getLogs(feature: PerformanceFeature, layer: PerformanceLayer) -> [PerformanceEntry] {
        var result: [PerformanceEntry] = []
        queue.sync {
            result = inMemoryCache.filter { $0.feature == feature && $0.layer == layer }
        }
        return result
    }

    // MARK: - Manual Flush

    /// Manually flush all destinations
    /// Useful before app termination or for testing
    public func flush() {
        queue.async { [weak self] in
            guard let self = self else { return }
            for destination in self.destinations {
                destination.flush()
            }
        }
    }

    // MARK: - Private Helpers

    private func generateKey(feature: PerformanceFeature, layer: PerformanceLayer) -> String {
        let timestamp = Date().timeIntervalSince1970
        return "\(feature.rawValue)_\(layer.rawValue)_\(timestamp)"
    }

    private func addToCache(_ entry: PerformanceEntry) {
        inMemoryCache.append(entry)

        // Maintain bounded cache size
        if inMemoryCache.count > maxCacheSize {
            inMemoryCache.removeFirst(inMemoryCache.count - maxCacheSize)
        }
    }

    private func sendToDestinations(_ entry: PerformanceEntry) {
        for destination in destinations {
            // Apply filter if present
            if let filter = destination.filter, !filter(entry) {
                continue
            }

            destination.log(entry: entry)
        }
    }

    private func setupCleanupTimer() {
        // Clean up expired sessions every minute
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.cleanupExpiredSessions()
        }
    }

    private func cleanupExpiredSessions() {
        queue.async { [weak self] in
            guard let self = self else { return }

            let expiredKeys = self.pendingSessions
                .filter { $0.value.isExpired }
                .map { $0.key }

            for key in expiredKeys {
                self.pendingSessions.removeValue(forKey: key)
                print("[Performance] Warning: Session expired without end(): \(key)")
            }
        }
    }
}
