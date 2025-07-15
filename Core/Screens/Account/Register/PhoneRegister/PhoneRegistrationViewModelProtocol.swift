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
    var referralFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
    var termsViewModel: TermsAcceptanceViewModelProtocol? { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var isLoadingConfigPublisher: AnyPublisher<Bool, Never> { get }
    var registerComplete: PassthroughSubject<Void, Never> { get }
    var registerError: PassthroughSubject<String, Never> { get }
    
    var extractedTermsHTMLData: RegisterConfigHelper.ExtractedHTMLData? { get }

    func registerUser()
}
