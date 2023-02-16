//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/02/2023.
//

import Foundation

struct FailableDecodable<Content: Decodable>: Decodable {
    let content: Content?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.content = try? container.decode(Content.self)
    }
}
