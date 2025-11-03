//
//  SocketParams.swift
//  EveryMatrix Provider
//
//  Created by Ruben Roques on 21/03/2025.
//

import Foundation

/// WAMP WebSocket parameters - now uses EveryMatrixUnifiedConfiguration for environment-based URLs
struct WAMPSocketParams {
    /// WebSocket realm - same for all environments
    static var realm: String {
        return EveryMatrixUnifiedConfiguration.shared.oddsMatrixWebSocketRealm
    }

    /// WebSocket endpoint - environment-dependent
    /// Staging: wss://sportsapi-betsson-stage.everymatrix.com/v2
    /// Production: wss://sportsapi.betssonem.com/v2
    static var wsEndPoint: String {
        let host = EveryMatrixUnifiedConfiguration.shared.oddsMatrixWebSocketURL
        let version = EveryMatrixUnifiedConfiguration.shared.oddsMatrixWebSocketVersion
        return "\(host)/\(version)"
    }

    /// WebSocket origin header - environment-dependent
    /// Staging: https://sportsbook-stage.gomagaming.com
    /// Production: https://sportsbook.gomagaming.com
    static var origin: String {
        return EveryMatrixUnifiedConfiguration.shared.oddsMatrixWebSocketOrigin
    }
}



/*
 ----
 old envs
 
     static let realm = "www.betsson.cm" // "http://www.jetbull.com" // "www.betsson.cm"
     static let wsEndPoint = "wss://sportsapi-betsson-stage.everymatrix.com/v2"
     static let origin = "https://sportsbook-stage.gomagaming.com"
 
 
 // "wss://api-stage.everymatrix.com/v2/"
 // "wss://api-stage.everymatrix.com/v2"
 // "wss://api-phoenix-stage.everymatrix.com/v2/"
 // "wss://api-ndwstage.everymatrix.com/v2/"
 // static let wsEndPoint = "wss://sportsapi-betsson-stage.everymatrix.com/v2/"
 ----
 */
