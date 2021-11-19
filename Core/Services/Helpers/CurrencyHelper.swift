//
//  CurrencyHelper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import Foundation

struct CurrencyFormater {

    static var defaultFormat: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "EUR"
        return currencyFormatter
    }()

}
