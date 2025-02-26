//
//  ManagedContentProvider.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Protocol for accessing managed content from external CMS systems
///
/// This protocol provides methods for retrieving promotional and templated content
/// used throughout the application, including banners, stories, news, and other promotional items.
public protocol ManagedContentProvider: Connector {

    // MARK: - Home Template

    /// Retrieves the home template configuration for the current platform
    /// - Returns: Publisher that emits the home template or an error
    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError>

    // MARK: - Alert Banner

    /// Retrieves the currently active alert banner, if any
    /// - Returns: Publisher that emits the alert banner or nil if none is active
    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError>

    // MARK: - Banners

    /// Retrieves promotional banners
    /// - Returns: Publisher that emits an array of banners
    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError>

    // MARK: - Sport Banners

    /// Retrieves sport-specific promotional banners
    /// - Returns: Publisher that emits an array of sport banners
    func getSportBanners() -> AnyPublisher<[SportBanner], ServiceProviderError>

    // MARK: - Boosted Odds

    /// Retrieves boosted odds banners
    /// - Returns: Publisher that emits an array of boosted odds banners
    func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsBanner], ServiceProviderError>

    // MARK: - Hero Cards

    /// Retrieves hero cards for featured promotions
    /// - Returns: Publisher that emits an array of hero cards
    func getHeroCards() -> AnyPublisher<[HeroCard], ServiceProviderError>

    // MARK: - Stories

    /// Retrieves ephemeral promotional stories
    /// - Returns: Publisher that emits an array of stories
    func getStories() -> AnyPublisher<[Story], ServiceProviderError>

    // MARK: - News

    /// Retrieves news articles
    /// - Parameters:
    ///   - pageIndex: The page index for pagination (starting at 0)
    ///   - pageSize: The number of items per page
    /// - Returns: Publisher that emits an array of news items
    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError>

    // MARK: - Pro Choices

    /// Retrieves expert betting tips
    /// - Returns: Publisher that emits an array of pro choices
    func getProChoices() -> AnyPublisher<[ProChoice], ServiceProviderError>

    // MARK: - Dynamic Content

    /// Retrieves content based on the section type from the home template
    /// - Parameters:
    ///   - sectionType: The type of section as defined in the template
    ///   - options: Additional options for the request, as specified in the template
    /// - Returns: Publisher that emits the appropriate content for the section
    func getContentForSection(sectionType: String, options: [String: Any]?) -> AnyPublisher<Any, ServiceProviderError>

    // MARK: - Cache Management

    /// Invalidates all cached content
    func invalidateCache()

    /// Invalidates specific cached content by type
    /// - Parameter contentType: The type of content to invalidate
    func invalidateCache(for contentType: ManagedContentType)
}

/// Types of managed content for cache invalidation
enum ManagedContentType {
    case homeTemplate
    case alertBanner
    case banners
    case sportBanners
    case boostedOddsBanners
    case heroCards
    case stories
    case news
    case proChoices
}