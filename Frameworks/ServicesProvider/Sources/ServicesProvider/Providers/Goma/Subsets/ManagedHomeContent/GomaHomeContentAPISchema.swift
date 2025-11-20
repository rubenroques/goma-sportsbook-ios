//
//  GomaHomeContentAPISchema.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

enum GomaHomeContentAPISchema {
    // Initial Dump
    case initialDump
    
    // Home Template
    case homeTemplate

    // Home widgets contents
    case alertBanner
    case banners
    case sportBanners
    case casinoCarouselBanners
    case boostedOdds
    case topImageCards
    case heroCards
    case stories
    case news(pageIndex: Int, pageSize: Int)
    case proChoices
    case topCompetitions
    case footerLinks(language: String?)
    case footerSponsors(language: String?)
    case footerSocialMedia(language: String?)
    
}

extension GomaHomeContentAPISchema: Endpoint {
    var url: String {
        return GomaAPIClientConfiguration.shared.apiHostname
    }

    var endpoint: String {
        switch self {
        case .initialDump:
            return "/api/initial-dump/v1"
            
        case .homeTemplate:
            return "/api/home/v1/template"

        case .alertBanner:
            return "/api/promotions/v1/alert-banner"
        case .banners:
            return "/api/promotions/v1/banners"
        case .sportBanners:
            return "/api/promotions/v1/sport-banners"
        case .casinoCarouselBanners:
            return "/api/promotions/v1/casino-carousel-banners"
        case .boostedOdds:
            return "/api/promotions/v1/boosted-odds-banners"
        case .topImageCards:
            return "/api/events/v1/highlights"
        case .heroCards:
            return "/api/promotions/v1/hero-cards"
        case .stories:
            return "/api/promotions/v1/stories"
        case .news:
            return "/api/promotions/v1/news"
        case .proChoices:
            return "/api/promotions/v1/pro-choices"
        case .topCompetitions:
            return "/api/competitions/v1/featured"
        case .footerLinks:
            return "/api/cms/v1/footer/links"
        case .footerSponsors:
            return "/api/cms/v1/footer/sponsors"
        case .footerSocialMedia:
            return "/api/cms/v1/footer/social-media"
        }
    }

    var query: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []

        // Always add platform=ios for all endpoints
//        queryItems.append(URLQueryItem(name: "platform", value: "ios"))

        switch self {
        case .news(let pageIndex, let pageSize):
            queryItems.append(URLQueryItem(name: "page", value: "\(pageIndex)"))
            queryItems.append(URLQueryItem(name: "page_size", value: "\(pageSize)"))
            queryItems.append(URLQueryItem(name: "platform", value: "ios"))

        case .initialDump:
            queryItems.append(URLQueryItem(name: "promotions", value: "false"))
            queryItems.append(URLQueryItem(name: "platform", value: "ios"))
        case .footerLinks(let language):
            if let language {
                queryItems.append(URLQueryItem(name: "language", value: language))
            }
            queryItems.append(URLQueryItem(name: "platform", value: "ios"))
        case .footerSponsors(let language):
            if let language {
                queryItems.append(URLQueryItem(name: "language", value: language))
            }
            queryItems.append(URLQueryItem(name: "platform", value: "ios"))
        case .footerSocialMedia(let language):
            if let language {
                queryItems.append(URLQueryItem(name: "language", value: language))
            }
            queryItems.append(URLQueryItem(name: "platform", value: "ios"))

        default:
            break
        }

        return queryItems.isEmpty ? nil : queryItems
    }

    var headers: HTTP.Headers? {
        // Common headers for all API requests
        return [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "App-Origin": "ios"
        ]
    }

    var method: HTTP.Method {
        return .get // All endpoints use GET method
    }

    var body: Data? {
        return nil // None of these endpoints require a request body
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    var timeout: TimeInterval {
        switch self {
        case .homeTemplate:
            return 15.0
        case .news:
            return 20.0
        case .initialDump:
            return 30.0 // Longer timeout since this is a large data dump
        default:
            return 10.0
        }
    }

    var requireSessionKey: Bool {
        return true // Require authentication for all endpoints
    }

    var comment: String? {
        switch self {
        case .homeTemplate:
            return "Get home template configuration"
            
        case .alertBanner:
            return "Get alert banner"
        case .banners:
            return "Get promotional banners"
        case .sportBanners:
            return "Get sport banners"
        case .casinoCarouselBanners:
            return "Get casino carousel banners"
        case .boostedOdds:
            return "Get boosted odds banners"
        case .topImageCards:
            return "Get highilights with the top image card style"
        case .heroCards:
            return "Get hero cards"
        case .stories:
            return "Get promotional stories"
        case .news:
            return "Get news articles"
        case .proChoices:
            return "Get pro betting choices"
        case .topCompetitions:
            return "Get top/featured competitions"
        case .initialDump:
            return "Get initial data dump including sports, competitions, and events"
        case .footerLinks:
            return "Get footer links for the configured client"
        case .footerSponsors:
            return "Get footer sponsor logos for the configured client"
        case .footerSocialMedia:
            return "Get footer social media links for the configured client"
        }
    }
}
