//
//  MyGamesTypeList.swift
//  Sportsbook
//
//  Created by André Lascas on 02/08/2023.
//

import Foundation

enum MyGamesTypeList {
    case all
    case live
    case today
    case tomorrow
    case thisWeek
    case nextWeek

    var index: Int {
        switch self {
        case .all:
            return 0
        case .live:
            return 1
        case .today:
            return 2
        case .tomorrow:
            return 3
        case .thisWeek:
            return 4
        case .nextWeek:
            return 5
        }
    }
}
