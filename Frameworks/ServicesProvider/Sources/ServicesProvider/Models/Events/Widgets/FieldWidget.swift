//
//  FieldWidget.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FieldWidget: Codable {
    public var data: String?
    public var version: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case version = "version"
    }
}
