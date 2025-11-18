//
//  BankingTimingMetrics.swift
//  BetssonCameroonApp
//
//  Created for timing analysis of deposit/withdraw flows
//  Tracks three distinct phases: APP, API, and WEB
//

import Foundation

enum BankingTimingPhase {
    case idle
    case appInitializing
    case apiCalling
    case webViewProvisionalLoad
    case webViewCommit
    case webViewDOMLoaded
    case webViewPollingForReady
    case webViewFullyReady
    case completed

    var displayName: String {
        switch self {
        case .idle: return "Idle"
        case .appInitializing: return "App Initializing"
        case .apiCalling: return "API Calling Backend"
        case .webViewProvisionalLoad: return "Web: Starting Load"
        case .webViewCommit: return "Web: Loading Content"
        case .webViewDOMLoaded: return "Web: DOM Loaded"
        case .webViewPollingForReady: return "Web: Waiting for Page"
        case .webViewFullyReady: return "Web: Fully Ready"
        case .completed: return "Completed"
        }
    }

    var responsibility: BankingTimingResponsibility {
        switch self {
        case .idle, .appInitializing:
            return .app
        case .apiCalling:
            return .api
        case .webViewProvisionalLoad, .webViewCommit, .webViewDOMLoaded, .webViewPollingForReady, .webViewFullyReady:
            return .webpage
        case .completed:
            return .completed
        }
    }
}

enum BankingTimingResponsibility {
    case app
    case api
    case webpage
    case completed

    var displayName: String {
        switch self {
        case .app: return "⚙️ App Processing"
        case .api: return "☁️ Backend API"
        case .webpage: return "🌐 Webpage Loading"
        case .completed: return "✅ Ready"
        }
    }

    var color: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        switch self {
        case .app: return (0.0, 0.478, 1.0)        // System Blue
        case .api: return (1.0, 0.584, 0.0)        // System Orange
        case .webpage: return (1.0, 0.271, 0.227)  // System Red
        case .completed: return (0.196, 0.843, 0.294)  // System Green
        }
    }
}

struct BankingTimingMetrics {
    let flowStartTime: Date
    var apiCallStartTime: Date?
    var apiCallEndTime: Date?
    var webViewProvisionalLoadTime: Date?
    var webViewCommitTime: Date?
    var webViewDOMLoadedTime: Date?
    var webViewFullyReadyTime: Date?

    var currentPhase: BankingTimingPhase = .idle

    init() {
        self.flowStartTime = Date()
    }

    // MARK: - Duration Calculations by Responsibility

    var appDuration: TimeInterval? {
        guard let apiStart = apiCallStartTime else {
            return nil
        }
        return apiStart.timeIntervalSince(flowStartTime)
    }

    var apiDuration: TimeInterval? {
        guard let start = apiCallStartTime, let end = apiCallEndTime else {
            return nil
        }
        return end.timeIntervalSince(start)
    }

    var webDuration: TimeInterval? {
        guard let start = webViewProvisionalLoadTime, let end = webViewFullyReadyTime else {
            return nil
        }
        return end.timeIntervalSince(start)
    }

    var totalDuration: TimeInterval? {
        guard let end = webViewFullyReadyTime else {
            return nil
        }
        return end.timeIntervalSince(flowStartTime)
    }

    func elapsedTime(from reference: Date = Date()) -> TimeInterval {
        return reference.timeIntervalSince(flowStartTime)
    }

    func currentPhaseDuration(from reference: Date = Date()) -> TimeInterval {
        let phaseStartTime: Date

        switch currentPhase {
        case .idle:
            phaseStartTime = flowStartTime
        case .appInitializing:
            phaseStartTime = flowStartTime
        case .apiCalling:
            phaseStartTime = apiCallStartTime ?? flowStartTime
        case .webViewProvisionalLoad:
            phaseStartTime = webViewProvisionalLoadTime ?? flowStartTime
        case .webViewCommit:
            phaseStartTime = webViewCommitTime ?? flowStartTime
        case .webViewDOMLoaded:
            phaseStartTime = webViewDOMLoadedTime ?? flowStartTime
        case .webViewPollingForReady, .webViewFullyReady:
            phaseStartTime = webViewDOMLoadedTime ?? flowStartTime
        case .completed:
            phaseStartTime = webViewFullyReadyTime ?? flowStartTime
        }

        return reference.timeIntervalSince(phaseStartTime)
    }

    // MARK: - Formatted Strings

    func formattedDuration(_ duration: TimeInterval?) -> String {
        guard let duration = duration else {
            return "N/A"
        }
        return String(format: "%.3fs", duration)
    }

    var formattedAppDuration: String {
        formattedDuration(appDuration)
    }

    var formattedApiDuration: String {
        formattedDuration(apiDuration)
    }

    var formattedWebDuration: String {
        formattedDuration(webDuration)
    }

    var formattedTotalDuration: String {
        formattedDuration(totalDuration)
    }

    // MARK: - Phase Updates

    mutating func startAppInitialization() {
        currentPhase = .appInitializing
    }

    mutating func startAPICall() {
        apiCallStartTime = Date()
        currentPhase = .apiCalling
    }

    mutating func endAPICall() {
        apiCallEndTime = Date()
    }

    mutating func startWebViewProvisionalLoad() {
        webViewProvisionalLoadTime = Date()
        currentPhase = .webViewProvisionalLoad
    }

    mutating func commitWebViewLoad() {
        webViewCommitTime = Date()
        currentPhase = .webViewCommit
    }

    mutating func finishWebViewDOMLoad() {
        webViewDOMLoadedTime = Date()
        currentPhase = .webViewDOMLoaded
    }

    mutating func startPollingForWebViewReady() {
        currentPhase = .webViewPollingForReady
    }

    mutating func markWebViewFullyReady() {
        webViewFullyReadyTime = Date()
        currentPhase = .webViewFullyReady
    }

    mutating func complete() {
        currentPhase = .completed
    }
}
