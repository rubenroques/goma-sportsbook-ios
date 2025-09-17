//
//  RPCResponse.swift
//  ServicesProvider
//
//  Created for handling EveryMatrix RPC responses
//

import Foundation

extension EveryMatrix {
    /// Generic response structure for all EveryMatrix RPC calls
    /// RPC calls return a different structure than subscription-based responses:
    /// - They include "format": "BASIC" field
    /// - They don't have messageType field (which is only in subscription responses)
    /// - They have version as a timestamp number instead of string
    struct RPCResponse: Codable {
        let version: String  // Timestamp as string like "1754464976985"
        let format: String   // Always "BASIC" for RPC responses
        let records: [EntityRecord]
        
        enum CodingKeys: String, CodingKey {
            case version
            case format
            case records
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle version as either String or Int64
            if let versionString = try? container.decode(String.self, forKey: .version) {
                self.version = versionString
            } else if let versionInt = try? container.decode(Int64.self, forKey: .version) {
                self.version = String(versionInt)
            } else {
                throw DecodingError.typeMismatch(String.self, 
                    DecodingError.Context(codingPath: [CodingKeys.version], 
                    debugDescription: "Version must be either String or Int64"))
            }
            
            self.format = try container.decode(String.self, forKey: .format)
            self.records = try container.decode([EntityRecord].self, forKey: .records)
        }
    }
    
    struct RPCBasicResponse: Codable {
        let records: [EntityRecord]
        let includedData : [EntityRecord]?
        
        enum CodingKeys: String, CodingKey {
            case records
            case includedData
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.records = try container.decode([EntityRecord].self, forKey: .records)
            
            self.includedData = try container.decodeIfPresent([EntityRecord].self, forKey: .includedData)
        }
    }
}
