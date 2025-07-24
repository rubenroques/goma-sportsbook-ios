//
//  File.swift
//  
//
//  Created by Ruben Roques on 04/04/2023.
//

import Foundation

extension SportRadarModels {

    struct FreebetResponse: Codable {

        var balance: Double

        enum CodingKeys: String, CodingKey {
            case balance = "freeBalance"
        }

    }

}
