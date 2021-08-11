//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

var Env = Environment()

struct Environment {

    let networkManager = NetworkManager()
    var deviceId: String {
        "61F9A5CC2906"
    }

}
