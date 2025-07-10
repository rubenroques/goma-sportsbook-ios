//
//  MockPhoneLoginViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

class MockPhoneLoginViewModel: PhoneLoginViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let phoneFieldViewModel: BorderedTextFieldViewModelProtocol
    let passwordFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let loginComplete = PassthroughSubject<Void, Never>()
    let loginError = PassthroughSubject<String, Never>()
    
    var phoneNumber: String = ""
    var password: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "profile_icon",
                                                                                           title: "Welcome back to Betsson!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Log in to continue playing!",
                                                                                          highlights: []))
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: "Phone number *",
                                                                                                  prefix: "+237",
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
        
        setupBindings()
    }
    
    private func setupBindings() {
        
        Publishers.CombineLatest(phoneFieldViewModel.textPublisher, passwordFieldViewModel.textPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] phoneText, passwordText in
                
                self?.phoneNumber = phoneText

                self?.password = passwordText
                
                if phoneText.isNotEmpty && passwordText.isNotEmpty {
                    self?.buttonViewModel.setEnabled(true)
                }
                else {
                    self?.buttonViewModel.setEnabled(false)
                }
            })
            .store(in: &cancellables)
    }
    
    func loginUser(phoneNumber: String, password: String) {
        
        isLoadingSubject.send(true)
        
        // Simulate endpoint delay
        if phoneNumber == "123456789" && password == "error" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.isLoadingSubject.send(false)
                
                self?.loginError.send("Incorrect username or password")

            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.isLoadingSubject.send(false)
                
                self?.loginComplete.send()
            }
        }
        
    }
}
