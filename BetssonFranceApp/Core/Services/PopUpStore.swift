//
//  PopUpStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/10/2021.
//

import Foundation

struct PopUpStore {
    
    private static var key: String = "popUpCacheKey"
    
    static func shouldShowPopUp(withId id: String) -> Bool {
        let cache = PopUpStore.cache()
        if cache.isEmpty {
            return true
        }
        guard let futureDate = cache[id] else {
            return true
        }
        let nowReferenceDate = Date.timeIntervalSinceReferenceDate
        
        return nowReferenceDate > futureDate.timeIntervalSinceReferenceDate
    }
    
    static func cache() -> [String: Date] {
        if let popUpCache: [String: Date] = UserDefaults.standard.codable(forKey: PopUpStore.key) {
            return popUpCache
        }
        let emptyCache: [String: Date] = [:]
        UserDefaults.standard.set(codable: emptyCache, forKey: PopUpStore.key)
        UserDefaults.standard.synchronize()
        return [:]
    }
    
    static func didHidePopUp(withId id: String, withTimeout minutes: Int) {
        var cache = PopUpStore.cache()
        
        let nextShowDate = Date.timeIntervalSinceReferenceDate + (Double(minutes) * 60.0)
        cache[id] = Date(timeIntervalSinceReferenceDate: nextShowDate)
        
        UserDefaults.standard.set(codable: cache, forKey: PopUpStore.key)
        UserDefaults.standard.synchronize()
    }
    
}
