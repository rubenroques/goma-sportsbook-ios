//
//  EveryMatrix+ResponsibleGaming.swift
//  ServicesProvider
//
//  Created by Claude on 07/11/2025.
//

import Foundation

extension EveryMatrix {
    struct ResponsibleGamingLimitsResponse: Decodable {
        let status: String?
        private let limitsDirect: [ResponsibleGamingLimit]?
        private let data: DataContainer?
        private let success: Bool?
        
        var limits: [ResponsibleGamingLimit] {
            if let limitsDirect = limitsDirect, !limitsDirect.isEmpty {
                return limitsDirect
            }
            if let dataLimits = data?.limits, !dataLimits.isEmpty {
                return dataLimits
            }
            if let singleLimit = data?.limit {
                return [singleLimit]
            }
            return []
        }
        
        struct DataContainer: Decodable {
            let limits: [ResponsibleGamingLimit]?
            let limit: ResponsibleGamingLimit?
        }
        
        enum CodingKeys: String, CodingKey {
            case status
            case limits = "limits"
            case data
            case success
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decodeIfPresent(String.self, forKey: .status)
            limitsDirect = try container.decodeIfPresent([ResponsibleGamingLimit].self, forKey: .limits)
            data = try container.decodeIfPresent(DataContainer.self, forKey: .data)
            success = try container.decodeIfPresent(Bool.self, forKey: .success)
        }
    }
    
    struct ResponsibleGamingLimit: Decodable {
        let id: String?
        let playerId: String?
        let domainId: String?
        let amount: Double?
        let currency: String?
        let period: String?
        let type: String?
        let products: [String]?
        let walletTypes: [String]?
        let schedules: [String]?
        let effectiveDate: String?
        let expiryDate: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case playerId
            case domainId
            case amount
            case currency
            case period
            case type
            case products
            case walletTypes
            case schedules
            case effectiveDate
            case expiryDate
        }
    }

    struct SetUserLimitResponse: Decodable {
        let limit: ResponsibleGamingLimit
    }

    struct EmptyResponse: Decodable { }
}

