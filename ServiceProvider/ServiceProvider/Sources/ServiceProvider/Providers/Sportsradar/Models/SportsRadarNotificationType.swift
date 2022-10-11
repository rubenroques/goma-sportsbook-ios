//
//  SportsRadarNotificationType.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation

enum SportRadarModels {
    
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
                    let contentId = (try? contentTypeContainer.decode(String.self, forKey: .contentId)) ?? ""
                    
                    let sportType = try SportRadarModels.SportType.init(id: contentId)

                    switch contentType {
                    case .liveAdvancedList:
                        // let changeType = (try? container.decode(String.self, forKey: .changeType)) ?? ""
                        let events: [SportRadarModels.Event] = try firstContentContainer.decode([SportRadarModels.Event].self, forKey: .change)
                        self = .contentChanges(content: .liveAdvancedList(sportType: sportType, eventsList: events))
                    }
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
    
    
    enum ContentType: String, Codable {
        case liveAdvancedList = "liveDataSummaryAdvancedListBySportType"
    }
    
    enum Content {
        case liveAdvancedList(sportType: SportRadarModels.SportType, eventsList: [SportRadarModels.Event])
        
        var type: ContentType {
            switch self {
            case .liveAdvancedList:
                return ContentType.liveAdvancedList
            }
        }
        
    }
    
    struct Event: Codable {
        
        var id: String
        var homeName: String
        var awayName: String
        var sportTypeName: String
        
        var competitionId: String
        var competitionName: String
        
        var markets: [Market]
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoevent"
            case homeName = "participantname_home"
            case awayName = "participantname_away"
            case competitionId = "idfotournament"
            case competitionName = "tournamentname"
            case sportTypeName = "sporttypename"
            case markets = "markets"
        }
        
    }
    
    struct Market: Codable {
        
        var id: String
        var name: String
        var outcomes: [Outcome]
        
        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
        }
        
    }
    
    struct Outcome: Codable {
        
        var id: String
        var name: String
        var hashCode: String
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoselection"
            case name = "name"
            case hashCode = "selectionhashcode"
        }
        
    }
    
}


extension SportRadarModels {
    
    enum SportType {
        case football
        
        init(id: String) throws {
            switch id {
            case "FBL/0":
                self = .football
            default:
                throw SportRadarError.unkownSportId
            }
        }
        
//        var code: String {
//            switch self {
//            case .football:
//                return "FBL"
//            }
//        }

        var id: String {
            switch self {
            case .football:
                return "FBL/0"
            }
        }
    }
    
}
