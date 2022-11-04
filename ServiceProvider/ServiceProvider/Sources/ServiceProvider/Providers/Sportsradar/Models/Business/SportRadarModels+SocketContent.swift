//
//  SportRadarModels.swift
//  
//
//  Created by Ruben Roques on 14/10/2022.
//

import Foundation


enum SportRadarModels {
    
}

extension SportRadarModels {
    
    enum ContentType: String, Codable {
        case liveAdvancedList = "liveDataSummaryAdvancedListBySportType"
        case inplaySportList = "inplaySportListBySportType"
        // case sportTypeList = ""
        case sportTypeByDate = "sportTypeByDate"
        case eventListBySportTypeDate = "eventListBySportTypeDate"

    }
    
    enum Content {
        
        case liveAdvancedList(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])
        case inplaySportList(sportsTypes: [SportRadarModels.SportTypeDetails])
        case sportTypeByDate(sportsTypes: [SportRadarModels.SportType])
        case eventListBySportTypeDate(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])
//        case popularEventListBySportTypeDate(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])
//        case upcomingEventListBySportTypeDate(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])

        
        var code: ContentType {
            switch self {
            case .liveAdvancedList: return .liveAdvancedList
            case .inplaySportList: return .inplaySportList
            case .sportTypeByDate: return .sportTypeByDate
            case .eventListBySportTypeDate: return .eventListBySportTypeDate
//            case .popularEventListBySportTypeDate: return .eventListBySportTypeDate
//            case .upcomingEventListBySportTypeDate: return .eventListBySportTypeDate
            }
        }
        
    }
    
}
