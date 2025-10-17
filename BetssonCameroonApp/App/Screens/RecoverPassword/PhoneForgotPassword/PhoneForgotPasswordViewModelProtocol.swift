//
//  PhonePasswordCodeResetViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol PhoneForgotPasswordViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var newPasswordFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var confirmNewPasswordFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var passwordChanged: PassthroughSubject<Void, Never> { get }
    var showError: PassthroughSubject<String, Never> { get }

    var resetPasswordType: ResetPasswordType { get }

    func requestPasswordChange()
}
