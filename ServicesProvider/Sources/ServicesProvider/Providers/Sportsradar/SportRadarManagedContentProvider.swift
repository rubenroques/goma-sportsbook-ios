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

    // MARK: - API Request Helper

    private func request<T: Decodable>(_ endpoint: String, parameters: [String: Any]? = nil) -> AnyPublisher<T, ServiceProviderError> {
        // This is a simplified placeholder for API requests
        // In a real implementation, you would use your preferred networking approach
        return Fail(error: ServiceProviderError.notSupportedForProvider)
            .eraseToAnyPublisher()
    }

    // MARK: - ManagedContentProvider Implementation

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        return request("/api/home-template")
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        return request("/api/alert-banner")
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        return request("/api/banners")
    }

    func getSportBanners() -> AnyPublisher<[SportBanner], ServiceProviderError> {
        return request("/api/sport-banners")
    }

    func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsBanner], ServiceProviderError> {
        return request("/api/boosted-odds-banners")
    }

    func getHeroCards() -> AnyPublisher<[HeroCard], ServiceProviderError> {
        return request("/api/hero-cards")
    }

    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        return request("/api/stories")
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        return request("/api/news", parameters: ["page": pageIndex, "pageSize": pageSize])
    }

    func getProChoices() -> AnyPublisher<[ProChoice], ServiceProviderError> {
        return request("/api/pro-choices")
    }

    func invalidateCache() {
        // No caching implemented in this version
    }

    func invalidateCache(for contentType: ManagedContentType) {
        // No caching implemented in this version
    }
}