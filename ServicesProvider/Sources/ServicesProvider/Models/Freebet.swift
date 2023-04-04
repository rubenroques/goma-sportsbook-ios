//
//  File.swift
//  
//
//  Created by Ruben Roques on 04/04/2023.
//

import Foundation


public struct FreebetBalance: Codable {

    public var balance: Double

    enum CodingKeys: CodingKey {
        case balance
    }

    public init(balance: Double) {
        self.balance = balance
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.balance = try container.decode(Double.self, forKey: .balance)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.balance, forKey: .balance)
    }

}
