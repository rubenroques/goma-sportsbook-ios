//
//  SystemBetResponse.swift
//  EveryMatrixProviderClient
//
//  Created by Ruben Roques on 28/05/2025.
//

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
