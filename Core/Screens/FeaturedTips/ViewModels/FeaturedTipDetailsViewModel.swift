//
//  FeaturedTipDetailsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class FeaturedTipDetailsViewModel {

    var featuredTip: FeaturedTip

    init(featuredTip: FeaturedTip) {
        self.featuredTip = featuredTip
    }

    func getUsername() -> String {
        return self.featuredTip.username
    }

    func getTotalOdds() -> String {
        if let oddsDouble = Double(self.featuredTip.totalOdds) {
            let oddFormatted = OddFormatter.formatOdd(withValue: oddsDouble)
            return "\(oddFormatted)"
        }
        return ""
    }

    func getNumberSelections() -> String {
        if let numberSelections = self.featuredTip.selections?.count {
            return "\(numberSelections)"
        }

        return ""
    }
}
