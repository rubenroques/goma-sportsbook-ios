//
//  Scores.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation

enum Score: Codable, Hashable {
    
    case set(index: Int, home: Int?, away: Int?)
    case gamePart(home: Int?, away: Int?)
    case matchFull(home: Int?, away: Int?)
    
    var sortValue: Int {
        switch self {
        case .set(let index, _, _):
            return index
        case .gamePart:
            return 100
        case .matchFull:
            return 200
        }
    }
    
    var key: String {
        switch self {
        case .set(let index, _, _):
            return "set\(index)"
        case .gamePart:
            return "gamePart"
        case .matchFull:
            return "matchFull"
        }
    }
    
}
