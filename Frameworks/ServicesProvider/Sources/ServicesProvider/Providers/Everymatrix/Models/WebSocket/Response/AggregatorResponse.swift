//
//  AggregatorResponse.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct AggregatorResponse: Codable {
        let version: String
        let format: String
        let messageType: String?
        let records: [EveryMatrix.EntityRecord]
    }
}
