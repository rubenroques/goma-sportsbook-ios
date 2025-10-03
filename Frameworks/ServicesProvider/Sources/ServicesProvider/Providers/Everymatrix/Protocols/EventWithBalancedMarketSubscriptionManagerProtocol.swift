//
//  EventWithBalancedMarketSubscriptionManagerProtocol.swift
//  ServicesProvider
//
//  Created on 2025-09-30.
//

import Foundation
import Combine

/// Protocol for managing subscriptions to events with their most balanced market
///
/// The "balanced market" is determined by EveryMatrix based on the betting type and event part combination.
/// The specific market returned may change over time as odds are rebalanced.
protocol EventWithBalancedMarketSubscriptionManagerProtocol {

    /// Subscribe to event with balanced market updates
    /// - Returns: Publisher emitting Event with single balanced market in markets array
    func subscribe() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>

    /// Unsubscribe from all active subscriptions and clean up resources
    func unsubscribe()
}
