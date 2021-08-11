//
//  NetworkModels.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
//

import Foundation

struct NetworkResponse<T: Decodable>: Decodable {

    let status: String
    let message: String
    let data: T

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}

struct ExampleModel: Decodable {

    let userId: Int
    let deviceId: String
    let deviceType: String

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case deviceId = "device_uuid"
        case deviceType = "device_type"
    }

}

