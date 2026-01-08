//
//  SystemBetResponse.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/11/2021.
//

import Foundation

struct SystemBetResponse: Decodable {
    var systemBets: [SystemBetType]

    enum CodingKeys: String, CodingKey {
        case systemBets = "systemBetTypes"
    }

}

struct SystemBetType: Decodable {
    var id: String
    var name: String?
    var numberOfBets: Int?
}

extension SystemBetType: Equatable {
    static func == (lhs: SystemBetType, rhs: SystemBetType) -> Bool {
        return lhs.id == rhs.id
    }
}
