//
//  PerformanceEntry.swift
//  GomaPerformanceKit
//
//  Represents a completed performance measurement
//

import Foundation

/// A completed performance measurement with timing and metadata
public struct PerformanceEntry: Codable, Equatable {
    /// Unique identifier (auto-generated: feature_layer_timestamp)
    public let id: String

    /// The business feature being measured
    public let feature: PerformanceFeature

    /// The technical layer being measured
    public let layer: PerformanceLayer

    /// When the operation started
    public let startTime: Date

    /// When the operation completed
    public let endTime: Date

    /// Duration in seconds
    public let duration: TimeInterval

    /// Custom metadata (URLs, status codes, errors, etc.)
    public let metadata: [String: String]

    /// Static device and app context
    public let context: DeviceContext

    /// Optional user ID (hashed, nil if logged out)
    public let userID: String?

    // MARK: - Computed Properties

    /// Duration formatted in milliseconds
    public var durationInMilliseconds: Double {
        duration * 1000
    }

    /// Formatted duration string (e.g., "1.234s" or "234.5ms")
    public var durationFormatted: String {
        if duration >= 1.0 {
            return String(format: "%.3fs", duration)
        } else {
            return String(format: "%.1fms", durationInMilliseconds)
        }
    }

    /// ISO8601 formatted start time
    public var startTimeISO8601: String {
        ISO8601DateFormatter().string(from: startTime)
    }

    /// ISO8601 formatted end time
    public var endTimeISO8601: String {
        ISO8601DateFormatter().string(from: endTime)
    }

    // MARK: - Initialization

    public init(
        id: String,
        feature: PerformanceFeature,
        layer: PerformanceLayer,
        startTime: Date,
        endTime: Date,
        metadata: [String: String],
        context: DeviceContext,
        userID: String?
    ) {
        self.id = id
        self.feature = feature
        self.layer = layer
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.metadata = metadata
        self.context = context
        self.userID = userID
    }
}

// MARK: - Identifiable

extension PerformanceEntry: Identifiable {}
