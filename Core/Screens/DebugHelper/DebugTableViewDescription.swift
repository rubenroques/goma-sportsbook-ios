//
//  DebugTableViewDescription.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/08/2021.
//

import UIKit

enum DebugTableViewDescription: TableViewDescriptor {

    case production
    case development
    case clearUserDefaults
    case logoutUser
    case globalLogs
    case networking

    static var layout: [[DebugTableViewDescription]] {
        return [
            [
                .production,
                .development
            ],
            [
                .clearUserDefaults,
                .logoutUser
            ],
            [
                .networking,
                .globalLogs
            ]
        ]
    }

    static var sectionHeaders: [Int: String]? = [
        0: "Environment",
        1: "Utilities",
        2: "Logs"
    ]
    static var sectionFooters: [Int: String]? = [:]

    var style: UITableViewCell.CellStyle {
        return .subtitle
    }

    var icon: UIImage? {
        return nil
    }

    var label: String {
        switch self {
        case .production: return "Production"
        case .development: return "Development"

        case .clearUserDefaults: return "Clear user defaults and caches"
        case .logoutUser: return "Logout User"

        case .globalLogs: return "Verbose Logs"
        case .networking: return "Networking"
        }
    }

    public var detailLabel: String? {
        switch self {
        case .globalLogs: return "View debug app logs"
        case .networking: return "View all network requests from this session"
        default:
            return nil
        }
    }
}
