//
//  GomaCustomerSupportProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//


import Foundation
import Combine

/// Implementation of DownloadableContentsProvider for the Goma API
class GomaCustomerSupportProvider: CustomerSupportProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)
    private let authenticator: GomaAuthenticator
    private let apiClient: GomaDownloadableContentAPIClient // GomaCustomerSupport API Client not implemented

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

    /// Sends a “Contact Us” request with basic details.
    func contactUs(form: ContactUsForm) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    /// Sends a support request including account context.
    func contactSupport(form: ContactSupportForm) -> AnyPublisher<SupportResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
}
