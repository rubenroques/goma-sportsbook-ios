//
//  SportRadarSocketResponse.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation

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
