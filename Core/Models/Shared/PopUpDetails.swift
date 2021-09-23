//
//  PopUpDetails.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/09/2021.
//

import Foundation

struct PopUpDetails: Codable {
    let id: Int
    let type: Int
    let title, subtitle, textTile, text: String
    let promoButtonText: String
    let closeButtonText: String
    let coverImage: String
    let linkURL: String

    enum CodingKeys: String, CodingKey {
        case id, type
        case text, title, subtitle
        case promoButtonText = "promo_btn_text"
        case closeButtonText = "close_btn_text"
        case coverImage = "cover_image"
        case textTile = "text_tile"
        case linkURL = "link_ios"
    }
}
