//
//  GomaManagedContentProvider.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Implementation of ManagedContentProvider for the Goma API
class GomaHomeContentProvider: HomeContentProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)
    private let authenticator: GomaAuthenticator
    private let apiClient: GomaHomeContentAPIClient

    // Optional providers for enrichment
    private var casinoProvider: CasinoProvider?
    private var eventsProvider: EventsProvider?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        authenticator: GomaAuthenticator = GomaAuthenticator(deviceIdentifier: ""),
        casinoProvider: CasinoProvider? = nil,
        eventsProvider: EventsProvider? = nil
    ) {
        self.authenticator = authenticator
        self.casinoProvider = casinoProvider
        self.eventsProvider = eventsProvider

        self.apiClient = GomaHomeContentAPIClient(
            connector: GomaConnector(authenticator: authenticator),
            cache: GomaAPIPromotionsCache()
        )
    }
    
    func invalidateCache() {
        self.apiClient.clearCache()
    }
    
    // MARK: - API Request Helper
    
    private func request<T: Decodable>(_ endpoint: GomaHomeContentAPIClient) -> AnyPublisher<T, ServiceProviderError> {
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
            .map(GomaModelMapper.carouselEventPointers(fromInternalCarouselEventPointers:))
            .eraseToAnyPublisher()
    }
    
    func getCarouselEvents() -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> {
        return self.apiClient.carouselEvents()
            .map(GomaModelMapper.events(fromInternalHeroCardEvents:))
            .map { events -> ImageHighlightedContents<Event> in
                events.map { event in
                    ImageHighlightedContent(
                        content: event,
                        promotedChildCount: 1,
                        imageURL: event.promoImageURL
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getCasinoCarouselPointers() -> AnyPublisher<CasinoCarouselPointers, ServiceProviderError> {
        return self.apiClient.casinoCarouselPointers()
            .map(GomaModelMapper.casinoCarouselPointers(fromInternalCasinoCarouselPointers:))
            .eraseToAnyPublisher()
    }

    func getCasinoRichBannerPointers() -> AnyPublisher<RichBannerPointers, ServiceProviderError> {
        return self.apiClient.casinoRichBanners()
            .map(GomaModelMapper.richBannerPointers(fromInternalRichBanners:))
            .eraseToAnyPublisher()
    }

    func getSportRichBannerPointers() -> AnyPublisher<RichBannerPointers, ServiceProviderError> {
        return self.apiClient.sportRichBanners()
            .map(GomaModelMapper.richBannerPointers(fromInternalRichBanners:))
            .eraseToAnyPublisher()
    }

    func getCasinoRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
        }

        return self.apiClient.casinoRichBanners()
            .flatMap { (internalBanners: GomaModels.RichBanners) -> AnyPublisher<RichBanners, ServiceProviderError> in
                // Extract casino game IDs from banners
                let casinoGameIds = internalBanners.compactMap { banner -> String? in
                    if case .casinoGame(let data) = banner {
                        return data.casinoGameId
                    }
                    return nil
                }

                // If no casino games, just map info banners
                guard !casinoGameIds.isEmpty else {
                    let richBanners = GomaModelMapper.richBanners(
                        fromInternalRichBanners: internalBanners,
                        casinoGames: [],
                        events: []
                    )
                    return Just(richBanners)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }

                // Fetch casino games in parallel
                // Order is preserved by mapper iterating through internalBanners
                let publishers: [AnyPublisher<CasinoGame?, Never>] = casinoGameIds.map { gameId in
                    casinoProvider.getGameDetails(gameId: gameId, language: nil, platform: nil)
                        .map { Optional.some($0) }
                        .catch { _ in Just(nil) }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .map { (games: [CasinoGame?]) -> RichBanners in
                        let casinoGames = games.compactMap { $0 }
                        // Mapper iterates internalBanners in order and looks up games by ID
                        return GomaModelMapper.richBanners(
                            fromInternalRichBanners: internalBanners,
                            casinoGames: casinoGames,
                            events: []
                        )
                    }
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getSportRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError> {
        guard let eventsProvider = self.eventsProvider else {
            return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
        }

        return self.apiClient.sportRichBanners()
            .flatMap { (internalBanners: GomaModels.RichBanners) -> AnyPublisher<RichBanners, ServiceProviderError> in
                // Extract event IDs from banners
                let eventIds = internalBanners.compactMap { banner -> String? in
                    if case .sportEvent(let data) = banner {
                        return data.sportEventId
                    }
                    return nil
                }

                // If no events, just map info banners
                guard !eventIds.isEmpty else {
                    let richBanners = GomaModelMapper.richBanners(
                        fromInternalRichBanners: internalBanners,
                        casinoGames: [],
                        events: []
                    )
                    return Just(richBanners)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }

                // Fetch events in parallel
                // Order is preserved by mapper iterating through internalBanners
                let publishers: [AnyPublisher<Event?, Never>] = eventIds.map { eventId in
                    eventsProvider.getEventDetails(eventId: eventId)
                        .map { Optional.some($0) }
                        .catch { _ in Just(nil) }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .map { (events: [Event?]) -> RichBanners in
                        let validEvents = events.compactMap { $0 }
                        // Mapper iterates internalBanners in order and looks up events by ID
                        return GomaModelMapper.richBanners(
                            fromInternalRichBanners: internalBanners,
                            casinoGames: [],
                            events: validEvents
                        )
                    }
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getCasinoCarouselGames() -> AnyPublisher<CasinoGameBanners, ServiceProviderError> {
        // GomaHomeContentProvider only provides CMS data, not casino game data
        // This method should be implemented by wrapper providers that have access to casino providers
        return Fail(error: ServiceProviderError.notSupportedForProvider)
            .eraseToAnyPublisher()
    }

    func getBoostedOddsPointers() -> AnyPublisher<[BoostedOddsPointer], ServiceProviderError> {
        return self.apiClient.boostedOddsPointers()
            .map(GomaModelMapper.boostedOddsPointers(fromInternalBoostedOddsPointers:))
            .eraseToAnyPublisher()
    }
    
    func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return self.apiClient.boostedOddsEvents()
            .map(GomaModelMapper.events(fromInternalBoostedOddsEvents:))
            .eraseToAnyPublisher()
    }
    
    func getTopImageCardPointers() -> AnyPublisher<TopImageCardPointers, ServiceProviderError> {
        return self.apiClient.topImageCardPointers()
            .map(GomaModelMapper.topImageCardPointers(fromInternaTopImageCardPointers:))
            .eraseToAnyPublisher()
    }
    func getTopImageEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return self.apiClient.topImageEvents()
            .map(GomaModelMapper.events(fromInternalEvents:))
            .eraseToAnyPublisher()
    }
    
    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return self.apiClient.heroCardPointers()
            .map(GomaModelMapper.heroCardPointers(fromInternalHeroCardPointers:))
            .eraseToAnyPublisher()
    }
    
    func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return self.apiClient.heroCardEvents()
            .map(GomaModelMapper.events(fromInternalHeroCardEvents:))
            .eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        return self.apiClient.stories()
            .map(GomaModelMapper.stories(fromInternalStories:))
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

}
