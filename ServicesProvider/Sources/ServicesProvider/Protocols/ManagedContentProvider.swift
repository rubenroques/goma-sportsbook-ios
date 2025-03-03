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
protocol ManagedContentProvider: Connector {

    // MARK: - Home Template

    /// Prefetches and caches the home content for faster access
    /// - Returns: A publisher that emits the initial dump data (either from cache or fresh fetch)
    func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError>

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
    func getCarouselEvents() -> AnyPublisher<CarouselEvents, ServiceProviderError>

    // MARK: - Boosted Odds

    /// Retrieves boosted odds banners
    /// - Returns: Publisher that emits an array of boosted odds banners
    func getBoostedOddsPointers() -> AnyPublisher<BoostedOddsPointers, ServiceProviderError>

    /// Retrieves boosted odds events
    /// - Returns: Publisher that emits an array of boosted odds events
    func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError>

    // MARK: - Hero Cards

    /// Retrieves hero cards for featured promotions
    /// - Returns: Publisher that emits an array of hero cards
    func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError>

    /// Retrieves hero cards for featured promotions
    /// - Returns: Publisher that emits an array of hero cards
    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError>

    // MARK: - Top Image Cards

    /// Retrieves top image card pointers
    /// - Returns: Publisher that emits an array of top image card pointers
    func getTopImageCardPointers() -> AnyPublisher<TopImageCardPointers, ServiceProviderError>

    /// Retrieves top image card events
    /// - Returns: Publisher that emits an array of top image card events
    func getTopImageCardEvents() -> AnyPublisher<Events, ServiceProviderError>

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
    func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError>
    
    func getProChoiceMarketCards() -> AnyPublisher<[HighlightMarket], ServiceProviderError>
    
}
