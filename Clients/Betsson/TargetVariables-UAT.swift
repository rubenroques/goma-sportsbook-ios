//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    // MARK: - URLEndpointProvider Implementation

    static var api: URLEndpoint.APIs {
        URLEndpoint.APIs(
            gomaGaming: "https://gomagaming.com",
            sportsbook: "https://goma-uat.betsson.fr",
            firebase: "https://goma-sportsbook-sportradar-viab-95a78.europe-west1.firebasedatabase.app/",
            casino: "https://sportsbook-cms.gomagaming.com/casino/",
            promotions: "https://goma-uat.betsson.fr"
        )
    }

    static var support: URLEndpoint.Support {
        URLEndpoint.Support(
            helpCenter: "https://support.betsson.fr/hc/fr",
            zendesk: "https://betssonfrance.zendesk.com/hc/fr",
            customerSupport: "https://betssonfrance.zendesk.com"
        )
    }

    static var responsibleGaming: URLEndpoint.ResponsibleGaming {
        URLEndpoint.ResponsibleGaming(
            sosjoueurs: "https://sosjoueurs.org/",
            gamban: "https://gamban.com/fr/",
            evalujeu: "https://www.evalujeu.fr/",
            bettorTime: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1",
            jouersInfoService: "https://www.joueurs-info-service.fr/",
            anj: "https://anj.fr/",
            eEnfance: "https://e-enfance.org/informer/controle-parental/",
            chuNimes: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html"
        )
    }

    static var socialMedia: URLEndpoint.SocialMedia {
        URLEndpoint.SocialMedia(
            facebook: "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR",
            twitter: "https://twitter.com/BetssonFR",
            youtube: "https://www.youtube.com/channel/UCVYLZg-cDBbe1h8ege0N5Eg",
            instagram: "https://www.instagram.com/betsson_france/"
        )
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
        return "https://goma-sportsbook.europe-west1.firebasedatabase.app/"
    }

    static var supportedThemes: [Theme] {
        return Theme.allCases
    }

    static var supportedCardStyles: [CardsStyle] {
        return [CardsStyle.normal]
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
        let promotionsEndpoint = api.promotions
        let baseUrl = promotionsEndpoint ?? ""
        let isDarkThemeString = isDarkTheme?.description ?? ""
        let urlString = "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
        return urlString
    }

    static var appStoreUrl: String? {
        return "https://apps.apple.com/fr/app/betsson/id6463237718"
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
        return [:]
    }
}
