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
    private let authenticator: GomaAuthenticator
    private let apiClient: GomaDownloadableContentAPIClient

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(authenticator: GomaAuthenticator,
         apiClient: GomaDownloadableContentAPIClient) {
        self.authenticator = authenticator
        self.apiClient = apiClient
    }
    
    convenience init(authenticator: GomaAuthenticator = GomaAuthenticator(deviceIdentifier: "")) {
        let connector = GomaConnector(authenticator: authenticator)
        let apiClient = GomaDownloadableContentAPIClient(connector: connector)
        self.init(authenticator: authenticator, apiClient: apiClient)
    }

    func getDownloadableContentItems() -> AnyPublisher<DownloadableContentItems, ServiceProviderError> {
        return self.apiClient.downloadableContents()
            .map(GomaModelMapper.downloadableContentItems(fromInternalDownloadableContentItems:))
            .eraseToAnyPublisher()
    }
    
}
