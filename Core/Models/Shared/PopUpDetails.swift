//
//  PopUpDetails.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/09/2021.
//

import Foundation

struct PopUpDetails: Codable {

    let id: String
    let type: String
    let title, subtitle, textTile, text: String?
    let promoButtonText: String?
    let closeButtonText: String?
    let coverImage: String?
    let linkURL: String?
    let intervalMinutes: Int?

    enum CodingKeys: String, CodingKey {
        case id, type
        case text, title, subtitle
        case promoButtonText = "promo_btn_text"
        case closeButtonText = "close_btn_text"
        case coverImage = "cover_image"
        case textTile = "text_tile"
        case linkURL = "link_ios"
        case intervalMinutes = "interv_min"
    }

}
