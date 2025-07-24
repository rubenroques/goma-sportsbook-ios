//
//  File.swift
//
//
//  Created by Ruben Roques on 21/12/2023.
//

import Foundation

extension GomaModels {
    
    typealias Sports = [Sport]
    
    struct Sport: Codable, Equatable {
        var identifier: String
        var name: String
        var iconIdentifier: String?
        var preLiveEventsCount: Int?
        var liveEventsCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name = "name"
            case iconIdentifier = "icon_id"
            case preLiveEventsCount = "pre_live_count"
            case liveEventsCount = "live_count"
        }
        
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.iconIdentifier = try? container.decode(String.self, forKey: .iconIdentifier)
            
            // Check if the identifier is Int or String
            if let idInt = try? container.decode(Int.self, forKey: .identifier) {
                self.identifier = String(idInt)
            } else {
                self.identifier = try container.decode(String.self, forKey: .identifier)
            }
            
            if let countString = try? container.decode(String.self, forKey: .preLiveEventsCount), let count = Int(countString) {
                self.preLiveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .preLiveEventsCount) {
                self.preLiveEventsCount = countInt
            }
            else {
                self.preLiveEventsCount = 0
            }
            
            if let countString = try? container.decode(String.self, forKey: .liveEventsCount), let count = Int(countString) {
                self.liveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .liveEventsCount) {
                self.liveEventsCount = countInt
            }
            else {
                self.liveEventsCount = 0
            }
            
        }
        
    }
    
}

