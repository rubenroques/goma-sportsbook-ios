//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    #if DEBUG
    static var environmentType: EnvironmentType = .dev
    #else
    static var environmentType: EnvironmentType = .prod
    #endif

    static var gomaGamingHost: String {
        return "https://sportsbook-api.gomagaming.com"
    }

    static var gomaGamingAnonymousAuthEndpoint: String {
        "https://sportsbook-api.gomagaming.com/api/auth/v1"
    }

    static var gomaGamingLoggedAuthEndpoint: String {
        "https://sportsbook-api.gomagaming.com/api/auth/v1/login"
    }

    static var firebaseDatabaseURL: String {
        #if DEBUG
        "https://goma-sportsbook-ios-dev.europe-west1.firebasedatabase.app/"
        #else
        "https://goma-sportsbook-dev.europe-west1.firebasedatabase.app/"
        // "ht tps://goma-sportsbook.europe-west1.firebasedatabase.app/"
        #endif
    }

    static var homeTemplateKey: String? {
        return "everymatrix"
    }

    static var everyMatrixHost: String {
        return ""
    }

    static var supportedThemes: [Theme] {
        return Theme.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .small
    }
    
    static var casinoURL: String {
        return "https://sportsbook-cms.gomagaming.com/casino/"
    }
    
    static var serviceProviderType: ServiceProviderType {
        return .everymatrix
    }

    static var features: [SportsbookTargetFeatures] {
        return SportsbookTargetFeatures.allCases
    }
    
}
