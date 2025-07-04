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
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var referralFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var termsViewModel: TermsAcceptanceViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
}
