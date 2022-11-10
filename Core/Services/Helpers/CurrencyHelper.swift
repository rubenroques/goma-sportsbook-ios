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

    func currencyTypeFormatting(string: String) -> String {
        // TODO: SportRadar currency
        let currencyWalletType =  Env.userSessionStore.userWalletPublisher.value?.currency
        let decimals = Set("0123456789.")
        let value = string
        var filtered = ""
        if string != "" {
            filtered = String( value.filter { decimals.contains($0)})
            var currencyType = ""
            if currencyWalletType == "EUR" {
                currencyType = CurrencyType.eur.rawValue
            }
            else if currencyWalletType == "USD" {
                currencyType = CurrencyType.usd.rawValue
            }
            else if currencyWalletType == "GBP" {
                currencyType = CurrencyType.gbp.rawValue
            }
            filtered = "\(currencyType) \(filtered)"
            return filtered
        }

        return ""
    }

}

enum CurrencyType: String {
    case eur = "€"
    case usd = "$"
    case gbp = "£"
}
