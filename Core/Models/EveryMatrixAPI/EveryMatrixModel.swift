//
//  EveryMatrixModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

enum EveryMatrix {

}

extension EveryMatrix {
    
    struct OperatorInfo: Codable {
        var providerId: Int?
        var groupId: Int?
        var operatorId: Int?
        var apiVersion: Int?
        var ucsOperatorId: Int?

        enum CodingKeys: String, CodingKey {
            case providerId = "providerId"
            case groupId = "groupId"
            case operatorId = "operatorId"
            case apiVersion = "apiVersion"
            case ucsOperatorId = "ucsOperatorId"
        }
    }

}
