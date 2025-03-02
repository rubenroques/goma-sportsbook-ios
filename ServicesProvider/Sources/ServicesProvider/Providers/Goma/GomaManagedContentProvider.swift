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
    private let gomaAPIAuthenticator: GomaAPIAuthenticator
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(gomaAPIAuthenticator: GomaAPIAuthenticator) {
        self.gomaAPIAuthenticator = gomaAPIAuthenticator

    }

    // MARK: - API Request Helper

    private func request<T: Decodable>(_ endpoint: GomaAPIPromotionsSchema) -> AnyPublisher<T, ServiceProviderError> {
        // This is a simplified placeholder for API requests
        // In a real implementation, you would handle authentication and network requests here
        return Fail(error: ServiceProviderError.notSupportedForProvider)
            .eraseToAnyPublisher()
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

    func getCarouselEvents() -> AnyPublisher<CarouselEvents, ServiceProviderError> {
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
