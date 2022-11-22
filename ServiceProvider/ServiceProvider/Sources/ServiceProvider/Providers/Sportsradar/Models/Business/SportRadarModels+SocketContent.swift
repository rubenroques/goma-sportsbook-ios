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
    
    enum ContentType: String, Codable {
        case liveAdvancedList = "liveDataSummaryAdvancedListBySportType"
        case inplaySportList = "inplaySportListBySportType"
        case sportTypeByDate = "sportTypeByDate"
        case eventListBySportTypeDate = "eventListBySportTypeDate"
        case eventDetails = "event"
    }
    
    enum Content {
        
        case liveAdvancedList(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])
        case inplaySportList(sportsTypes: [SportRadarModels.SportTypeDetails])
        case sportTypeByDate(sportsTypes: [SportRadarModels.SportType])
        case eventListBySportTypeDate(sportType: SportRadarModels.SportType, events: [SportRadarModels.Event])
        case eventDetails(eventDetails: [SportRadarModels.Event])
        
        var code: ContentType {
            switch self {
            case .liveAdvancedList: return .liveAdvancedList
            case .inplaySportList: return .inplaySportList
            case .sportTypeByDate: return .sportTypeByDate
            case .eventListBySportTypeDate: return .eventListBySportTypeDate
            case .eventDetails: return .eventDetails
            }
        }
        
    }
    
}


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
                        // change key is optional
                        if firstContentContainer.contains(.change) {
                            let sportsTypes: [SportRadarModels.SportType] = try firstContentContainer.decode([SportRadarModels.SportType].self, forKey: .change)

                            content = .sportTypeByDate(sportsTypes: sportsTypes)
                        }
                        else {
                            let sportsTypes: [SportType] = []

                            content = .sportTypeByDate(sportsTypes: sportsTypes)
                        }

                    case .eventListBySportTypeDate:
                        // change key is optional
                        if firstContentContainer.contains(.change) {
                            let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                            guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }

                            let sportType = try SportRadarModels.SportType.init(id: sportId)

                            content = .eventListBySportTypeDate(sportType: sportType, events: events)
                        }
                        else {
                            guard let sportId = contentIdsArray.first else { throw SportRadarError.unkownContentId }

                            let sportType = try SportRadarModels.SportType.init(id: sportId)

                            content = .eventListBySportTypeDate(sportType: sportType, events: [])
                        }
                    case .eventDetails:
                        // change key is optional
                        if firstContentContainer.contains(.change) {
                            let event: SportRadarModels.Event = try firstContentContainer.decode(SportRadarModels.Event.self, forKey: .change)

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

extension SportRadarModels {
    
    struct SocketMessageType: Codable {
        
        let version: Int
        let notificationType: NotificationType
        
        enum CodingKeys: String, CodingKey {
            case version = "version"
            case notificationType = "notificationType"
        }
        
    }
    
    struct SocketMessage<T: Codable>: Codable {
        
        let version: Int
        let data: T?
        let notificationType: NotificationType
        
        enum CodingKeys: String, CodingKey {
            case version = "version"
            case data = "data"
            case notificationType = "notificationType"
        }
        
        init(from decoder: Decoder) throws {
            
            self.notificationType = .unknown
            self.data = nil
            self.version = 1
            
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.version = try container.decode(Int.self, forKey: .version)
//
//            let notificationTypeString = try container.decode(String.self, forKey: .notificationType)
//            guard
//                let sportsRadarNotificationType = NotificationType(rawValue: notificationTypeString)
//            else {
//                self.notificationType = .unknown
//                self.data = nil
//                return
//            }
//
//            self.notificationType = sportsRadarNotificationType
//
//            self.data = try container.decode(T.self, forKey: .data)
//
            //        switch self.notificationType {
            //        case .listeningStarted:
            //            self.data = try container.decode(String.self, forKey: .data)
            //        case .contentChanges:
            //        case .unknown:
            //            self.data = nil
            //        }
            
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.version, forKey: .version)
            try container.encode(self.data, forKey: .data)
            try container.encode(self.notificationType, forKey: .notificationType)
        }
    }
}
