//
//  UserTitle.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

enum UserTitle: String, Codable, CaseIterable, Hashable {
    case mister = "Mr."
    case mizz = "Ms."
    case misses = "Mrs."
    case miss = "Miss"
    
    static var titles: [String] {
        return Self.allCases.map(\.rawValue)
    }
    
    var genderAbbreviation: String {
        switch self {
        case .mister: return "M"
        default: return "F"
        }
    }
}
