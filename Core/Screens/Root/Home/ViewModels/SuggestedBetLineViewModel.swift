//
//  SuggestedBetLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/02/2022.
//

import Foundation

class SuggestedBetLineViewModel: NSObject {

    var suggestedBetCardSummaries: [SuggestedBetCardSummary] = []
    var suggestedBetViewModelCache: [Int: SuggestedBetViewModel] = [:]

    init(suggestedBetCardSummaries: [SuggestedBetCardSummary]) {
        self.suggestedBetCardSummaries = suggestedBetCardSummaries
    }

    func numberOfItems() -> Int {
        return suggestedBetCardSummaries.count
    }

    func viewModel(forIndex index: Int) -> SuggestedBetViewModel? {
        guard
            let suggestedBetCardSummaries = self.suggestedBetCardSummaries[safe: index]
        else {
            return nil
        }

        let betHash = suggestedBetCardSummaries.hashValue

        if let suggestedBetViewModel = suggestedBetViewModelCache[betHash] {
            return suggestedBetViewModel
        }
        else {
            let suggestedBetViewModel = SuggestedBetViewModel(suggestedBetCardSummary: suggestedBetCardSummaries)
            self.suggestedBetViewModelCache[betHash] = suggestedBetViewModel
            return suggestedBetViewModel
        }
    }

}

