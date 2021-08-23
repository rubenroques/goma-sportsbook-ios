//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

var Env = Environment() // swiftlint:disable:this identifier_name

struct Environment {

    let networkManager = NetworkManager()
    var deviceId: String {
        "61F9A5CC2906"
    }
    var isMaintenance = false
    var appUpdateType = ""
    var userLat = ""
    var userLong = ""

}
