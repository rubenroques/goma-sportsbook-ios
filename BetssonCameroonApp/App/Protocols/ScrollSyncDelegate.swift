//
//  ScrollSyncDelegate.swift
//  Sportsbook
//
//  Created by Complex Scroll Refactor
//

import UIKit

// MARK: - ScrollSyncDelegate
protocol ScrollSyncDelegate: AnyObject {
    func didScroll(to offset: CGPoint, from controller: MarketGroupCardsViewController)
}