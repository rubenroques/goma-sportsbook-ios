//
//  ChangeRecord.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct ChangeRecord: Codable {
        let changeType: EveryMatrix.ChangeType
        let entityType: String
        let id: String
        let entity: EveryMatrix.EntityData?  // For CREATE operations
        let changedProperties: [String: EveryMatrix.AnyChange]?  // For UPDATE operations

        private enum CodingKeys: String, CodingKey {
            case changeType
            case entityType
            case id
            case entity
            case changedProperties
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.ChangeRecord.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.changeType = try container.decode(EveryMatrix.ChangeType.self, forKey: CodingKeys.changeType)
            self.entityType = try container.decode(String.self, forKey: CodingKeys.entityType)
            self.id = try container.decode(String.self, forKey: CodingKeys.id)
            self.entity = try container.decodeIfPresent(EveryMatrix.EntityData.self, forKey: CodingKeys.entity)
            self.changedProperties = try container.decodeIfPresent([String : EveryMatrix.AnyChange].self, forKey: CodingKeys.changedProperties)
        }
    }
}
