//
//  OddsFormat.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//


import Foundation

enum OddsFormat: Int {
    case europe
    case unitedKingdom
    case unitedStates

    var oddsFormatId: Int {
        switch self {
        case .europe:
            return 1
        case .unitedKingdom:
            return 2
        case .unitedStates:
            return 3
        }
    }
}
