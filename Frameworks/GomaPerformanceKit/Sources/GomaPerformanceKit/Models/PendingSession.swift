//
//  PendingSession.swift
//  GomaPerformanceKit
//
//  Represents an in-flight performance measurement
//

import Foundation

/// Represents a performance measurement that has started but not yet completed
internal struct PendingSession {
    /// The business feature being measured
    let feature: PerformanceFeature

    /// The technical layer being measured
    let layer: PerformanceLayer

    /// When the operation started
    let startTime: Date

    /// Metadata from start() call
    let startMetadata: [String: String]

    /// When this session was created (for timeout detection)
    let createdAt: Date

    /// Session timeout duration (5 minutes)
    static let timeoutInterval: TimeInterval = 300

    // MARK: - Initialization

    init(
        feature: PerformanceFeature,
        layer: PerformanceLayer,
        startTime: Date,
        metadata: [String: String]
    ) {
        self.feature = feature
        self.layer = layer
        self.startTime = startTime
        self.startMetadata = metadata
        self.createdAt = Date()
    }

    // MARK: - Timeout Detection

    /// Check if this session has expired without being completed
    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > Self.timeoutInterval
    }

    /// Time remaining until timeout
    var timeUntilTimeout: TimeInterval {
        max(0, Self.timeoutInterval - Date().timeIntervalSince(createdAt))
    }
}
