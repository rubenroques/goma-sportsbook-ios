//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation
import Core

struct TargetVariables: SportsbookTarget {

    // MARK: - URLEndpointProvider Implementation

    static var apiEndpoints: Set<URLEndpoint.API> {
        [
            .gomaGaming(url: "https://gomagaming.com"),
            .sportsbook(url: "https://goma-uat.betsson.fr"),
            .firebase(url: "https://goma-sportsbook-sportradar-viab-95a78.europe-west1.firebasedatabase.app/"),
            .casino(url: "https://sportsbook-cms.gomagaming.com/casino/"),
            .promotions(url: "https://sportradar.gomadevelopment.pt")
        ]
    }

    static var supportEndpoints: Set<URLEndpoint.Support> {
        [
            .helpCenter(url: "https://support.betsson.fr/hc/fr"),
            .zendesk(url: "https://betssonfrance.zendesk.com/hc/fr"),
            .customerSupport(url: "https://betssonfrance.zendesk.com")
        ]
    }

    static var responsibleGamingEndpoints: Set<URLEndpoint.ResponsibleGaming> {
        [
            .sosjoueurs(url: "https://sosjoueurs.org/"),
            .gamban(url: "https://gamban.com/fr/"),
            .evalujeu(url: "https://www.evalujeu.fr/"),
            .bettorTime(url: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1"),
            .jouersInfoService(url: "https://www.joueurs-info-service.fr/"),
            .anj(url: "https://anj.fr/"),
            .eEnfance(url: "https://e-enfance.org/informer/controle-parental/"),
            .chuNimes(url: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html")
        ]
    }

    static var socialMediaEndpoints: Set<URLEndpoint.SocialMedia> {
        [
            .facebook(url: "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR"),
            .twitter(url: "https://twitter.com/BetssonFR"),
            .youtube(url: "https://www.youtube.com/channel/UCVYLZg-cDBbe1h8ege0N5Eg"),
            .instagram(url: "https://www.instagram.com/betsson_france/")
        ]
    }

    // MARK: - Other SportsbookTarget Requirements

    static var environmentType: EnvironmentType = .prod

    static var gomaGamingHost: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com"
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
        return Theme.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

    static var competitionListStyle: CompetitionListStyle {
        return .toggle
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
        return HomeTemplateBuilderType.clientDynamic
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
        return [SportsbookSupportedLanguage.french]
    }

    static var clientBaseUrl: String {
        return "https://goma-uat.betsson.fr"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let promotionsEndpoint = apiEndpoints.first(where: { 
            if case .promotions = $0 { return true }
            return false
        })
        let baseUrl = promotionsEndpoint?.url ?? ""
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
