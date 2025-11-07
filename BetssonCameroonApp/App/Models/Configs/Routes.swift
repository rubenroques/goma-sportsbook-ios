//
//  Route.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

enum Route {
    case register
    case login
    case sportsHome
    case liveGames
    case myBets
    case sportsSearch
    case casinoHome
    case casinoVirtuals
    case casinoGame(gameId: String)
    case casinoSearch
    case deposit
    case promotions
    case bonus
    case event(id: String)
    case competition(id: String)
    case none
}
