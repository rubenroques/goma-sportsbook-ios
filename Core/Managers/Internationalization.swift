//
//  Internationalization .swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/07/2021.
//

import Foundation

struct Internationalization {

    enum Currency {

        case euro
        case dollar
        case real
        case peso
        case bolivar

        var symbol: String {
            switch self {
            case .euro:
                return "€"
            case .dollar:
                return "$"
            case .real:
                return "R$"
            case .peso:
                return "$"
            case .bolivar:
                return "Bs"
            }
        }

        var ISOCode: String {
            switch self {
            case .euro:
                return "EUR"
            case .dollar:
                return "USD"
            case .real:
                return "BRL"
            case .peso:
                return "ARS"
            case .bolivar:
                return "VEF"
            }
        }
    }


    static func format(number: Int, currency: Currency) -> String? {
        self.format(number: Double(number), currency: currency)
    }
    
    static func format(number: Float, currency: Currency) -> String? {
        self.format(number: Double(number), currency: currency)
    }
    
    static func format(number: Double, currency: Currency) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.ISOCode
        return formatter.string(from: NSNumber(value:number))
    }
    
}
