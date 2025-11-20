//
//  Scores.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation

enum Score: Codable, Hashable {
    
    case set(index: Int, home: Int?, away: Int?)
    case gamePart(index: Int?, home: Int?, away: Int?)
    case matchFull(home: Int?, away: Int?)
    
    var sortValue: Int {
        switch self {
        case .set(let index, _, _):
            return index
        case .gamePart(let index, _, _):
            return index ?? 100
        case .matchFull:
            return 200
        }
    }
    
    var key: String {
        switch self {
        case .set(let index, _, _):
            return "set\(index)"
        case .gamePart(let index, _, _):
            if let index = index {
                return "gamePart\(index)"
            }
            return "gamePart"
        case .matchFull:
            return "matchFull"
        }
    }
    
}

extension Score: CustomDebugStringConvertible {
    var debugDescription: String {
        let scoreDetails: String
        switch self {
        case .set(let index, let home, let away):
            scoreDetails = "Type: Set \(index) - [\(home ?? -1) - \(away ?? -1)]"
        case .gamePart(let index, let home, let away):
            let indexStr = index.map { "\($0)" } ?? "nil"
            scoreDetails = "Type: Game Part \(indexStr) - [\(home ?? -1) - \(away ?? -1)]"
        case .matchFull(let home, let away):
            scoreDetails = "Type: Match Full - [\(home ?? -1) - \(away ?? -1)]"
        }
        return scoreDetails
    }
}
