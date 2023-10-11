//
//  CoreClientProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

protocol SportsbookClient {

}

protocol SportsbookTarget {

    static var environmentType: EnvironmentType { get }

    static var gomaGamingHost: String { get }

    static var gomaGamingAnonymousAuthEndpoint: String { get }
    static var gomaGamingLoggedAuthEndpoint: String { get }

    static var firebaseDatabaseURL: String { get }
    
    static var everyMatrixHost: String { get }

    static var supportedThemes: [Theme] { get }

    static var defaultCardStyle: CardsStyle { get }
    
    static var serviceProviderType: ServiceProviderType { get }

    static var homeTemplateBuilder: HomeTemplateBuilderType { get }
    
    static var casinoURL: String { get }

    static var features: [SportsbookTargetFeatures] { get }

    static func hasFeatureEnabled(feature: SportsbookTargetFeatures) -> Bool

    static var shouldUserBlurEffectTabBar: Bool { get }

    static var shouldUseGradientBackgrounds: Bool { get }

    static var serviceProviderEnvironment: EnvironmentType { get }
    
    static var supportedLanguages: [SportsbookSupportedLanguage] { get }

    static var clientBaseUrl: String { get }
    
}

enum SportsbookTargetFeatures: CaseIterable {
    case homeBanners
    case homePopUps

    case getLocationLimits

    case favoriteEvents
    case favoriteCompetitions

    case eventStats
    case eventListFilters

    case betsNotifications
    case eventsNotifications

    case chat
    case tips

    case suggestedBets
    case cashout
    case cashback
    case freebets

    case casino
}

enum SportsbookSupportedLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"
    
    var languageCode: String {
        return self.rawValue
    }
}

extension SportsbookTarget {

    static func hasFeatureEnabled(feature: SportsbookTargetFeatures) -> Bool {
        for enabledFeature in Self.features {
            if feature == enabledFeature {
                return true
            }
        }
        return false
    }

    static var shouldUserBlurEffectTabBar: Bool {
        return false
    }

    static var shouldUseGradientBackgrounds: Bool {
        return false
    }
    
    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return SportsbookSupportedLanguage.allCases
    }

}
