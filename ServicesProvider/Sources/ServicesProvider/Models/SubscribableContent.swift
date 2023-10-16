//
//  SubscribableContent.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum SubscribableContent<T> {
    case connected(subscription: Subscription)
    case contentUpdate(content: T)
    case disconnected
}

extension SubscribableContent: Equatable where T: Equatable {
    public static func == (lhs: SubscribableContent<T>, rhs: SubscribableContent<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.connected(lhsSubscription), .connected(rhsSubscription)):
            return lhsSubscription == rhsSubscription
        case let (.contentUpdate(lhsValue), .contentUpdate(rhsValue)):
            return lhsValue == rhsValue
        case (.disconnected, .disconnected):
            return true
        default:
            return false
        }
    }
}
