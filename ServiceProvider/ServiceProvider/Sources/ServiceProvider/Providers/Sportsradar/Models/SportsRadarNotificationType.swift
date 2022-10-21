//
//  SportsRadarNotificationType.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation

extension SportRadarModels {
    
    enum NotificationType: Codable {
        
        case listeningStarted(sessionTokenId: String)
        case contentChanges(content: Content)
        case unknown
        
        enum CodingKeys: String, CodingKey {
            case notificationType = "notificationType"
            case data = "data"
            
            case content = "contentId"
            case contentType = "type"
            case contentId = "id"
            
            case changeType = "changeType"
            case change = "change"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let typeString = try container.decode(String.self, forKey: .notificationType)
            
            switch typeString {
            case "LISTENING_STARTED":
                let sessionTokenId = try container.decode(String.self, forKey: .data)
                self = .listeningStarted(sessionTokenId: sessionTokenId)
            case "CONTENT_CHANGES":
                do {
                    var dataUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .data)
                    // while !dataUnkeyedContainer.isAtEnd {
                    // }
                    let firstContentContainer = try dataUnkeyedContainer.nestedContainer(keyedBy: CodingKeys.self)
                    let contentTypeContainer = try firstContentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
                    
                    let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
                    let contentIdsArray = ((try? contentTypeContainer.decode(String.self, forKey: .contentId)) ?? "").components(separatedBy: "/")
                    
                    var content: Content
                    
                    switch contentType {
                    case .liveAdvancedList:
                        let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                        guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }
                        
                        let sportType = try SportRadarModels.SportType.init(id: sportId)
                        
                        content = .liveAdvancedList(sportType: sportType, events: events)
                    case .inplaySportList:
                        let sportsTypes: [SportRadarModels.SportTypeDetails] = try firstContentContainer.decode([SportRadarModels.SportTypeDetails].self, forKey: .change)
                        
                        content = .inplaySportList(sportsTypes: sportsTypes)
                    case .sportTypeByDate:
                        let sportsTypes: [SportRadarModels.SportType] = try firstContentContainer.decode([SportRadarModels.SportType].self, forKey: .change)

                        content = .sportTypeByDate(sportsTypes: sportsTypes)
                    case .eventListBySportTypeDate:
                        let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                        guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }

                        let sportType = try SportRadarModels.SportType.init(id: sportId)

                        content = .eventListBySportTypeDate(sportType: sportType, events: events)
//                    case .popularEventListBySportTypeDate:
//                        let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
//                        guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }
//
//                        let sportType = try SportRadarModels.SportType.init(id: sportId)
//
//                        content = .popularEventListBySportTypeDate(sportType: sportType, events: events)
//                    case .upcomingEventListBySportTypeDate:
//                        let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
//                        guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }
//
//                        let sportType = try SportRadarModels.SportType.init(id: sportId)
//
//                        content = .upcomingEventListBySportTypeDate(sportType: sportType, events: events)
                    }
                    self = .contentChanges(content: content)
                }
                catch {
                    print("Decoding error \(error)")
                    self = .unknown
                }
            default:
                self = .unknown
            }
        }
        
        func encode(to encoder: Encoder) throws {
            
        }
        
    }
    
}
