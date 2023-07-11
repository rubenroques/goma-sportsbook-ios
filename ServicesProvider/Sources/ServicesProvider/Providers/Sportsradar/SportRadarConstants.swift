//
//  File.swift
//
//
//  Created by Ruben Roques on 21/11/2022.
//

import Foundation
import Extensions

struct SportRadarConstants {

//    =======================================
//       GOMA ENV
//    =======================================

//    Events via socket
//
//    static var socketHostname = "wss://velnt-spor-int.optimahq.com"
//    static var socketURL: String {
//        return socketHostname + "/notification/listen/websocket"
//    }
//    static var servicesRestHostname = "https://www-sportbook-goma-int.optimahq.com" // To subscribe to contentIDs
//    static var socketLanguageCode = "UK"
//
//    // PAM
//    //static var pamHostname = "https://ps.omegasys.eu"
//    static var pamHostname = "https://bfr-ps.omegasys.eu"
//
//    // Betting
//    static var apiRestHostname = "https://www-sportbook-goma-int.optimahq.com"
//
//    // Others
//    static var sportRadarFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================


//    =======================================
//       BETSSON
//    =======================================
//
//    //Events via socket
    static var socketHostname = "wss://velnt-bson-ssb-ua.betsson.fr"
    static var socketURL: String {
        return socketHostname + "/notification/listen/websocket"
    }
    static var servicesRestHostname = "https://www-bson-ssb-ua.betsson.fr"

    static var servicesSubscribeRestHostname = "https://velsv-bson-ssb-ua.betsson.fr" // To subscribe to contentIDs, as in velsv-bson-ssb-ua.betsson.fr/services

    static var socketLanguageCode = "FR" // Localization.localized("sportradar_content_languange_code")

    // PAM
    // //static var pamHostname = "https://ps.omegasys.eu"
    static var pamHostname = "https://ips-stg.betsson.fr"
    // Betting
    static var apiRestHostname = "https://api-bson-ssb-ua.betsson.fr" // as in api-bson-ssb-ua.betsson.fr/API

    // Others
    static var sportRadarFrontEndURL = "https://cdn1-bson-ssb-ua.betsson.fr"

    // Support
    static var supportHostname = "https://betssonfrance.zendesk.com"

    // Sumsub
    static var sumsubHostname = "https://api.sumsub.com"

    static var frontEndCode = "1356"
    
    //static var sportRadarLegacyFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================


//    =======================================
//       DEMO VIDEO ENV
//    =======================================
//
//    Events via socket
//
//    static var socketHostname = "wss://velnt-spor-uat.optimahq.com"
//    static var socketURL: String {
//        return socketHostname + "/notification/listen/websocket"
//    }
//    static var servicesRestHostname = "https://www-pam-uat.optimahq.com" // To subscribe to contentIDs
//    static var socketLanguageCode = "UK"
//
//    // PAM
//    // //static var pamHostname = "https://ps.omegasys.eu"
//    static var pamHostname = "https://bfr-ps.omegasys.eu"
//    // Betting
//    static var apiRestHostname = "https://www-pam-uat.optimahq.com"
//
//    // Others
//    static var sportRadarFrontEndURL = "https://cdn1.optimahq.com"

//    ===================================================================================================================

}

