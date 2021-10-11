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

//    static var test: PopUpDetails {
//        PopUpDetails(id: 2, type: 2,
//                     title: "SERIE A IS COMING!",
//                     subtitle: "DEPOSIT 20€ AND GET 10€ FREE",
//                     textTile: "Get ready Serie A is coming!",
//                     text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
//                     promoButtonText: "See Promo",
//                     closeButtonText: "Maybe Later",
//                     coverImage: "https://www.abola.pt/img/fotos/abola2015/FOTOSAP/INGLATERRA/2021/ronaldoSolskjaer1.jpg",
//                     linkURL: "https://gomadevelopment.pt/",
//                     intervalMinutes: 2)
//    }
}
