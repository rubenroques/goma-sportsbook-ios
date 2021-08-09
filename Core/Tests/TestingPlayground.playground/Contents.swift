import UIKit

/*
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
                return "MXN"
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
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: NSNumber(value:number))
    }

}


Internationalization.format(number: 125.50, currency: .peso)
Internationalization.format(number: 125.50, currency: .bolivar)
Internationalization.format(number: 125.50, currency: .euro)
Internationalization.format(number: 125.50, currency: .dollar)
Internationalization.format(number: 125.50, currency: .real)
*/



var greeting = "Hello, playground"

protocol FeatureFlags {
    static var low: Int { get }
    static var high: Int { get }
    //static var mid: Int { get }
}

protocol Target {
    associatedtype Flags: FeatureFlags
    static var step: Int { get }
    static var flags: Flags.Type { get }
}



struct TargetFeaureFlags: FeatureFlags {
    static var low: Int = 10
    static var high: Int = 100
}


struct ClientFoo: Target {
    typealias Flags = TargetFeaureFlags

    static var step: Int { 100 }

    static var flags: TargetFeaureFlags.Type {
        return TargetFeaureFlags.self
    }
}

struct ClientBar: Target {
    typealias Flags = TargetFeaureFlags

    static var step: Int { 12}

    static var flags: TargetFeaureFlags.Type { TargetFeaureFlags.self }
}

var fooLow = ClientFoo.flags.low
fooLow
