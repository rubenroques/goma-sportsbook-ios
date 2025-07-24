//
//  String+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import Foundation
import CryptoKit

extension String {
    
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
    }
    
    var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
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
