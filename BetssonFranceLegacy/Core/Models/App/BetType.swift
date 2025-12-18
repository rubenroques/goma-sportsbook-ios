//
//  BetType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/12/2022.
//

import Foundation

public enum BetType: Equatable {
    case single(identifier: String)
    case multiple(identifier: String)
    case system(identifier: String, name: String)

    public static func == (lhs: BetType, rhs: BetType) -> Bool {
        switch (lhs, rhs) {
        case let (.single(id1), .single(id2)):
            return id1 == id2
        case let (.multiple(id1), .multiple(id2)):
            return id1 == id2
        case let (.system(id1, name1), .system(id2, name2)):
            return id1 == id2 && name1 == name2
        default:
            return false
        }
    }

}
