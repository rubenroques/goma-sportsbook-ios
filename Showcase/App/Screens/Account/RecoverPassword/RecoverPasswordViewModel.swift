//
//  RecoverPasswordViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 16/02/2023.
//

import Foundation
import Combine
import ServicesProvider

class RecoverPasswordViewModel {

    init() {

    }

    func submitRecoverPassword(email: String, secrestQuestion: String? = nil, secrestAnswer: String? = nil) -> AnyPublisher<Bool, ServiceProviderError> {
        return Env.servicesProvider.forgotPassword(email: email, secretQuestion: secrestQuestion, secrestAnswer: secrestAnswer)
    }
}
