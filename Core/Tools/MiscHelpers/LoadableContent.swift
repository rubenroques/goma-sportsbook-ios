//
//  LoadState.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

enum LoadableContent<T> {
    case idle
    case loading
    case loaded(T)
    case failed
}

extension LoadableContent: Equatable where T: Equatable {
    static func == (lhs: LoadableContent<T>, rhs: LoadableContent<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.failed, .failed):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
