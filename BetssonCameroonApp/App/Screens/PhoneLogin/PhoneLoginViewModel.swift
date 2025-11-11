//
//  MockPhoneLoginViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI
import Combine

class PhoneLoginViewModel {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let phoneFieldViewModel: BorderedTextFieldViewModelProtocol
    let passwordFieldViewModel: BorderedTextFieldViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    var loginComplete: (() -> Void)?
    var loginError: ((String) -> Void)?
    
    var phoneNumber: String = ""
    var password: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "profile_icon",
                                                                                           title: localized("welcome_back"),
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: localized("login_to_continue"),
                                                                                          highlights: []))
        
        phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                                  placeholder: localized("phone_number"),
                                                                                                  prefix: "+237",
                                                                                                  isSecure: false,
                                                                                                  isRequired: true,
                                                                                                  visualState: .idle,
                                                                                                  keyboardType: .phonePad,
                                                                                                  returnKeyType: .next,
                                                                                                  textContentType: .telephoneNumber,
                                                                                                  maxLength: 9,
                                                                                                  allowedCharacters: .decimalDigits))

        passwordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "password",
                                                                                                     placeholder: localized("password"),
                                                                                                     isSecure: true,
                                                                                                     isRequired: true,
                                                                                                     visualState: .idle,
                                                                                                     keyboardType: .default,
                                                                                                     returnKeyType: .go,
                                                                                                     textContentType: .password))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "login",
                                                                     title: localized("login"),
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

                if phoneText.count == 9 && passwordText.isNotEmpty {
                    self?.buttonViewModel.setEnabled(true)
                }
                else {
                    self?.buttonViewModel.setEnabled(false)
                }
            })
            .store(in: &cancellables)
    }
    
    func loginUser() {
        
        isLoadingSubject.send(true)
        
        let username = "\(phoneFieldViewModel.prefixText ?? "")\(phoneNumber)"
        let password = "\(password)"
        
        Env.userSessionStore.login(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let errorMessage):
                        self?.loginError?(errorMessage)
                    default:
                        self?.loginError?("Login after register error")
                    }
                case .finished:
                    ()
                }
                
                self?.isLoadingSubject.send(false)
            }, receiveValue: { [weak self] _ in
                self?.loginComplete?()
            })
            .store(in: &cancellables)
        
    }
}
