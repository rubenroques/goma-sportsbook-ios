//
//  EveryMatrixModelMapper+Bonus.swift
//  ServicesProvider
//
//  Created by André Lascas on 24/03/2023.
//

import Foundation

extension EveryMatrixModelMapper {
    
    static func availableBonuses(fromInternalResponse response: EveryMatrix.BonusResponse) -> [AvailableBonus] {
        return response.bonuses.map { bonusItem in
            AvailableBonus(
                id: bonusItem.id,
                bonusPlanId: bonusItem.domainID,
                name: bonusItem.presentation.name.content,
                description: bonusItem.presentation.description.content,
                type: bonusItem.type,
                amount: 0.0,
                triggerDate: parseDate(from: bonusItem.trigger.startTime),
                expiryDate: parseDate(from: bonusItem.trigger.endTime),
                wagerRequirement: nil,
                imageUrl: "https:\(bonusItem.presentation.assets.content)",
                actionUrl: bonusItem.presentation.url.content
            )
        }
    }
    
    static func grantedBonuses(fromInternalResponse response: EveryMatrix.GrantedBonusResponse) -> [GrantedBonus] {
        return response.items.compactMap { bonusItem in
            // Convert string ID to Int, skip if conversion fails
            guard let intId = Int(bonusItem.id) else {
                print("⚠️ Failed to convert granted bonus ID '\(bonusItem.id)' to Int, skipping")
                return nil
            }
            
            let triggerDate = parseDate(from: bonusItem.grantedDate)
            
            let expiryDate = parseDate(from: bonusItem.expiryDate)
            
            return GrantedBonus(
                id: intId,
                name: bonusItem.name,
                status: bonusItem.status,
                amount: "\(bonusItem.remainingAmount) \(bonusItem.currency)",
                triggerDate: triggerDate,
                expiryDate: expiryDate,
                wagerRequirement: "\(bonusItem.remainingWagerRequirementAmount) \(bonusItem.currency)",
                amountWagered: nil
            )
        }
    }
    
    private static func parseDate(from dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        
        // Try different format combinations to handle various date formats
        let formatOptions: [ISO8601DateFormatter.Options] = [
            [.withInternetDateTime, .withFractionalSeconds],  // For dates with fractional seconds
            [.withInternetDateTime],                           // For dates without fractional seconds
            [.withFullDate, .withTime, .withColonSeparatorInTime, .withTimeZone], // For standard ISO8601
        ]
        
        for options in formatOptions {
            formatter.formatOptions = options
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        // Fallback: Try with DateFormatter for more flexibility
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",           // 2025-10-22T14:56:05+00:00
            "yyyy-MM-dd'T'HH:mm:ss'Z'",         // 2026-01-30T14:56:04Z
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",       // With milliseconds
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",     // With milliseconds and Z
        ]
        
        for format in dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        
        print("⚠️ Failed to parse date string: \(dateString)")
        return nil
    }
}
