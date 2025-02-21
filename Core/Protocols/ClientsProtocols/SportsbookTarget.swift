//
//  CoreClientProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

protocol SportsbookClient {

}

protocol SportsbookTarget: URLEndpointProvider {

    static var environmentType: EnvironmentType { get }

    static var supportedThemes: [Theme] { get }

    static var supportedCardStyles: [CardsStyle] { get }
    static var defaultCardStyle: CardsStyle { get }

    static var competitionListStyle: CompetitionListStyle { get }

    static var serviceProviderType: ServiceProviderType { get }

    static var homeTemplateBuilder: HomeTemplateBuilderType { get }

    static var features: [SportsbookTargetFeatures] { get }

    static func hasFeatureEnabled(feature: SportsbookTargetFeatures) -> Bool

    static var shouldUserBlurEffectTabBar: Bool { get }

    static var shouldUseGradientBackgrounds: Bool { get }

    static var serviceProviderEnvironment: EnvironmentType { get }

    static var supportedLanguages: [SportsbookSupportedLanguage] { get }

    static func generatePromotionsPageUrlString(forAppLanguage: String?, isDarkTheme: Bool?) -> String

    static var knowYourClientLevels: [KnowYourCustomerLevel: String] { get }

    static var localizationOverrides: [String: String] { get }
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

    case responsibleGamingForm
    case legalAgeWarning
}

enum SportsbookSupportedLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"

    var languageCode: String {
        return self.rawValue
    }
}

enum KnowYourCustomerLevel: Int, CaseIterable {
    case identification = 1
    case proofOfAddress = 2
    case bankAccountIdentification = 3
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

    static var supportedCardStyles: [CardsStyle] {
        return CardsStyle.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

    static var competitionListStyle: CompetitionListStyle {
        return .toggle
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

    static var knowYourClientLevels: [KnowYourCustomerLevel: String] {
        return [:]
    }

    static func generatePromotionsPageUrlString(forAppLanguage: String?, isDarkTheme: Bool?) -> String {
        let promotionsEndpoint = apiEndpoints.first(where: {
            if case .promotions = $0 { return true }
            return false
        })
        let baseUrl = promotionsEndpoint?.url ?? ""
        let isDarkThemeString = isDarkTheme?.description ?? ""
        return "\(baseUrl)/\(forAppLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
    }

    static var localizationOverrides: [String: String] {
        return [:]
    }
}
