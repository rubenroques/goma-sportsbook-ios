//
//  SupportTicketResponse.swift
//  Sportsbook
//
//  Created by Teresa on 02/06/2022.
//

import Foundation

struct SupportTicketResponse: Codable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}
