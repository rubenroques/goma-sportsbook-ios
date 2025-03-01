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
    private let sessionCoordinator: SportRadarSessionCoordinator
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(sessionCoordinator: SportRadarSessionCoordinator) {
        self.sessionCoordinator = sessionCoordinator

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

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        fatalError("")
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        fatalError("")
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        fatalError("")
    }

    func getSportBanners() -> AnyPublisher<[SportBanner], ServiceProviderError> {
        fatalError("")
    }

    func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsBanner], ServiceProviderError> {
        fatalError("")
    }

    func getHeroCards() -> AnyPublisher<[HeroCard], ServiceProviderError> {
        fatalError("")
    }

    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        fatalError("")
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        fatalError("")
    }

    func getProChoices() -> AnyPublisher<[ProChoice], ServiceProviderError> {
        fatalError("")
    }

}
