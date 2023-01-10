//
//  BetType.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/12/2022.
//

import Foundation

public enum BetType {
    case single(identifier: String)
    case multiple(identifier: String)
    case system(identifier: String, name: String)
}
