//
//  FailableDecodable.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/11/2021.
//

import Foundation

struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

