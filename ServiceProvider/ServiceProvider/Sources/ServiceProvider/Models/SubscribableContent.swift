//
//  File.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum SubscribableContent<T> {
    case connected // subscriptionIdentifier: SubscriptionIdentifier)
    case content(T)
    case disconnected
}
