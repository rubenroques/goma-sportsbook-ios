//
//  BonusTypeMapper.swift
//  Sportsbook
//
//  Created by André Lascas on 05/04/2023.
//

import Foundation

enum BonusTypeMapper {

    case active
    case queued
    case optedIn
    case expired
    case cancelled

    init?(bonusType: String) {

        switch bonusType {
        case "ACTIVE": self = .active
        case "QUEUED": self = .queued
        case "OPTED_IN": self = .optedIn
        case "EXPIRED": self = .expired
        case "CANCELED": self = .cancelled
        default: return nil
        }
    }

    var bonusName: String {
        switch self {
        case .active: return localized("active")
        case .queued: return localized("queued")
        case .optedIn: return localized("opted_in")
        case .expired: return localized("expired")
        case .cancelled: return localized("cancelled")
        }
    }
}
