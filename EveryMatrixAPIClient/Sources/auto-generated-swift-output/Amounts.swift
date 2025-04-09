import Foundation

struct Amounts: Codable {
    var created: String?
    var type: String?
    var amount: Double?
    var currency: String?
    var systemCurrencyAmount: Double?
    var currencyRateVersionCode: String?
    var operatorCurrencyAmount: Double?
    var operatorCurrency: String?

    enum CodingKeys: String, CodingKey {
        case created = "Created"
        case type = "Type"
        case amount = "Amount"
        case currency = "Currency"
        case systemCurrencyAmount = "SystemCurrencyAmount"
        case currencyRateVersionCode = "CurrencyRateVersionCode"
        case operatorCurrencyAmount = "OperatorCurrencyAmount"
        case operatorCurrency = "OperatorCurrency"
    }
}
