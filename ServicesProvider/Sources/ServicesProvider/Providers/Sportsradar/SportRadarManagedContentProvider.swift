//
//  SportRadarManagedContentProvider.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Implementation of ManagedContentProvider for the Sportradar API
class SportRadarManagedContentProvider: ManagedContentProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)

    private unowned let sessionCoordinator: SportRadarSessionCoordinator
    private let eventsProvider: SportRadarEventsProvider
    
    private let gomaManagedContentProvider: GomaManagedContentProvider

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(sessionCoordinator: SportRadarSessionCoordinator,
         eventsProvider: SportRadarEventsProvider,
         gomaManagedContentProvider: GomaManagedContentProvider = GomaManagedContentProvider()) {

        self.sessionCoordinator = sessionCoordinator
        self.eventsProvider = eventsProvider
        
        self.gomaManagedContentProvider = gomaManagedContentProvider

        // Set up token handling
        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if launchToken != nil {
                    self?.connectionStateSubject.send(.connected)
                } else {
                    self?.connectionStateSubject.send(.disconnected)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - ManagedContentProvider Implementation
    func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {
        return self.gomaManagedContentProvider.preFetchHomeContent()
    }

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        return self.gomaManagedContentProvider.getHomeTemplate()
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        return self.gomaManagedContentProvider.getAlertBanner()
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        return self.gomaManagedContentProvider.getBanners()
    }

    func getCarouselEvents() -> AnyPublisher<CarouselEvents, ServiceProviderError> {
        return self.gomaManagedContentProvider.getCarouselEvents()
    }

    func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsBanner], ServiceProviderError> {
        return self.gomaManagedContentProvider.getBoostedOddsBanners()
    }

    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return self.gomaManagedContentProvider.getHeroCardPointers()
    }

    func getHeroCards() -> AnyPublisher<[Event], ServiceProviderError> {
        let requestPublisher = self.gomaManagedContentProvider.getHeroCardPointers()

        var eventMarketGroupRelations: [String: String] = [:]
        var uniqueMarketGroupIds: [String] = []

        return requestPublisher
            .flatMap({ heroCardPointers -> AnyPublisher<[Event], ServiceProviderError> in

                var headlineItemImage = [String: String]()


                heroCardPointers.forEach({ pointer in
                    if let id = pointer.eventId, let imageURL = pointer.imageUrl {
                        headlineItemImage[id] = imageURL
                    }
                })

                let marketGroupIds = heroCardPointers.map({ $0.eventMarketIds ?? [] }).flatMap { $0 }

                var seen = Set<String>() // Adjust the type according to the type of `marketGroupId`

                uniqueMarketGroupIds = marketGroupIds.filter { marketGroupId in
                    guard !seen.contains(marketGroupId) else { return false }
                    seen.insert(marketGroupId)
                    return true
                }

                // Support multiple events
                let publishers = uniqueMarketGroupIds.map { marketGroupId in
                    self.eventsProvider.getEventForMarketGroup(withId: marketGroupId)
                        .map({ event -> Event in

                            eventMarketGroupRelations[event.id] = marketGroupId

                            event.promoImageURL = headlineItemImage[marketGroupId] ?? ""

                            let firstMarket = event.markets.first
                            event.homeTeamName = firstMarket?.homeParticipant ?? ""
                            event.awayTeamName = firstMarket?.awayParticipant ?? ""
                            event.name = firstMarket?.eventName ?? ""
                            return event
                        })
                        .eraseToAnyPublisher()
                }

                // Combine all the publishers into a single one that emits an array of events
                return Publishers.MergeMany(publishers)
                    .collect()
                    // Restore the original order of events
                    .map { events in
                        return events.sorted { leftEvent, rightEvent in
                            let leftEventMarketGroupId = eventMarketGroupRelations[leftEvent.id] ?? ""
                            let rightEventMarketGroupId = eventMarketGroupRelations[rightEvent.id] ?? ""

                            let leftPosition = uniqueMarketGroupIds.firstIndex(of: leftEventMarketGroupId) ?? 100
                            let rightPosition = uniqueMarketGroupIds.firstIndex(of: rightEventMarketGroupId) ?? 101

                            return leftPosition < rightPosition
                        }
                    }
                    .eraseToAnyPublisher()

            })
            .eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        return self.gomaManagedContentProvider.getStories()
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        return self.gomaManagedContentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
    }

    func getProChoices() -> AnyPublisher<[ProChoice], ServiceProviderError> {
        return self.gomaManagedContentProvider.getProChoices()
    }

}
