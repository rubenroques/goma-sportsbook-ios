//
//  TipsSliderViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class TipsSliderViewModel {

    var featuredTips: [FeaturedTip]
    private var featuredTipCollectionCacheViewModel: [String: FeaturedTipCollectionViewModel] = [:]
    private var startIndex: Int
    private var cancellables = Set<AnyCancellable>()

    init(featuredTips: [FeaturedTip], startIndex: Int) {
        self.featuredTips = featuredTips
        self.startIndex = startIndex

    }

    func initialIndex() -> Int {
        return self.startIndex
    }

    func numberOfItems() -> Int {
        return featuredTips.count
    }

    func viewModel(forIndex index: Int) -> FeaturedTipCollectionViewModel? {
        guard
            let featuredTip = self.featuredTips[safe: index]
        else {
            return nil
        }

        let tipId = featuredTip.betId

        if let featuredTipCollectionViewModel = featuredTipCollectionCacheViewModel[tipId] {
            return featuredTipCollectionViewModel
        }
        else {
            let featuredTipCollectionViewModel = FeaturedTipCollectionViewModel(featuredTip: featuredTip, sizeType: .fullscreen)
            self.featuredTipCollectionCacheViewModel[tipId] = featuredTipCollectionViewModel
            return featuredTipCollectionViewModel
        }
    }

}
