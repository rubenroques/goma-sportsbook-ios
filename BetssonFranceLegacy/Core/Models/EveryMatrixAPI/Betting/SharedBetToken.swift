//
//  SharedBetToken.swift
//  Sportsbook
//
//  Created by André Lascas on 07/02/2022.
//

import Foundation

struct SharedBetToken: Decodable {

    var success: Bool
    var errorMessage: String?
    var sharedBetTokens: BetToken

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case errorMessage = "errorMessage"
        case sharedBetTokens = "sharedBetTokens"
    }
}

struct BetToken: Decodable {
    var betTokenWithAllInfo: String
    var betTokenWithoutStakeAndWinnings: String

    enum CodingKeys: String, CodingKey {
        case betTokenWithAllInfo = "betTokenWithAllInfo"
        case betTokenWithoutStakeAndWinnings = "betTokenWithoutStakeAndWinnings"
    }
}
