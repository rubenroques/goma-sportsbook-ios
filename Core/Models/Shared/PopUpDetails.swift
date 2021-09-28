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

    static var test: PopUpDetails {
        PopUpDetails(id: 2, type: 1,
                     title: "SERIE A IS COMING!",
                     subtitle: "DEPOSIT 20€ AND GET 10€ FREE",
                     textTile: "Get ready Serie A is coming!",
                     text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
                     promoButtonText: "See Promo",
                     closeButtonText: "Maybe Later",
                     coverImage: "https://via.placeholder.com/600x300",
                     linkURL: "https://gomadevelopment.pt/")
    }
}
