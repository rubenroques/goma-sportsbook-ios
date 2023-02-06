//
//  File.swift
//
//
//  Created by Ruben Roques on 21/11/2022.
//

import Foundation

struct SportRadarConstants {

//    =======================================
//       GOMA ENV
//    =======================================

    //Events via socket
    static var socketHostname = "wss://velnt-spor-int.optimahq.com"
    static var socketURL: String {
        return socketHostname + "/notification/listen/websocket"
    }
    static var socketRestHostname = "https://www-sportbook-goma-int.optimahq.com" // To subscribe to contentIDs
    static var socketLanguageCode = "UK"

    // PAM
    //static var pamHostname = "https://ps.omegasys.eu"
    static var pamHostname = "https://bfr-ps.omegasys.eu"

    // Betting
    static var bettingHostname = "https://www-sportbook-goma-int.optimahq.com"

    // Others
    static var sportRadarFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================



//    =======================================
//       BETSSON
//    =======================================

//    //Events via socket
//    static var socketHostname = "wss://velnt-bson-ssb-ua.betsson.fr"
//    static var socketURL: String {
//        return socketHostname + "/notification/listen/websocket"
//    }
//    static var socketRestHostname = "https://www-bson-ssb-uat.betsson.fr" // To subscribe to contentIDs
//    static var socketLanguageCode = "UK"
//
//    // PAM
//    // //static var pamHostname = "https://ps.omegasys.eu"
//    static var pamHostname = "https://bfr-ps.omegasys.eu"
//    // Betting
//    static var bettingHostname = "https://www-bson-ssb-uat.betsson.fr"
//
//    // Others
//    static var sportRadarFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================


//    =======================================
//       DEMO VIDEO ENV
//    =======================================

    //Events via socket
//    static var socketHostname = "wss://velnt-spor-uat.optimahq.com"
//    static var socketURL: String {
//        return socketHostname + "/notification/listen/websocket"
//    }
//    static var socketRestHostname = "https://www-pam-uat.optimahq.com" // To subscribe to contentIDs
//    static var socketLanguageCode = "UK"
//
//    // PAM
//    // //static var pamHostname = "https://ps.omegasys.eu"
//    static var pamHostname = "https://bfr-ps.omegasys.eu"
//    // Betting
//    static var bettingHostname = "https://www-pam-uat.optimahq.com"
//
//    // Others
//    static var sportRadarFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================

}
