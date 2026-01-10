//
//  Throwable.swift
//  AllGoals
//
//  Created by Ruben Roques on 14/04/2020.
//  Copyright © 2020 GOMA Development. All rights reserved.
//

import Foundation

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result { try T(from: decoder) }
    }

    func value() -> T? {
        return try? result.get()
    }
}
