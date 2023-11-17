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
    
    enum NotificationType: Codable {
        
        case listeningStarted(sessionTokenId: String)
        case contentChanges(contents: [ContentContainer])
        case subscriberIdNotFoundError(oldId: String?)
        case genericError
        case unknown

        enum CodingKeys: String, CodingKey {
            case notificationType = "notificationType"
            case errorType = "errorType"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let errorMessage: String = try? container.decode(String.self, forKey: .errorType) {
                if  errorMessage.lowercased() == "subscriber_not_found" {
                    let oldId: String? = (try? container.decode([String].self, forKey: .data))?.first
                    self = .subscriberIdNotFoundError(oldId: oldId)
                }
                else {
                    self = .genericError
                }
            }
            else if let typeString = try? container.decode(String.self, forKey: .notificationType) {
                switch typeString {
                case "LISTENING_STARTED":
                    let sessionTokenId = try container.decode(String.self, forKey: .data)
                    self = .listeningStarted(sessionTokenId: sessionTokenId)
                case "CONTENT_CHANGES":
                    let contents = try container.decode([FailableDecodable<SportRadarModels.ContentContainer>].self, forKey: .data)
                    let validContents = contents.compactMap({ $0.content })
                    self = .contentChanges(contents: validContents)
                default:
                    self = .unknown
                }
            }
            else {
                self = .unknown
            }
        }
        
        func encode(to encoder: Encoder) throws {
            
        }

    }

}



extension SportRadarModels {

    struct RestResponse<T: Codable>: Codable {
        let data: T?
        enum CodingKeys: String, CodingKey {
            case data = "data"
        }
    }

}
