//
//  ScrollPositionCoordinator.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - ScrollPositionCoordinator
class ScrollPositionCoordinator {
    
    private var currentScrollOffset: CGPoint = .zero
    private var subscribers: [WeakScrollSubscriber] = []

    private struct WeakScrollSubscriber {
        weak var viewModel: MarketGroupCardsViewModel?
    }

    func addSubscriber(_ viewModel: MarketGroupCardsViewModel) {
        // Remove any existing reference to this viewModel
        subscribers.removeAll { $0.viewModel == nil || $0.viewModel === viewModel }

        // Add new subscriber
        subscribers.append(WeakScrollSubscriber(viewModel: viewModel))

        // Apply current scroll position to new subscriber
        viewModel.setScrollPosition(currentScrollOffset)
    }

    func removeSubscriber(_ viewModel: MarketGroupCardsViewModel) {
        subscribers.removeAll { $0.viewModel === viewModel }
    }

    func updateScrollPosition(_ offset: CGPoint, from sourceViewModel: MarketGroupCardsViewModel?) {
        currentScrollOffset = offset

        // Update all other subscribers (except the source)
        for subscriber in subscribers {
            guard let viewModel = subscriber.viewModel,
                  viewModel !== sourceViewModel else { continue }

            viewModel.setScrollPosition(offset)
        }

        // Clean up nil references
        subscribers.removeAll { $0.viewModel == nil }
    }

    func getCurrentScrollPosition() -> CGPoint {
        return currentScrollOffset
    }
}

