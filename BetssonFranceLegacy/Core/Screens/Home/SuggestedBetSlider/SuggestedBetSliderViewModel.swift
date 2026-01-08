//
//  SuggestedBetSliderViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class SuggestedBetSliderViewModel {

    private enum DataType {
        case featuredTips([FeaturedTip])
        case suggestedBetslips([SuggestedBetslip])
    }
    
    private var dataType: DataType

    private var suggestedBetCardCacheViewModel: [String: SuggestedBetCardViewModel] = [:]
    private var startIndex: Int
    
    private var cancellables = Set<AnyCancellable>()

    var initialIndex: Int {
        return self.startIndex
    }

    init(featuredTips: [FeaturedTip], startIndex: Int) {
        self.dataType = .featuredTips(featuredTips)
        self.startIndex = startIndex
    }
    
    init(suggestedBetslip: [SuggestedBetslip], startIndex: Int) {
        self.dataType = .suggestedBetslips(suggestedBetslip)
        self.startIndex = startIndex
    }
    
    func indexForItem(withId id: String) -> Int? {
        switch self.dataType {
        case .featuredTips(let featureTips):
            return featureTips.firstIndex(where: { $0.betId == id })
        case .suggestedBetslips(let suggestedBetslips):
            return suggestedBetslips.firstIndex(where: { $0.id == id })
        }
    }

    func numberOfItems() -> Int {
        switch self.dataType {
        case .featuredTips(let featureTips):
            featureTips.count
        case .suggestedBetslips(let suggestedBetslips):
            suggestedBetslips.count
        }
    }
    
    func cellViewModel(forIndex index: Int) -> SuggestedBetCardViewModel? {
        switch dataType {
        case .featuredTips(let featureTips):
            guard
                let featuredTip = featureTips[safe: index]
            else {
                return nil
            }

            let tipId = featuredTip.betId

            if let featuredTipCollectionViewModel = suggestedBetCardCacheViewModel[tipId] {
                return featuredTipCollectionViewModel
            }
            else {
                let featuredTipCollectionViewModel = SuggestedBetCardViewModel(featuredTip: featuredTip,
                                                                                    sizeType: .fullscreen)
                self.suggestedBetCardCacheViewModel[tipId] = featuredTipCollectionViewModel
                return featuredTipCollectionViewModel
            }
        case .suggestedBetslips(let suggestedBetslips):
            guard
                let suggestedBetslip = suggestedBetslips[safe: index]
            else {
                return nil
            }

            if let featuredTipCollectionViewModel = suggestedBetCardCacheViewModel[suggestedBetslip.id] {
                return featuredTipCollectionViewModel
            }
            else {
                let featuredTipCollectionViewModel = SuggestedBetCardViewModel(suggestedBetslip: suggestedBetslip,
                                                                                    sizeType: .fullscreen)
                self.suggestedBetCardCacheViewModel[suggestedBetslip.id] = featuredTipCollectionViewModel
                return featuredTipCollectionViewModel
            }
        }
        
    }

}
