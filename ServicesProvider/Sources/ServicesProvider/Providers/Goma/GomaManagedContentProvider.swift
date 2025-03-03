//
//  GomaManagedContentProvider.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Implementation of ManagedContentProvider for the Goma API
class GomaManagedContentProvider: ManagedContentProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)
    private let authenticator: GomaAPIAuthenticator
    private let apiClient: GomaAPIPromotionsClient

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(gomaAPIAuthenticator: GomaAPIAuthenticator = GomaAPIAuthenticator(deviceIdentifier: "") ) {
        self.authenticator = gomaAPIAuthenticator

        self.apiClient = GomaAPIPromotionsClient(
            connector: GomaConnector(gomaAPIAuthenticator: gomaAPIAuthenticator),
            cache: GomaAPIPromotionsCache()
        )
    }

    func invalidateCache() {
        self.apiClient.clearCache()
    }

    // MARK: - API Request Helper

    private func request<T: Decodable>(_ endpoint: GomaAPIPromotionsSchema) -> AnyPublisher<T, ServiceProviderError> {
        // This is a simplified placeholder for API requests
        // In a real implementation, you would handle authentication and network requests here
        return Fail(error: ServiceProviderError.notSupportedForProvider)
            .eraseToAnyPublisher()
    }

    // MARK: - ManagedContentProvider Implementation
    func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {

        return self.apiClient.preFetchHomeContent()
            .map({ (initialDump: GomaModels.InitialDump) in
                return GomaModelMapper.initialDump(fromInternalInitialDump: initialDump)
            })
            .eraseToAnyPublisher()
    }

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {

        return self.apiClient.homeTemplate()
            .map({ internalHomeTemplate in
                return GomaModelMapper.homeTemplate(fromInternalHomeTemplate: internalHomeTemplate)
            })
            .eraseToAnyPublisher()
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {

        return self.apiClient.alertBanner()
            .map({ internalAlertBanner in
                return GomaModelMapper.alertBanner(fromInternalAlertBanner: internalAlertBanner)
            })
            .eraseToAnyPublisher()
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {

        return self.apiClient.banners()
            .map({ internalBanners in
                return internalBanners.map({ internalBanner in
                    return GomaModelMapper.banner(fromInternalBanner: internalBanner)
                })
            })
            .eraseToAnyPublisher()
    }

    func getCarouselEvents() -> AnyPublisher<CarouselEvents, ServiceProviderError> {

        return self.apiClient.carouselEvents()
            .map({ internalCarouselEvents in
                return GomaModelMapper.carouselEvents(fromInternalCarouselEvents: internalCarouselEvents)
            })
            .eraseToAnyPublisher()
    }

    func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsBanner], ServiceProviderError> {

        return self.apiClient.boostedOddsBanners()
            .map({ internalBoostedOddsBanners in
                return GomaModelMapper.boostedOddsBanners(fromInternalBoostedOddsBanners: internalBoostedOddsBanners)
            })
            .eraseToAnyPublisher()
    }

    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return self.apiClient.heroCards()
            .map({ internalHeroCardPointers in
                return GomaModelMapper.heroCardPointers(fromInternalHeroCardPointers: internalHeroCardPointers)
            })
            .eraseToAnyPublisher()
    }
    
    func getHeroCards() -> AnyPublisher<[Event], ServiceProviderError> {
        let endpoint = GomaAPISchema.getHeroCards
        let publisher: AnyPublisher<[GomaModels.HeroCardEvents], ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.print("getHeroCards").map({ heroCardEvents in
            let convertedEvents = heroCardEvents.map({
                return GomaModelMapper.event(fromInternalHeroCardEvent: $0)
            })
            return convertedEvents
        }).eraseToAnyPublisher()
    }

    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {

        return self.apiClient.stories()
            .map({ internalStories in
                return internalStories.map({ internalStory in
                    return GomaModelMapper.story(fromInternalStory: internalStory)
                })
            })
            .eraseToAnyPublisher()
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {

        return self.apiClient.newsItems(pageIndex: pageIndex, pageSize: pageSize)
            .map({ internalNewsItems in
                return GomaModelMapper.newsItems(fromInternalNewsItems: internalNewsItems)
            })
            .eraseToAnyPublisher()
    }

    func getProChoices() -> AnyPublisher<[ProChoice], ServiceProviderError> {

        return self.apiClient.proChoices()
            .map({ internalProChoiceitems in
                return GomaModelMapper.proChoices(fromInternalProChoices: internalProChoiceitems)
            })
            .eraseToAnyPublisher()
    }

}
