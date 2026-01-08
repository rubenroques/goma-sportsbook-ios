//
//  NetworkModels.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
//

import Foundation

struct MessageNetworkResponse: Decodable {

    let status: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }

    static let forbiden: MessageNetworkResponse = MessageNetworkResponse(status: "error", message: "User Access Denied!")
    static let failed: MessageNetworkResponse = MessageNetworkResponse(status: "error", message: "Failed request")

}

struct NetworkResponse<T: Decodable>: Decodable {

    let status: String
    let message: String
    let data: T?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}
