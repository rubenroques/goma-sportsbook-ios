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
        currencyFormatter.roundingMode = .halfUp
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
    
    func currencyTypeWithSeparatorFormatting(string: String) -> String {
        // TODO: SportRadar currency
        let currencyWalletType =  Env.userSessionStore.userWalletPublisher.value?.currency
        let decimals = Set("0123456789.")
        let value = string
        var filtered = ""
        if string != "" {
            filtered = String( value.filter { decimals.contains($0)})
            
            if let number = Double(filtered) {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.groupingSeparator = " "

                if let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) {
                    filtered = formattedNumber
                    print("Formatted Number: \(formattedNumber)")
                }
                else {
                    print("Error formatting number")
                }
            }
            else {
                print("Invalid number string")
            }
            
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
    
    init?(rawValue: String) {
        switch rawValue {
        case "€":
            self = .eur
        case "$":
            self = .usd
        case "£":
            self = .gbp
        default:
            self = .eur
        }
    }
    
    var code: String {
        switch self {
        case .eur:
            return "EUR"
        case .usd:
            return "USD"
        case .gbp:
            return "GBP"
        }
    }
}
