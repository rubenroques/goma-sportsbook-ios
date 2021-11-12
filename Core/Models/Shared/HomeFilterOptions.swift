//
//  HomeFilterOptions.swift
//  Sportsbook
//
//  Created by André Lascas on 02/11/2021.
//

import Foundation
import CoreGraphics

struct HomeFilterOptions {
    let timeRange: [CGFloat]
    let defaultMarketId: Int
    let oddsRange: [CGFloat]
    let countFilters: Int

    init(timeRange: [CGFloat] = [0, 24], defaultMarketId: Int = 69, oddsRange: [CGFloat] = [1.0, 30.0], countFilters: Int = 0) {
        self.timeRange = timeRange
        self.defaultMarketId = defaultMarketId
        self.oddsRange = oddsRange
        self.countFilters = countFilters
    }
}
