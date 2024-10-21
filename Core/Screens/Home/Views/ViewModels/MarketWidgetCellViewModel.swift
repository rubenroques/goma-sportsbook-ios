//
//  MarketWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2024.
//

import Foundation

class MarketWidgetCellViewModel {

    private var highlightedMarket: HighlightedContent<Market>

    init(highlightedMarket: HighlightedContent<Market>) {
        self.highlightedMarket = highlightedMarket
    }

}
