import Foundation

/// Represents all possible URL endpoints categories in the application
enum URLEndpoint {

    /// Authentication and API endpoints
    enum API: CaseIterable, Codable, Hashable, Equatable {
        case gomaGaming(url: String)
        case sportsbook(url: String)
        case firebase(url: String)
        case casino(url: String)
        case promotions(url: String)

        var url: String {
            switch self {
            case .gomaGaming(let url),
                 .sportsbook(let url),
                 .firebase(let url),
                 .casino(let url),
                 .promotions(let url):
                return url
            }
        }

        static var allCases: [API] {
            [
                .gomaGaming(url: ""),
                .sportsbook(url: ""),
                .firebase(url: ""),
                .casino(url: ""),
                .promotions(url: "")
            ]
        }
    }

    /// Support and Help Center endpoints
    enum Support: CaseIterable, Codable, Hashable, Equatable {
        case helpCenter(url: String)
        case zendesk(url: String)
        case customerSupport(url: String)

        var url: String {
            switch self {
            case .helpCenter(let url),
                 .zendesk(let url),
                 .customerSupport(let url):
                return url
            }
        }

        static var allCases: [Support] {
            [
                .helpCenter(url: ""),
                .zendesk(url: ""),
                .customerSupport(url: "")
            ]
        }
    }

    /// Responsible Gaming endpoints
    enum ResponsibleGaming: CaseIterable, Codable, Hashable, Equatable {
        case sosjoueurs(url: String)
        case gamban(url: String)
        case evalujeu(url: String)
        case bettorTime(url: String)
        case jouersInfoService(url: String)
        case anj(url: String)
        case eEnfance(url: String)
        case chuNimes(url: String)

        var url: String {
            switch self {
            case .sosjoueurs(let url),
                 .gamban(let url),
                 .evalujeu(let url),
                 .bettorTime(let url),
                 .jouersInfoService(let url),
                 .anj(let url),
                 .eEnfance(let url),
                 .chuNimes(let url):
                return url
            }
        }

        static var allCases: [ResponsibleGaming] {
            [
                .sosjoueurs(url: ""),
                .gamban(url: ""),
                .evalujeu(url: ""),
                .bettorTime(url: ""),
                .jouersInfoService(url: ""),
                .anj(url: ""),
                .eEnfance(url: ""),
                .chuNimes(url: "")
            ]
        }
    }

    /// Social Media endpoints
    enum SocialMedia: CaseIterable, Codable, Hashable, Equatable {
        case facebook(url: String)
        case twitter(url: String)
        case youtube(url: String)
        case instagram(url: String)

        var url: String {
            switch self {
            case .facebook(let url),
                 .twitter(let url),
                 .youtube(let url),
                 .instagram(let url):
                return url
            }
        }

        static var allCases: [SocialMedia] {
            [
                .facebook(url: ""),
                .twitter(url: ""),
                .youtube(url: ""),
                .instagram(url: "")
            ]
        }
    }
}

/// Protocol to be implemented by each client to provide their specific URLs
protocol URLEndpointProvider {
    static var apiEndpoints: Set<URLEndpoint.API> { get }
    static var supportEndpoints: Set<URLEndpoint.Support> { get }
    static var responsibleGamingEndpoints: Set<URLEndpoint.ResponsibleGaming> { get }
    static var socialMediaEndpoints: Set<URLEndpoint.SocialMedia> { get }
}

/// Default implementation for optional endpoints
extension URLEndpointProvider {
    static var apiEndpoints: Set<URLEndpoint.API> { [] }
    static var supportEndpoints: Set<URLEndpoint.Support> { [] }
    static var responsibleGamingEndpoints: Set<URLEndpoint.ResponsibleGaming> { [] }
    static var socialMediaEndpoints: Set<URLEndpoint.SocialMedia> { [] }
}
