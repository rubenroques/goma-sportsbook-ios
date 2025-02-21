import Foundation

/// Represents all possible URL endpoints categories in the application
enum URLEndpoint {

    struct APIs: Hashable {
        let gomaGaming: String
        let sportsbook: String
        let firebase: String
        let casino: String
        let promotions: String

        static var empty: APIs {
            APIs(gomaGaming: "", sportsbook: "", firebase: "", casino: "", promotions: "")
        }
    }

    struct Support: Hashable {
        let helpCenter: String
        let zendesk: String
        let customerSupport: String

        static var empty: Support {
            Support(helpCenter: "", zendesk: "", customerSupport: "")
        }
    }

    struct ResponsibleGaming: Hashable {
        let sosjoueurs: String
        let gamban: String
        let evalujeu: String
        let bettorTime: String
        let jouersInfoService: String
        let anj: String
        let eEnfance: String
        let chuNimes: String

        static var empty: ResponsibleGaming {
            ResponsibleGaming(
                sosjoueurs: "",
                gamban: "",
                evalujeu: "",
                bettorTime: "",
                jouersInfoService: "",
                anj: "",
                eEnfance: "",
                chuNimes: ""
            )
        }
    }

    struct SocialMedia: Hashable {
        let facebook: String
        let twitter: String
        let youtube: String
        let instagram: String

        static var empty: SocialMedia {
            SocialMedia(facebook: "", twitter: "", youtube: "", instagram: "")
        }
    }
}

/// Protocol to be implemented by each client to provide their specific URLs
protocol URLEndpointProvider {
    static var api: URLEndpoint.APIs { get }
    static var support: URLEndpoint.Support { get }
    static var responsibleGaming: URLEndpoint.ResponsibleGaming { get }
    static var socialMedia: URLEndpoint.SocialMedia { get }
}

/// Default implementation for optional endpoints
extension URLEndpointProvider {
    static var api: URLEndpoint.APIs { .empty }
    static var support: URLEndpoint.Support { .empty }
    static var responsibleGaming: URLEndpoint.ResponsibleGaming { .empty }
    static var socialMedia: URLEndpoint.SocialMedia { .empty }
}
