//
//  SportRegion.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import SharedModels

public struct SportRegion: Codable {
    public var id: String
    public var name: String?
    public var numberEvents: String
    public var numberOutrightEvents: String
    public var country: Country?

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case numberEvents = "numevents"
        case numberOutrightEvents = "numoutrightevents"
    }
}
