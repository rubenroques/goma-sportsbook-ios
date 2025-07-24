//
//  File.swift
//
//
//  Created by Ruben Roques on 21/12/2023.
//

import Foundation
import SharedModels

extension GomaModelMapper {
    
    static func sportsType(fromSports sports: GomaModels.Sports) -> [SportType] {
        
        return sports.map(Self.sportType(fromSport:))
        
    }
    
    static func sportType(fromSport sport: GomaModels.Sport) -> SportType {
        
        var iconIdentifier = sport.iconIdentifier
        if iconIdentifier == nil {
            iconIdentifier = Self.sportIconId(forNumericIdentifier: sport.identifier)
        }
        
        let sportType = SportType(name: sport.name,
                                  numericId: sport.identifier,
                                  alphaId: sport.identifier,
                                  iconId: iconIdentifier,
                                  showEventCategory: false,
                                  numberEvents: sport.preLiveEventsCount ?? 0,
                                  numberOutrightEvents: 0,
                                  numberOutrightMarkets: 0,
                                  numberLiveEvents: sport.liveEventsCount ?? 0)
        return sportType
    }
    
    private static func simplify(string: String) -> String {
        let validChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return string.filter { validChars.contains($0) }.lowercased()
    }
    
    static func sportIconId(forNumericIdentifier numericIdentifier: String) -> String? {
        switch numericIdentifier {
        case "4": return "1"    // "name": "Futebol"
        case "1": return "8"    // "name": "Basquetebol"
        case "2": return "3"    // "name": "Tenis"
        case "3": return "20"   // "name": "Voleibol"
        case "5": return "6"    // "name": "Hoquei Gelo"
        case "6": return "28"   // "name": "Rugby"
        case "7": return "7"    // "name": "Andebol"
        case "8": return "49"   // "name": "Futsal"
        case "9": return "5"    // "name": "Fut. Americano"
        case "10": return "902" // "name": "Hoquei Patins"
        case "11": return "66"  // "name": "Futebol Praia"
        default: return nil
        }
        
    }
    
}
