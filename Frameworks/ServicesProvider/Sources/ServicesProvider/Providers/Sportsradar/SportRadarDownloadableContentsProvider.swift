//
//  SportRadarDownloadableContentsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//
import Foundation
import Combine

class SportRadarDownloadableContentsProvider: DownloadableContentsProvider {
    
    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)

    private unowned let sessionCoordinator: SportRadarSessionCoordinator

    private let gomaDownloadableContentsProvider: GomaDownloadableContentsProvider

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(sessionCoordinator: SportRadarSessionCoordinator,
         gomaDownloadableContentsProvider: GomaDownloadableContentsProvider = GomaDownloadableContentsProvider()) {

        self.sessionCoordinator = sessionCoordinator

        self.gomaDownloadableContentsProvider = gomaDownloadableContentsProvider

        // Set up token handling
        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if launchToken != nil {
                    self?.connectionStateSubject.send(.connected)
                } else {
                    self?.connectionStateSubject.send(.disconnected)
                }
            }
            .store(in: &self.cancellables)
    }

        
    func getDownloadableContentItems() -> AnyPublisher<DownloadableContentItems, ServiceProviderError> {
        return self.gomaDownloadableContentsProvider.getDownloadableContentItems().eraseToAnyPublisher()
    }
}
