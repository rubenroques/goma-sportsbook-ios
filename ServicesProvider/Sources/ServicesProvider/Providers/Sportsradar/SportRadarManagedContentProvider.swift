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

    func getHeroCards() -> AnyPublisher<[HeroCard], ServiceProviderError> {
        return self.gomaManagedContentProvider.getHeroCards()
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
