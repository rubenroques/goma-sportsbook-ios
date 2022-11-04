//
//  OmegaSessionCredentials.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation
import Combine

struct OmegaSessionAccessToken: SessionAccessToken {
    var hash: String
}

struct OmegaSessionCredentials {
    var username: String
    var password: String
}
