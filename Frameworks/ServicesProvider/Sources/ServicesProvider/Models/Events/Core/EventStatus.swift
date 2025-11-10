//
//  EventStatus.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum EventStatus: Hashable {
    case unknown
    case notStarted
    case inProgress(String)
    case ended(String)

    public init(value: String) {
        let resultStatus: EventStatus
        switch value {
        case "not_started":
            resultStatus = .notStarted
        case "ended":
            resultStatus = .ended(value)
        default:
            resultStatus = .inProgress(value)
        }

        // Debug log for status parsing
        let statusName: String
        switch resultStatus {
        case .notStarted: statusName = "notStarted"
        case .inProgress: statusName = "inProgress"
        case .ended: statusName = "ended"
        default: statusName = "inProgress"
        }
        print("[M-STATUS] EventStatus.init | value: \"\(value)\" → .\(statusName)")

        self = resultStatus
    }

    public var isInProgress: Bool {
        switch self {
        case .inProgress:
            return true
        default:
            return false
        }
    }
}
