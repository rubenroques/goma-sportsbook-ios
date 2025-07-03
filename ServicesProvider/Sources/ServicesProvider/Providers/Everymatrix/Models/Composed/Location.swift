//
//  Location.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Location: Identifiable, Hashable {
        let id: String
        let typeId: String
        let name: String
        let shortName: String?
        let code: String?
    }
}