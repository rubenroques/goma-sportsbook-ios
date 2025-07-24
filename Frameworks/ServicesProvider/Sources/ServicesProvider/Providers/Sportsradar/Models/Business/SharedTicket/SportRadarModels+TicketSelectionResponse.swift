//
//  SportRadarModels+TicketSelectionResponse.swift
//  
//
//  Created by André Lascas on 24/04/2023.
//

import Foundation

extension SportRadarModels {

    struct TicketSelectionResponse: Codable {

        var data: TicketSelection?
        var errorType: String?

        enum CodingKeys: String, CodingKey {
            case data = "data"
            case errorType = "errorType"
        }
    }

}
