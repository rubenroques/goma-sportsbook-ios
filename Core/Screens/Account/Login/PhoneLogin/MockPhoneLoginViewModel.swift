//
//  MockPhoneLoginViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI

class MockPhoneLoginViewModel: PhoneLoginViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let phoneFieldViewModel: BorderedTextFieldViewModelProtocol
    let passwordFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "profile_icon",
                                                                                           title: "Welcome back to Betsson!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Log in to continue playing!",
                                                                                          highlights: []))
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: "Phone number *",
                                                                                                  isSecure: false,
                                                                                                  visualState: .idle,
                                                                                                  keyboardType: .phonePad,
                                                                                                  textContentType: .telephoneNumber))
        
        passwordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "password",
                                                                                                     placeholder: "Password *",
                                                                                                     isSecure: true,
                                                                                                     visualState: .idle,
                                                                                                     keyboardType: .default,
                                                                                                     textContentType: .password))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "login",
                                                                     title: "Log In",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
    }
}
