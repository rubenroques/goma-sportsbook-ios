//
//  HomeFilterOptions.swift
//  Sportsbook
//
//  Created by André Lascas on 02/11/2021.
//

import Foundation
import CoreGraphics

struct HomeFilterOptions: Equatable {

    let lowerBoundTimeRange: CGFloat
    let highBoundTimeRange: CGFloat
    let defaultMarket: MainMarketType?
 
    let lowerBoundOddsRange: CGFloat
    let highBoundOddsRange: CGFloat
    let countFilters: Int

    init(lowerBoundTimeRange: CGFloat = 0.0,
         highBoundTimeRange: CGFloat = 365.0,
         defaultMarket: MainMarketType? = nil,
         lowerBoundOddsRange: CGFloat = 1.0,
         highBoundOddsRange: CGFloat = 300.0,
         countFilters: Int = 0) {
        
        self.lowerBoundTimeRange = lowerBoundTimeRange
        self.highBoundTimeRange = highBoundTimeRange
        self.defaultMarket = defaultMarket
        self.lowerBoundOddsRange = lowerBoundOddsRange
        self.highBoundOddsRange = highBoundOddsRange
        self.countFilters = countFilters
    }
    
}
