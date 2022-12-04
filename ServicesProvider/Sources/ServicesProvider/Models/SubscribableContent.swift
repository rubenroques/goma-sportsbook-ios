//
//  File.swift
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
