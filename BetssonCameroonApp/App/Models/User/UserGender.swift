//
//  UserGender.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

enum UserGender: String, Codable, CaseIterable, Hashable {
    case male = "M"
    case female = "F"

    static var titles: [String] {
        return Self.allCases.map(\.rawValue)
    }

}
