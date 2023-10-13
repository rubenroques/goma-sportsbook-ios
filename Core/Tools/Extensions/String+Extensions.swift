//
//  String+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import Foundation
import CryptoKit

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
    
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
    }
    
    var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }

    func isValidEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    func slugify() -> String {
        let normalizedString = self.folding(options: .diacriticInsensitive, locale: .current)
        let withoutSpecialCharacters = normalizedString.replacingOccurrences(of: "[^a-zA-Z0-9\\s-]", with: "", options: .regularExpression, range: nil)
        let lowercasedString = withoutSpecialCharacters.lowercased()
        let trimmedString = lowercasedString.trimmingCharacters(in: .whitespacesAndNewlines)
        let replacingSpacesWithDash = trimmedString.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression, range: nil)
        let removingConsecutiveDashes = replacingSpacesWithDash.replacingOccurrences(of: "--+", with: "-", options: .regularExpression, range: nil)

        return removingConsecutiveDashes
    }
    
}
