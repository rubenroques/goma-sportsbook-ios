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
        // return self.featuredTip.username
        return "USERNAME"
    }

    func getUserId() -> String {
        //return self.featuredTip.userId ?? ""
        return ""
    }

    func getTotalOdds() -> String {
//        let oddFormatted = OddFormatter.formatOdd(withValue: self.featuredTip.totalOdds)
//        return "\(oddFormatted)"
        return "-.--"
    }

    func getNumberSelections() -> String {
        if let numberSelections = self.featuredTip.selections?.count {
            return "\(numberSelections)"
        }

        return ""
    }

    func getOMBetId() -> String {
        return self.featuredTip.betId ?? ""
    }

    func hasFollowEnabled() -> Bool {

        return false
    }
}
