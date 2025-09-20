//
//  EveryMatrixManagedContentProvider.swift
//
//
//  Created on: Today
//

import Foundation
import Combine

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

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(gomaHomeContentProvider: GomaHomeContentProvider, casinoProvider: EveryMatrixCasinoProvider) {
        self.gomaHomeContentProvider = gomaHomeContentProvider
        self.casinoProvider = casinoProvider
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

    func getCarouselEvents() -> AnyPublisher<Events, ServiceProviderError> {
        return gomaHomeContentProvider.getCarouselEvents()
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