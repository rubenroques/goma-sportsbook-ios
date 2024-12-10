//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/02/2023.
//

import Foundation

struct FailableDecodable<Content: Codable>: Codable {
    let content: Content?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self.content = try container.decode(Content.self)
        } catch let DecodingError.typeMismatch(type, context)  {
            //print("FailableDecodable Error: Type '\(type)' mismatch: \(context.debugDescription); codingPath: \(context.codingPath)")
            self.content = nil
        } catch let DecodingError.valueNotFound(type, context)  {
            //print("FailableDecodable Error: Type '\(type)' mismatch: \(context.debugDescription); codingPath: \(context.codingPath)")
            self.content = nil
        } catch {
            //print("FailableDecodable Error: Unknown error decoding \(error)")
            self.content = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}
