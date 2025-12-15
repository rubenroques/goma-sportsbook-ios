//
//  SportRadarModels+CashbackBalance.swift
//
//
//  Created by André Lascas on 17/07/2023.
//

import Foundation

extension SportRadarModels {
    
    struct CashbackBalance: Codable {
        var status: String
        var balance: Double?
        var message: String?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case balance = "balance"
            case message = "message"
        }
        
        init(status: String, balance: Double? = nil, message: String? = nil) {
            self.status = status
            self.balance = balance
            self.message = message
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try container.decode(String.self, forKey: .status)
            self.message = try container.decodeIfPresent(String.self, forKey: .message)
            
            var balanceDouble: Double?
            if let balanceStringValue = try? container.decodeIfPresent(String.self, forKey: .balance) {
                balanceDouble = self.formattedAmountStringToDouble(from: balanceStringValue)
            }
            else if let balanceDoubleValue = try? container.decodeIfPresent(Double.self, forKey: .balance) {
                balanceDouble = balanceDoubleValue
            }
            self.balance = balanceDouble
        }
        
        
        // Improved string to double conversion function
        func formattedAmountStringToDouble(from string: String) -> Double? {
            // Check if string starts with a minus sign
            
            let isNegative = string.starts(with: "-")
            let stringWithoutMinus = isNegative ? String(string.dropFirst()) : string
            
            // STEP 1: Detect format (US/UK or European)
            // Look for decimal separators
            let lastPeriodIndex = stringWithoutMinus.lastIndex(of: ".")
            let lastCommaIndex = stringWithoutMinus.lastIndex(of: ",")
            
            // Determine which is likely the decimal separator
            var usesCommaAsDecimal = false
            
            if let lastPeriod = lastPeriodIndex, let lastComma = lastCommaIndex {
                // If both exist, the one that comes later is likely the decimal separator
                usesCommaAsDecimal = stringWithoutMinus.distance(from: stringWithoutMinus.startIndex, to: lastComma) >
                stringWithoutMinus.distance(from: stringWithoutMinus.startIndex, to: lastPeriod)
            } else if lastCommaIndex != nil && lastPeriodIndex == nil {
                // Only comma exists
                usesCommaAsDecimal = true
            }
            // If only period exists or neither exists, usesCommaAsDecimal remains false
            
            // STEP 2: Process based on detected format
            var processedString = stringWithoutMinus
            
            if usesCommaAsDecimal {
                // European format: replace all periods (thousand separators) with nothing
                processedString = processedString.replacingOccurrences(of: ".", with: "")
                // Replace comma (decimal separator) with period
                processedString = processedString.replacingOccurrences(of: ",", with: ".")
            } else {
                // US/UK format: replace all commas (thousand separators) with nothing
                processedString = processedString.replacingOccurrences(of: ",", with: "")
            }
            
            // STEP 3: Remove any non-numeric characters except the decimal point
            let pattern = "[^0-9.]"
            processedString = processedString.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            
            // STEP 4: Convert to Double and apply sign
            if let result = Double(processedString) {
                return isNegative ? -result : result
            }
            
            return nil
        }
    }
}
