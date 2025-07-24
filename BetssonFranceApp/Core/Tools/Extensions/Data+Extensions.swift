//
//  Data+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 24/01/2023.
//

import Foundation

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
