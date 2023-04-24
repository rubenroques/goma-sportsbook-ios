//
//  TicketSelectionResponse.swift
//  
//
//  Created by André Lascas on 24/04/2023.
//

import Foundation

public struct TicketSelectionResponse: Codable {

    public var data: TicketSelection?
    public var errorType: String?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case errorType = "errorType"
    }
}
