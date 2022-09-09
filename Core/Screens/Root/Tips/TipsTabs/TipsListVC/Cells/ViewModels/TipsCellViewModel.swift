//
//  TipsCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2022.
//

import Foundation

class TipsCellViewModel {

    var featuredTip: FeaturedTip

    init(featuredTip: FeaturedTip) {
        self.featuredTip = featuredTip

    }

    func getUsername() -> String {
        return self.featuredTip.username
    }

    func getUserId() -> String {
        return self.featuredTip.userId ?? ""
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

    func getOMBetId() -> String {
        return self.featuredTip.omBetId ?? ""
    }

    func hasFollowEnabled() -> Bool {
        // TEST
        if self.featuredTip.id % 2 == 0 {
            return true
        }

        return false
    }
}
