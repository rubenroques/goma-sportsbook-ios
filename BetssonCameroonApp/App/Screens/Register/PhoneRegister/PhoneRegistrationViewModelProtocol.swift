//
//  PhoneRegistrationViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol PhoneRegistrationViewModelProtocol {
    var isRegisterDataComplete: CurrentValueSubject<Bool, Never> { get }
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }

    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var firstNameFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var lastNameFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var birthDateFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var termsViewModel: TermsAcceptanceViewModelProtocol? { get }
    var buttonViewModel: ButtonViewModelProtocol { get }

    var phonePrefixText: String { get }
    var phoneText: String { get }
    var password: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var birthDate: String { get }

    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var isLoadingConfigPublisher: AnyPublisher<Bool, Never> { get }
    var registerComplete: (() -> Void)? { get set }
    var registerError: ((String) -> Void)? { get set }

    var extractedTermsHTMLData: RegisterConfigHelper.ExtractedHTMLData? { get }

    func registerUser()
}
