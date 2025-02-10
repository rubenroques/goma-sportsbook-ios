//
//  ClientVariables.swift
//  DAZN
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {
        
    static var environmentType: EnvironmentType = .prod
    
    static var gomaGamingHost: String {
        return "https://sportsbook-api.gomagaming.com"
    }
    
    static var gomaGamingAnonymousAuthEndpoint: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com/api/auth/v1"
    }

    static var gomaGamingLoggedAuthEndpoint: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com/api/auth/v1/login"
    }

    static var firebaseDatabaseURL: String {
        return "https://goma-sportsbook-sportradar-viab-95a78.europe-west1.firebasedatabase.app/"
    }

    static var supportedThemes: [Theme] {
        return [Theme.dark]
    }
    
    static var defaultCardStyle: CardsStyle {
        return .normal
    }
    
    static var competitionListStyle: CompetitionListStyle {
        return .navigateToDetails
    }

    static var defaultOddsValueType: OddsValueType {
        return .allOdds
    }

    static var casinoURL: String {
        return "https://sportsbook-cms.gomagaming.com/casino/"
    }
    
    static var serviceProviderType: ServiceProviderType {
        return .sportradar
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        // return HomeTemplateBuilderType.backendDynamic(clientTemplateKey: "dazn")
        return HomeTemplateBuilderType.dummyWidgetShowcase(widgets: [
            // .userProfile, // AlertBanners
            // .bannerLine, // PromotionBanners
            // .quickSwipeStack, // MatchBanners
            // .promotionalStories, // PromotionStories - instagram style stories
            // .heroCard, // HeroBanner
            .highlightedLiveMatches, // LiveGamesHome
            // .makeOwnBetCallToAction, // MakeYourOwnBet
            .highlightedMatches, // Highlights image cards
            .videoNewsLine, // Video news cards
            // .highlightedMarketProChoices, // Pro Choices Markets
            .highlightedBoostedOddsMatches, // Boosted Odds
            .topCompetitionsShortcuts, // TopCompetitionsMobile
            .featuredTips, // SuggestedBets
        ])
    }

    static var features: [SportsbookTargetFeatures] {
        return [.cashback]
    }

    static var shouldUserBlurEffectTabBar: Bool {
        return true
    }

    static var shouldUseGradientBackgrounds: Bool {
        return true
    }

    static var shouldUseAlternateTopBar: Bool {
        return true
    }
    
    static var serviceProviderEnvironment: EnvironmentType {
        return .dev
    }
    
    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return SportsbookSupportedLanguage.allCases
    }

    static var clientBaseUrl: String {
        return "https://goma-uat.betsson.fr"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = "https://sportradar.gomadevelopment.pt"
        let isDarkThemeString = isDarkTheme?.description ?? ""
        let urlString = "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
        return urlString
    }

    static var appStoreUrl: String? {
        return "https://apps.apple.com/"
    }

    static var secundaryMarketSpecsUrl: String? {
        return "https://goma-uat.betsson.fr/secondary_markets_config.json"
    }

    static var knowYourClientLevels: [KnowYourCustomerLevel: String] {
        return [.identification: "kyc-level-1-id-verification-UAT",
                .proofOfAddress: "kyc-level-2-poa-verification-UAT",
                .bankAccountIdentification: "RIB Verification"]
    }

    static var localizationOverrides: [String: String] {
        return [
            "anj_authorization_text": "SportRadar.fr est édité par SportRadar, société de droit maltais, titulaire des licences n# délivrées par l'ANJ le 01/01/2025",
            "app_version_profile": "App Version {version_1} ({version_2})\n® Tous droits réservés",
            "app_version_profile_1": "App Version {version_1} ({version_2})",
            "app_version_profile_2": "® Tous droits réservés",
        ]
    }
    
}
