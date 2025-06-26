//
//  ChangeRecord.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct ChangeRecord: Codable {
        let changeType: ChangeType
        let entityType: String
        let id: String
        let entity: EntityData?  // For CREATE operations
        let changedProperties: [String: AnyCodable]?  // For UPDATE operations

        private enum CodingKeys: String, CodingKey {
            case changeType
            case entityType
            case id
            case entity
            case changedProperties
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.ChangeRecord.CodingKeys> = try decoder.container(keyedBy: EveryMatrix.ChangeRecord.CodingKeys.self)
            self.changeType = try container.decode(EveryMatrix.ChangeType.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.changeType)
            self.entityType = try container.decode(String.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.entityType)
            self.id = try container.decode(String.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.id)
            self.entity = try container.decodeIfPresent(EveryMatrix.EntityData.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.entity)
            self.changedProperties = try container.decodeIfPresent([String : EveryMatrix.AnyCodable].self, forKey: EveryMatrix.ChangeRecord.CodingKeys.changedProperties)
        }
    }
}