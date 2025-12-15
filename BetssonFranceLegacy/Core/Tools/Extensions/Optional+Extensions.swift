//
//  Optional+Extensions.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/08/2021.
//

import Foundation

extension Optional {
    var hasValue: Bool {
        switch self {
        case .none:
            return false
        case .some(_):
            return true
        }
    }

    var noValue: Bool {
        return !hasValue
    }
}
