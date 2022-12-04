//
//  SportRadarModels.swift
//  
//
//  Created by Ruben Roques on 05/10/2022.
//

import Foundation

enum SportRadarModels {
    
}

extension SportRadarModels {

    enum ContentContainer {
        
        case liveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case preLiveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        
        case liveSports(sportsTypes: [SportType])
        case preLiveSports(sportsTypes: [SportType]) // TODO: Task André - Deveria ser um modelo da Sportradar, SportRadarModels.SportType
        
        case eventDetails(eventDetails: [SportRadarModels.Event])
    }

    struct RestResponse<T: Codable>: Codable {
        let data: T?
        enum CodingKeys: String, CodingKey {
            case data = "data"
        }
    }

}


extension SportRadarModels {
    
    enum NotificationType: Codable {
        
        case listeningStarted(sessionTokenId: String)
        case contentChanges(content: ContentContainer)
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
                    
                    let contentContainer = try dataUnkeyedContainer.nestedContainer(keyedBy: CodingKeys.self)
                    
                    let contentTypeContainer = try contentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
                    let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
                    
//                    let contentIdsArray = ((try? contentTypeContainer.decode(String.self, forKey: .contentId)) ?? "").components(separatedBy: "/")

                    let contentIdentifier = try contentContainer.decode(ContentIdentifier.self, forKey: .content)
                    var content: ContentContainer
                    
                    switch contentType {
                    case .liveEvents:
                        let events: [SportRadarModels.Event] = try contentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                        content = .liveEvents(contentIdentifier: contentIdentifier, events: events)
                        
                    case .liveSports:
                        let sportsTypeDetails: [SportRadarModels.SportTypeDetails] = try contentContainer.decode([SportRadarModels.SportTypeDetails].self, forKey: .change)
                        let sportsTypes = sportsTypeDetails.map(\.sportType)
                        content = .liveSports(sportsTypes: sportsTypes)
                        
                    case .preLiveSports:
                        // change key is optional
                        if contentContainer.contains(.change) {
                            let sportsTypes: [SportRadarModels.SportType] = try contentContainer.decode([SportRadarModels.SportType].self, forKey: .change)
                            content = .preLiveSports(sportsTypes: sportsTypes)
                        }
                        else {
                            let sportsTypes: [SportType] = []
                            content = .preLiveSports(sportsTypes: sportsTypes)
                        }

                    case .preLiveEvents:
                        // change key is optional
                        if contentContainer.contains(.change) {
                            let events: [SportRadarModels.Event] = try contentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                            content = .preLiveEvents(contentIdentifier: contentIdentifier, events: events)
                        }
                        else {
                            content = .preLiveEvents(contentIdentifier: contentIdentifier, events: [])
                        }
                        
                    case .eventDetails:
                        // change key is optional
                        if contentContainer.contains(.change) {
                            let event: SportRadarModels.Event = try contentContainer.decode(SportRadarModels.Event.self, forKey: .change)

                            content = .eventDetails(eventDetails: [event])
                        }
                        else {

                            content = .eventDetails(eventDetails: [])
                        }
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
