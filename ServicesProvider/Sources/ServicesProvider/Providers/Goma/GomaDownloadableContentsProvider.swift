//
//  GomaDownloadableContentsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//


import Foundation
import Combine

/// Implementation of DownloadableContentsProvider for the Goma API
class GomaDownloadableContentsProvider: DownloadableContentsProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)
    private let authenticator: GomaAPIAuthenticator
    private let apiClient: GomaAPIDownloadableContentClient

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(gomaAPIAuthenticator: GomaAPIAuthenticator = GomaAPIAuthenticator(deviceIdentifier: "") ) {
        self.authenticator = gomaAPIAuthenticator

        self.apiClient = GomaAPIDownloadableContentClient (
            connector: GomaConnector(gomaAPIAuthenticator: gomaAPIAuthenticator)
        )
    }

    
    func getDownloadableContentItems() -> AnyPublisher<DownloadableContentItems, ServiceProviderError> {
        return self.apiClient.downloadableContents()
            .map(GomaModelMapper.downloadableContentItems(fromInternalDownloadableContentItems:))
            .eraseToAnyPublisher()
    }
    
}
