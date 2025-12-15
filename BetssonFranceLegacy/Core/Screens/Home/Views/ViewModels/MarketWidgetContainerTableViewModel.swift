//
//  MarketWidgetContainerTableViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2024.
//

import UIKit

class MarketWidgetContainerTableViewModel {

    static let defaultCardHeight: CGFloat = 304.0
    static let topMargin: CGFloat = 10.0
    static let leftMargin: CGFloat = 18.0

    var cardsViewModels: [MarketWidgetCellViewModel] = []

    init(cardsViewModels: [MarketWidgetCellViewModel]) {
        self.cardsViewModels = cardsViewModels
    }

    init(singleCardsViewModel: MarketWidgetCellViewModel) {
        self.cardsViewModels = [singleCardsViewModel]
    }

    var numberOfCells: Int {
        return self.cardsViewModels.count
    }

    var isScrollEnabled: Bool {
        return self.numberOfCells > 1
    }

    func maxHeightForInnerCards() -> CGFloat {
        return Self.defaultCardHeight
    }

    func heightForItem(atIndex index: Int) -> CGFloat {
        return Self.defaultCardHeight - (Self.topMargin * 2)
    }

}

