//
//  PhonePasswordCodeResetViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol PhonePasswordCodeResetViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var shouldVerifyCode: PassthroughSubject<Void, Never> { get }

    func requestPasswordResetCode()
}
