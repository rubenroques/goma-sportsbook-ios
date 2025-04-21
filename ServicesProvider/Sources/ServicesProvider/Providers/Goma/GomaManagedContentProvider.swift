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
    init(gomaAPIAuthenticator: GomaAPIAuthenticator = GomaAPIAuthenticator(deviceIdentifier: "")) {
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
        // TODO: SP Merge Needs tests
        return self.apiClient.banners()
            .map({ internalBanners in
                return internalBanners.map({ internalBanner in
                    return GomaModelMapper.banner(fromInternalBanner: internalBanner)
                })
            })
            .eraseToAnyPublisher()
    }

    func getCarouselEventPointers() -> AnyPublisher<CarouselEventPointers, ServiceProviderError> {

        return self.apiClient.carouselEventPointers()
            .map({ internalCarouselEvents in
                return GomaModelMapper.carouselEventPointers(fromInternalCarouselEventPointers: internalCarouselEvents)
            })
            .eraseToAnyPublisher()
    }
    
    func getCarouselEvents() -> AnyPublisher<Events, ServiceProviderError> {
        // TODO: SP Merge Needs tests
        let endpoint = GomaAPISchema.getEventsBanners
        let publisher: AnyPublisher<GomaModels.HeroCardEvents, ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.map({ heroCardEvents in
            let convertedEvents = heroCardEvents.map({
                return GomaModelMapper.event(fromInternalHeroCardEvent: $0)
            })
            return convertedEvents
        }).eraseToAnyPublisher()
    }

    func getBoostedOddsPointers() -> AnyPublisher<[BoostedOddsPointer], ServiceProviderError> {
        return self.apiClient.boostedOddsPointers()
            .map({ internalBoostedOddsBanners in
                return GomaModelMapper.boostedOddsPointers(fromInternalBoostedOddsPointers: internalBoostedOddsBanners)
            })
            .eraseToAnyPublisher()
    }

    func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        // TODO: SP Merge Needs tests
        let endpoint = GomaAPISchema.getBoostedOddEvents
        let publisher: AnyPublisher<[GomaModels.BoostedOddsEvent], ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.map({ boostedOddEvents in

            let convertedEvents = boostedOddEvents.map({
                return GomaModelMapper.event(fromInternalBoostedOddsEvent: $0)
            })

            return convertedEvents
        }).eraseToAnyPublisher()
    }

    func getTopImageCardPointers() -> AnyPublisher<TopImageCardPointers, ServiceProviderError> {
        return self.apiClient.topImageCardPointers()
            .map({ topImageCardPointers in
                return GomaModelMapper.topImageCardPointers(fromInternaTopImageCardPointers: topImageCardPointers)
            })
            .eraseToAnyPublisher()
    }
    func getTopImageEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return self.apiClient.topImageEvents()
            .map(GomaModelMapper.events(fromInternalEvents:))
            .eraseToAnyPublisher()
    }

    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return self.apiClient.heroCards()
            .map({ internalHeroCardPointers in
                return GomaModelMapper.heroCardPointers(fromInternalHeroCardPointers: internalHeroCardPointers)
            })
            .eraseToAnyPublisher()
    }

    func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        let endpoint = GomaAPISchema.getHeroCards
        let publisher: AnyPublisher<GomaModels.HeroCardEvents, ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.map({ heroCardEvents in
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

    func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError> {
        return self.apiClient.proChoicePointers()
            .map({ pointers in
                return GomaModelMapper.proChoiceCardPointers(fromInternalProChoiceCardPointers: pointers)
            })
            .eraseToAnyPublisher()
    }

    func getProChoiceMarketCards() -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> {
        let transform: ([GomaModels.Event]) -> ImageHighlightedContents<Market> = { events in
            let mappedEvents = GomaModelMapper.events(fromInternalEvents: events)
            let highlightedEvents: [ImageHighlightedContent<Market>] = mappedEvents.compactMap { event -> ImageHighlightedContent<Market>? in
                guard let firstMarket = event.markets.first else { return nil }
                return ImageHighlightedContent(content: firstMarket, promotedChildCount: 3, imageURL: event.promoImageURL)
            }
            return highlightedEvents
        }
        
        return self.apiClient.proChoices()
            .map(transform)
            .eraseToAnyPublisher()
    }


    func getTopCompetitionsPointers() -> AnyPublisher<TopCompetitionPointers, ServiceProviderError> {
        return self.apiClient.topCompetitionPointers()
            .map({ pointers in
                return GomaModelMapper.topCompetitionPointers(fromInternalTopCompetitionPointers: pointers)
            })
            .eraseToAnyPublisher()
    }
    
    func getTopCompetitions() -> AnyPublisher<TopCompetitions, ServiceProviderError> {
        return self.apiClient.topCompetitions()
            .map({ (competitions: GomaModels.Competitions) in
                return GomaModelMapper.topCompetitions(fromCompetitions: competitions)
            })
            .eraseToAnyPublisher()
    }
    
    func getPromotions() -> AnyPublisher<[PromotionInfo], ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.allPromotions
        
        let publisher: AnyPublisher<[GomaModels.PromotionInfo], ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.map({ promotionsInfo in
            let convertedPromotionsResponse = promotionsInfo.map({
                GomaModelMapper.promotionInfo(fromInternalPromotionInfo: $0)
            })
            return convertedPromotionsResponse
        }).eraseToAnyPublisher()
    }

    func getPromotionDetails(promotionSlug: String, staticPageSlug: String) -> AnyPublisher<PromotionInfo, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.promotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug)
        
        let publisher: AnyPublisher<GomaModels.PromotionInfo, ServiceProviderError> = self.apiClient.requestPublisher(endpoint)
        return publisher.map({ promotionInfo in
            let convertedPromotionsResponse = GomaModelMapper.promotionInfo(fromInternalPromotionInfo: promotionInfo)
            
            return convertedPromotionsResponse
        }).eraseToAnyPublisher()
    }
}
