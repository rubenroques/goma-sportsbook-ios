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

    static var supportedThemes: [Theme] {
        return Theme.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

    static var casinoURL: String {
        return "https://sportsbook-cms.gomagaming.com/casino/"
    }

    static var serviceProviderType: ServiceProviderType {
        return .everymatrix
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        return HomeTemplateBuilderType.appStatic
    }

    static var features: [SportsbookTargetFeatures] {
        return []
    }

    static var serviceProviderEnvironment: EnvironmentType {
        return .dev
    }

    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return SportsbookSupportedLanguage.allCases
    }

    static var clientBaseUrl: String {
        return ""
    }

    static var appStoreUrl: String? {
        return nil
    }

    static var secundaryMarketSpecsUrl: String? {
        return nil
    }

    // MARK: - URLEndpointProvider Implementation

    static var api: URLEndpoint.APIs {
        URLEndpoint.APIs(
            gomaGaming: "https://gomagaming.com",
            sportsbook: "https://gomasportradar.betsson.fr",
            firebase: "https://goma-sportsbook-gomasportradar.europe-west1.firebasedatabase.app/",
            casino: "https://sportsbook-cms.gomagaming.com/casino/",
            promotions: "https://gomasportradar.betsson.fr"
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

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        return "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
    }
}
