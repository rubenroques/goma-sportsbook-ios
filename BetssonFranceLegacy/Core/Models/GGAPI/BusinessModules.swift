//
//  BusinessModules.swift
//  Sportsbook
//
//  Created by Ruben Roques on 08/08/2022.
//

import Foundation

typealias BusinessModules = [BusinessModule]

struct BusinessModule: Codable {

    var id: String
    var category: String
    var name: String
    var enabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case category = "category"
        case name = "name"
        case enabled = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        }
        else if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        }
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid id format"))
        }
        
        if let isEnabledInt: Int = (try? container.decode(Int.self, forKey: .enabled)) {
            self.enabled = isEnabledInt == 1 ? true : false
        }
        else if let isEnabledString: String = (try? container.decode(String.self, forKey: .enabled)) {
            self.enabled = isEnabledString == "1" ? true : false
        }
        else {
            self.enabled = false
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.category, forKey: .category)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.enabled, forKey: .enabled)
    }
    
}

