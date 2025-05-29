//
//  FailableDecodable.swift
//  EveryMatrixProviderClient
//
//  Created by Ruben Roques on 28/05/2025.
//

struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

