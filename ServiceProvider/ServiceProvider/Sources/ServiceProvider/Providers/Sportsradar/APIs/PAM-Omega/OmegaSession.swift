//
//  OmegaSessionCredentials.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation
import Combine

struct OmegaSessionAccessToken {
    var sessionKey: String
    var launchKey: String?
}

struct OmegaSessionCredentials {
    var username: String
    var password: String
}
