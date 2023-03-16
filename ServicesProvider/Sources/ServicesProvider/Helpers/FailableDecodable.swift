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

        do {
            self.content = try container.decode(Content.self)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print(" codingPath: \(context.codingPath)")
            self.content = nil
        }
        catch let DecodingError.valueNotFound(type, context)  {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print(" codingPath: \(context.codingPath)")
            self.content = nil
        }
        catch {
            // print("Uknown error decoding \(error)")
            self.content = nil
        }
    }
    
}
