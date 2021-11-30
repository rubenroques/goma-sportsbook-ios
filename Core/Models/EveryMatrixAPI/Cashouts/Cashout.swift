//
//  Cashout.swift
//  Sportsbook
//
//  Created by André Lascas on 29/11/2021.
//

import Foundation

extension EveryMatrix {
    struct Cashout: Decodable {

        let id: String
        let type: String?
        let betId: String?
        let value: Double?
        let stake: Double?

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case id = "id"
            case betId = "betId"
            case value = "value"
            case stake = "stake"
        }

        func cashoutUpdated(value: Double?, stake: Double?) -> Self {

            return Self(id: self.id,
                        type: self.type,
                        betId: self.betId,
                        value: value,
                        stake: stake
            )
        }
    }
}
