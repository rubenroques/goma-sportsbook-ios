//
//  CoreClientProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

/// Protocol to be implemented by each client to provide their specific URLs
protocol SportsbookClient {

}

protocol SportsbookTarget: SportsbookClient, URLEndpointProvider {

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

    static var enableDeveloperSettings: Bool { get }

    // static var registerFlowType: RegisterFlowType { get }

    static var links: URLEndpoint.Links { get }

}

enum SportsbookTargetFeatures: Codable, CaseIterable {
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
    
    case mixMatch
        
    case homeTickets
    
    case userWalletBalance
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
    private static var dynamicFeatureOverrides: Set<SportsbookTargetFeatures>? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "DynamicFeatureOverrides") else { return nil }
            return try? JSONDecoder().decode(Set<SportsbookTargetFeatures>.self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: "DynamicFeatureOverrides")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "DynamicFeatureOverrides")
            }
            NotificationCenter.default.post(.targetFeaturesDidChange)
        }
    }
    
    static func getCurrentFeatures() -> [SportsbookTargetFeatures] {
        return dynamicFeatureOverrides?.map { $0 } ?? Self.features
    }
    
    static func setDynamicFeatures(_ features: [SportsbookTargetFeatures]) {
        dynamicFeatureOverrides = Set(features)
    }
    
    static func resetToDefaultFeatures() {
        dynamicFeatureOverrides = nil
    }
    
    static func hasFeatureEnabled(feature: SportsbookTargetFeatures) -> Bool {
        return getCurrentFeatures().contains(feature)
    }
}

extension SportsbookTarget {

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
        let baseUrl = self.links.api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        return "\(baseUrl)/\(forAppLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
    }

    static var localizationOverrides: [String: String] {
        return [:]
    }
    
    static var links: URLEndpoint.Links {
        return URLEndpoint.Links.empty
    }
    
    static var enableDeveloperSettings: Bool {
        return true
    }

}
