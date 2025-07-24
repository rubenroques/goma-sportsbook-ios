//
//  GomaUIModelMapper+Outcome.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/06/2025.
//
import GomaUI

enum GomaUIModelMapper {
    static func oddsChangeDirection(fromGomaUI oddsChangeDirection: GomaUI.OddsChangeDirection) -> OddsChangeDirection {
        switch oddsChangeDirection {
        case .up:
            return .up
        case .down:
            return .down
        case .none:
            return .none
        }
    }
    
    static func gomaUIOddsChangeDirection(fromApp oddsChangeDirection: OddsChangeDirection) -> GomaUI.OddsChangeDirection {
        switch oddsChangeDirection {
        case .up:
            return .up
        case .down:
            return .down
        case .none:
            return .none
        }
    }
    
}
