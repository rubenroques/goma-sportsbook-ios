//
//  EveryMatrix+UserWallet.swift
//  ServicesProvider
//
//  Created by André Lascas on 21/08/2025.
//

extension EveryMatrix {
    struct WalletBalance: Codable {
        let totalAmount: CurrencyAmount
        let totalCashAmount: CurrencyAmount
        let totalWithdrawableAmount: CurrencyAmount
        let totalRealAmount: CurrencyAmount
        let totalBonusAmount: CurrencyAmount
        let items: [WalletItem]
    }
    
    struct CurrencyAmount: Codable {
        let amount: Double
        let currency: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCurrencyCodingKeys.self)
            
            // Get the first (and only) key-value pair
            guard let currencyKey = container.allKeys.first else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Currency amount has no keys"
                ))
            }
            
            self.currency = currencyKey.stringValue
            self.amount = try container.decode(Double.self, forKey: currencyKey)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCurrencyCodingKeys.self)
            try container.encode(amount, forKey: DynamicCurrencyCodingKeys(stringValue: currency))
        }
    }
    
    struct DynamicCurrencyCodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?
        
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }
    }
    
    struct WalletItem: Codable {
        let type: String
        let amount: Double?
        let currency: String?
        let productType: String?
        let sessionTimestamp: String?
        let walletAccountType: String?
        let sessionId: String?
        let creditLine: String?
    }
}
