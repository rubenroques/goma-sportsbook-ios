//
//  FeaturedTipCollectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2022.
//

import Foundation
import Combine

class FeaturedTipCollectionViewModel {

    var featuredTip: FeaturedTip

    init(featuredTip: FeaturedTip) {
        self.featuredTip = featuredTip

    }

    func getUsername() -> String {
        return self.featuredTip.username
    }

    func getTotalOdds() -> String {
        let oddFormatted = OddFormatter.formatOdd(withValue: self.featuredTip.totalOdds)
        return "\(oddFormatted)"
    }

    func getNumberSelections() -> String {
        if let numberSelections = self.featuredTip.betSelections?.count {
            return "\(numberSelections)"
        }

        return ""
    }
}
