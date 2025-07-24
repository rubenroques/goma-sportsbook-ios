//
//  PhonePasswordCodeVerificationViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol PhonePasswordCodeVerificationViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var pinEntryViewModel: PinDigitEntryViewModelProtocol { get }
    var resendCodeCountdownViewModel: ResendCodeCountdownViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var shouldPasswordChange: PassthroughSubject<Void, Never> { get }

    func requestPasswordChange()

}
