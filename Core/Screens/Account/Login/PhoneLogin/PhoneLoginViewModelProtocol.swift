//
//  PhoneLoginViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol PhoneLoginViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    
    var phoneNumber: String { get }
    var password: String { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var loginComplete: PassthroughSubject<Void, Never> { get }
    var loginError: PassthroughSubject<String, Never> { get }

    func loginUser(phoneNumber: String, password: String)
}
