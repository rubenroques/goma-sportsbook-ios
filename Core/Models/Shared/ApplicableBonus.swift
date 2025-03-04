//
//  ApplicableBonus.swift
//  Sportsbook
//
//  Created by André Lascas on 24/03/2023.
//

import Foundation

struct ApplicableBonus: Decodable {

    let code: String
    let name: String
    let description: String
    let url: String?
    let html: String?
    let assets: String?

}
