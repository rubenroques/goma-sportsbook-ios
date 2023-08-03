//
//  FilterFavoritesValue.swift
//  Sportsbook
//
//  Created by André Lascas on 03/08/2023.
//

import Foundation

enum FilterFavoritesValue: CaseIterable {

    case time
    case higherOdds

    init?(filterIndex: Int) {

        switch filterIndex {
        case 0: self = .time
        case 1: self = .higherOdds
        default: return nil
        }

    }

    var identifier: Int {
        switch self {
        case .time:
            return 0
        case .higherOdds:
            return 1
        }
    }

    var name: String {
        switch self {
        case .time: return localized("time")
        case .higherOdds: return localized("higher_odds")
        }
    }

}
