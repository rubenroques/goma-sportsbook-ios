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
    private let authenticator: GomaAPIAuthenticator
    private let apiClient: GomaAPIDownloadableContentClient

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(authenticator: GomaAPIAuthenticator = GomaAPIAuthenticator(deviceIdentifier: "") ) {
        self.authenticator = authenticator

        self.apiClient = GomaAPIDownloadableContentClient (
            connector: GomaConnector(authenticator: authenticator)
        )
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
