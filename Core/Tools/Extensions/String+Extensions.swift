//
//  String+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import Foundation

import UIKit

extension String {
    
    func currencyFormatting() -> String {
        let locale = Locale.current
        let decimals = Set("0123456789.")
        let value = self
        var filtered = ""
        if self != "" {
            filtered = String( value.filter { decimals.contains($0)})
            filtered = filtered.components(separatedBy: ".").prefix(2)                    .joined(separator: ".")
        }
        if let currencyString = Double(filtered) {
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            if let str = formatter.string(for: currencyString) {
                return str
            }
        }
        return ""
    }

    func currencyTypeFormatting() -> String {
        let currencyWalletType = Env.userSessionStore.userBalanceWallet.value?.currency ?? ""
        let decimals = Set("0123456789.")
        let value = self
        var filtered = ""
        if self != "" {
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
