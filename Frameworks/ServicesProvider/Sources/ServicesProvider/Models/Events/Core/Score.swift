//
//  Score.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum Score: Codable, Hashable {

    case set(index: Int, home: Int?, away: Int?)
    case gamePart(home: Int?, away: Int?)
    case matchFull(home: Int?, away: Int?)

    public var sortValue: Int {
        switch self {
        case .set(let index, _, _):
            return index
        case .gamePart:
            return 100
        case .matchFull:
            return 200
        }
    }

    public var key: String {
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
