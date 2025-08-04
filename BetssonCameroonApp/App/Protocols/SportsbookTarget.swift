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
    
    static var firebaseDatabaseURL: String { get }

    static var supportedThemes: [AppearanceMode] { get }
    
    static var links: URLEndpoint.Links { get }
    
    static func hasFeatureEnabled(feature: SportsbookTargetFeatures) -> Bool
    static var features: [SportsbookTargetFeatures] { get }
    static var userRequiredFeatures: [SportsbookTargetFeatures] { get }
    
    static var serviceProviderEnvironment: EnvironmentType { get }

    static var supportedLanguages: [SportsbookSupportedLanguage] { get }
    
    static var serviceProviderType: ServiceProviderType { get }
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
            NotificationCenter.default.post(name: Notification.Name.targetFeaturesChanged, object: nil)
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

/*
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

    static var shouldUseBlurEffectTabBar: Bool {
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

}
*/
