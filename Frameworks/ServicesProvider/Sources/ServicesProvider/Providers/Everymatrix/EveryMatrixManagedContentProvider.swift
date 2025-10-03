
import Foundation
import Combine
import SharedModels

/// Implementation of ManagedContentProvider for the EveryMatrix API
/// Combines EveryMatrix casino provider with Goma CMS for promotional content
class EveryMatrixManagedContentProvider: HomeContentProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        // Use Goma CMS connection state as primary since it provides most content
        gomaHomeContentProvider.connectionStatePublisher
    }

    private let gomaHomeContentProvider: GomaHomeContentProvider
    private let casinoProvider: EveryMatrixCasinoProvider
    private let eventsProvider: EveryMatrixEventsProvider

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(gomaHomeContentProvider: GomaHomeContentProvider,
         casinoProvider: EveryMatrixCasinoProvider,
         eventsProvider: EveryMatrixEventsProvider) {
        self.gomaHomeContentProvider = gomaHomeContentProvider
        self.casinoProvider = casinoProvider
        self.eventsProvider = eventsProvider
    }

    // MARK: - HomeContentProvider Implementation
    // Most methods delegate to GomaHomeContentProvider for CMS data

    func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {
        return gomaHomeContentProvider.preFetchHomeContent()
    }

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        return gomaHomeContentProvider.getHomeTemplate()
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        return gomaHomeContentProvider.getAlertBanner()
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        return gomaHomeContentProvider.getBanners()
    }

    func getCarouselEventPointers() -> AnyPublisher<CarouselEventPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getCarouselEventPointers()
    }

    func getCarouselEvents() -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> {
        let requestPublisher = gomaHomeContentProvider.getCarouselEventPointers()
        return requestPublisher
            .flatMap({ carouselEventPointers -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> in

                // Extract event IDs from pointers
                let eventIds: [String] = carouselEventPointers.map { $0.eventId }

                // Handle empty list case
                guard !eventIds.isEmpty else {
                    return Just([]).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                // Create a dictionary to map event IDs to their banner metadata
                var bannerMetadataMap: [String: CarouselEventPointer] = [:]
                carouselEventPointers.forEach { pointer in
                    bannerMetadataMap[pointer.eventId] = pointer
                }

                // Fetch event details using RPC calls (not subscriptions)
                let publishers: [AnyPublisher<Event?, Never>] = eventIds.map { eventId in
                    return self.eventsProvider.getEventDetails(eventId: eventId)
                        .map { Optional.some($0) }
                        .catch { error -> AnyPublisher<Event?, Never> in
                            print("Failed to fetch event details for \(eventId): \(error)")
                            return Just(nil).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }

                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> ImageHighlightedContents<Event> in
                        // Filter out nil events and preserve order based on original pointers
                        let validEvents = events.compactMap { $0 }

                        // Create a dictionary for efficient event lookup by ID
                        var eventDict: [String: Event] = [:]
                        validEvents.forEach { event in
                            eventDict[event.id] = event
                        }

                        // Create ImageHighlightedContent array in the same order as pointers
                        let highlightedEvents: ImageHighlightedContents<Event> = carouselEventPointers.compactMap { pointer in
                            guard let event = eventDict[pointer.eventId] else { return nil }

                            // Create ImageHighlightedContent with image URL from CMS
                            return ImageHighlightedContent(
                                content: event,
                                promotedChildCount: 1,
                                imageURL: pointer.imageUrl
                            )
                        }

                        return highlightedEvents
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getCasinoCarouselPointers() -> AnyPublisher<CasinoCarouselPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getCasinoCarouselPointers()
    }

    func getCasinoCarouselGames() -> AnyPublisher<CasinoGameBanners, ServiceProviderError> {
        let requestPublisher = gomaHomeContentProvider.getCasinoCarouselPointers()
        return requestPublisher
            .flatMap({ casinoCarouselPointers -> AnyPublisher<CasinoGameBanners, ServiceProviderError> in

                // Extract casino game IDs from pointers
                let casinoGameIds: [String] = casinoCarouselPointers.compactMap { $0.casinoGameId }

                // Handle empty list case
                guard !casinoGameIds.isEmpty else {
                    return Just([]).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                // Create a dictionary to map casino game IDs to their banner metadata
                var bannerMetadataMap: [String: CasinoGameBanner.BannerMetadata] = [:]
                casinoCarouselPointers.forEach { pointer in
                    guard let gameId = pointer.casinoGameId else { return }
                    bannerMetadataMap[gameId] = CasinoGameBanner.BannerMetadata(
                        bannerId: pointer.id,
                        type: pointer.type,
                        title: pointer.title,
                        subtitle: pointer.subtitle,
                        ctaText: pointer.ctaText,
                        ctaUrl: pointer.ctaUrl,
                        ctaTarget: pointer.ctaTarget,
                        customImageUrl: pointer.imageUrl
                    )
                }

                // Fetch casino game details for each game ID
                let publishers: [AnyPublisher<CasinoGame?, Never>] = casinoGameIds.map { gameId in
                    self.casinoProvider.getGameDetails(gameId: gameId, language: nil, platform: nil)
                        .map { $0 }
                        .catch { _ in Just(nil) }
                        .eraseToAnyPublisher()
                }

                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (games: [CasinoGame?]) -> CasinoGameBanners in
                        // Filter out nil games and create CasinoGameBanner objects
                        let validGames = games.compactMap { $0 }

                        // Create a dictionary for efficient game lookup by ID
                        var gameDict: [String: CasinoGame] = [:]
                        validGames.forEach { game in
                            gameDict[game.id] = game
                        }

                        // Create CasinoGameBanner objects in the same order as pointers
                        let orderedCasinoGameBanners: CasinoGameBanners = casinoCarouselPointers.compactMap { pointer in
                            guard
                                let gameId = pointer.casinoGameId,
                                let game = gameDict[gameId],
                                let bannerMetadata = bannerMetadataMap[gameId]
                            else { return nil }

                            return CasinoGameBanner(casinoGame: game, bannerMetadata: bannerMetadata)
                        }

                        return orderedCasinoGameBanners
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getCasinoRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSportRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getBoostedOddsPointers() -> AnyPublisher<BoostedOddsPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getBoostedOddsPointers()
    }

    func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return gomaHomeContentProvider.getBoostedOddsEvents()
    }

    func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return gomaHomeContentProvider.getHeroCardEvents()
    }

    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getHeroCardPointers()
    }

    func getTopImageCardPointers() -> AnyPublisher<TopImageCardPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getTopImageCardPointers()
    }

    func getTopImageEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return gomaHomeContentProvider.getTopImageEvents()
    }

    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        return gomaHomeContentProvider.getStories()
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        return gomaHomeContentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
    }

    func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError> {
        return gomaHomeContentProvider.getProChoiceCardPointers()
    }

    func getProChoiceMarketCards() -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> {
        return gomaHomeContentProvider.getProChoiceMarketCards()
    }

    func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError> {
        return gomaHomeContentProvider.getTopCompetitionsPointers()
    }

    func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError> {
        return gomaHomeContentProvider.getTopCompetitions()
    }
}
