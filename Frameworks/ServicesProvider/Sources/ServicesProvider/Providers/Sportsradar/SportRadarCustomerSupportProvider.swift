//
//  File.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//

import Foundation
import Combine

class SportRadarCustomerSupportProvider: CustomerSupportProvider {
    
    var connector: OmegaConnector
    
    init(connector: OmegaConnector = OmegaConnector()) {
        self.connector = connector
    }
    
    func contactUs(form: ContactUsForm) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.contactUs(
            firstName: form.firstName,
            lastName: form.lastName,
            email: form.email,
            subject: form.subject,
            message: form.message
        )
        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {
                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)
                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func contactSupport(form: ContactSupportForm) -> AnyPublisher<SupportResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.contactSupport(
            userIdentifier: form.userIdentifier,
            firstName: form.firstName,
            lastName: form.lastName,
            email: form.email,
            subject: form.subject,
            subjectType: form.subjectType,
            message: form.message,
            isLogged: form.isLogged
        )
        let publisher: AnyPublisher<SportRadarModels.SupportResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ supportResponse -> AnyPublisher<SupportResponse, ServiceProviderError> in
            if supportResponse.request != nil {
                let supportResponse = SportRadarModelMapper.supportResponse(fromInternalSupportResponse: supportResponse)
                return Just(supportResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: SupportResponse.self, failure: ServiceProviderError.errorMessage(message: supportResponse.description ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }
}
