//
//  ChangeType.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    enum ChangeType: String, Codable {
        case create = "CREATE"
        case update = "UPDATE"
        case delete = "DELETE"
    }
}