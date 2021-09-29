//
//  RootData.swift
//  Sportsbook
//
//  Created by André Lascas on 02/09/2021.
//

import Foundation

struct EveryMatrixSocketResponse<T: Decodable>: Decodable {

    let version: String
    let format: String
    let messageType: String?
    let records: [T]?

    enum CodingKeys: String, CodingKey {
        case version = "version"
        case format = "format"
        case messageType = "messageType"
        case records = "records"
    }
}
