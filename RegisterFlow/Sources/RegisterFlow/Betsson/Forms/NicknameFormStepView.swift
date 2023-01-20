//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Combine
import ServicesProvider
import Theming
import Extensions

class NicknameFormStepViewModel {

    let title: String
    let nickname: String?
    let nicknamePlaceholder: String
    let serviceProvider: ServicesProviderClient

    var suggestedUsernames: CurrentValueSubject<[String]?, Never> = .init(nil)

    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var isValidUsername: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()

    init(title: String, nickname: String?, nicknamePlaceholder: String, serviceProvider: ServicesProviderClient) {
        self.title = title
        self.nickname = nickname
        self.nicknamePlaceholder = nicknamePlaceholder
        self.serviceProvider = serviceProvider
    }

    func validateUsername(_ username: String) {

        if username.count < 3 {
            self.suggestedUsernames.send(nil)
            self.isValidUsername.send(false)
            self.isLoading.send(false)
            return
        }

        self.isLoading.send(true)

        serviceProvider
            .validateUsername(username)
            .sink { [weak self]  completion in
                switch completion {
                case .failure:
                    self?.suggestedUsernames.send(nil)
                    self?.isValidUsername.send(false)
                case .finished:
                    ()
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] usernameValidation in
                self?.suggestedUsernames.send(usernameValidation.suggestedUsernames)
                self?.isValidUsername.send(usernameValidation.isAvailable)
            }
            .store(in: &cancellables)

    }

}

class NicknameFormStepView: FormStepView {

    private lazy var nicknameHeaderTextFieldView: HeaderTextFieldView = Self.createNicknameHeaderTextFieldView()
    private lazy var suggestedNicknamesStackview: UIStackView = Self.createSuggestedNicknamesStackview()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()
    let viewModel: NicknameFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: NicknameFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
        self.configureBindings()
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isValidUsername.eraseToAnyPublisher()
    }

    func configureSubviews() {
        self.stackView.addArrangedSubview(self.nicknameHeaderTextFieldView)

        self.nicknameHeaderTextFieldView.addSubview(self.loadingView)

        NSLayoutConstraint.activate([
            self.nicknameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.loadingView.centerYAnchor.constraint(equalTo: self.nicknameHeaderTextFieldView.contentCenterYConstraint),
            self.loadingView.trailingAnchor.constraint(equalTo: self.nicknameHeaderTextFieldView.trailingAnchor, constant: -10)
        ])


    }

    func configureBindings() {
        self.titleLabel.text = self.viewModel.title
        self.nicknameHeaderTextFieldView.setPlaceholderText(self.viewModel.nicknamePlaceholder)

        if let nickname = self.viewModel.nickname {
            self.nicknameHeaderTextFieldView.setText(nickname, slideUp: true)
        }

        self.nicknameHeaderTextFieldView
            .textPublisher
            .removeDuplicates()
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.viewModel.validateUsername(nickname)
            }
            .store(in: &self.cancellables)

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &self.cancellables)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.nicknameHeaderTextFieldView.backgroundColor = AppColor.backgroundPrimary
        self.nicknameHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.nicknameHeaderTextFieldView.setTextFieldColor(AppColor.inputText)
    }

}

extension NicknameFormStepView {

    fileprivate static func createNicknameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    fileprivate static func createSuggestedNicknamesStackview() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private static func createLoadingView() -> UIActivityIndicatorView {
        let loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }

}
