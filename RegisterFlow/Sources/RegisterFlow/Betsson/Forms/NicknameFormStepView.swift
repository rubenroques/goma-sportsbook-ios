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

    var suggestedUsernames: CurrentValueSubject<[String]?, Never> = .init(nil)

    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var isValidUsername: CurrentValueSubject<Bool?, Never> = .init(nil)

    private let serviceProvider: ServicesProviderClient

    private var cancellables = Set<AnyCancellable>()

    init(title: String, nickname: String?, nicknamePlaceholder: String, serviceProvider: ServicesProviderClient) {
        self.title = title
        self.nickname = nickname
        self.nicknamePlaceholder = nicknamePlaceholder
        self.serviceProvider = serviceProvider
    }

    func resetValidation() {
        self.isValidUsername.send(nil)
    }

    func validateUsername(_ username: String) {

        if username.count < 3 {
            self.suggestedUsernames.send(nil)
            self.isValidUsername.send(nil)
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
                    self?.isValidUsername.send(nil)
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

    private lazy var suggestionsLabelContainerView: UIView = Self.createSuggestionsLabelContainerView()
    private lazy var suggestionsLabel: UILabel = Self.createSuggestionsLabel()

    let viewModel: NicknameFormStepViewModel

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: NicknameFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
        self.configureBindings()
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isValidUsername.map({ isValid in
            if let isValid {
                return isValid
            }
            return false
        }).eraseToAnyPublisher()
    }

    func configureSubviews() {

        self.suggestionsLabel.text = ""
        self.suggestionsLabelContainerView.isHidden = true

        self.nicknameHeaderTextFieldView.addSubview(self.loadingView)
        self.suggestionsLabelContainerView.addSubview(self.suggestionsLabel)

        NSLayoutConstraint.activate([
            self.nicknameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.loadingView.centerYAnchor.constraint(equalTo: self.nicknameHeaderTextFieldView.contentCenterYConstraint),
            self.loadingView.trailingAnchor.constraint(equalTo: self.nicknameHeaderTextFieldView.trailingAnchor, constant: -10),

            self.suggestionsLabel.leadingAnchor.constraint(equalTo: suggestionsLabelContainerView.leadingAnchor),
            self.suggestionsLabel.trailingAnchor.constraint(equalTo: suggestionsLabelContainerView.trailingAnchor, constant: -4),
            self.suggestionsLabel.topAnchor.constraint(equalTo: suggestionsLabelContainerView.topAnchor),
            self.suggestionsLabel.bottomAnchor.constraint(equalTo: suggestionsLabelContainerView.bottomAnchor),
        ])

        self.stackView.addArrangedSubview(self.nicknameHeaderTextFieldView)
        self.stackView.addArrangedSubview(suggestionsLabelContainerView)

        self.suggestionsLabel.isUserInteractionEnabled = true
        self.suggestionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))

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
            .sink { [weak self] _ in
                self?.viewModel.resetValidation()
            }
            .store(in: &self.cancellables)

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

        self.viewModel.isValidUsername
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValidUsername in
                if let isValidUsername {
                    if isValidUsername {
                        self?.nicknameHeaderTextFieldView.hideTipAndError()
                    }
                    else {
                        self?.nicknameHeaderTextFieldView.showErrorOnField(text: "This username is already in use.")
                    }
                }
                else {
                    self?.nicknameHeaderTextFieldView.hideTipAndError()
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.suggestedUsernames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
                if let suggestions {
                    self?.suggestionsLabelContainerView.isHidden = false
                    self?.configureWithSuggestedNicknames(suggestions)
                }
                else {
                    self?.suggestionsLabelContainerView.isHidden = true
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

    func configureWithSuggestedNicknames(_ nicknames: [String]) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        let text = "Suggested nicknames: \(nicknames.joined(separator: "  "))"

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        for nickname in nicknames {
            if let range = text.range(of: nickname) {
                attributedString.addAttribute(.underlineStyle,
                                              value: NSUnderlineStyle.single.rawValue,
                                              range: NSRange(range, in: text))
            }
        }


        self.suggestionsLabel.text = nil
        self.suggestionsLabel.attributedText = attributedString
    }

    @IBAction private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = self.suggestionsLabel.attributedText?.string ?? ""
        for suggestion in self.viewModel.suggestedUsernames.value ?? [] {
            let suggestionRange = (text as NSString).range(of: suggestion)

            if gesture.didTapAttributedTextInLabel(label: self.suggestionsLabel, inRange: suggestionRange, alignment: .left) {
                self.nicknameHeaderTextFieldView.setText(suggestion, slideUp: true)
                break
            }

        }
    }

}

extension NicknameFormStepView {

    private static func createNicknameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createSuggestedNicknamesStackview() -> UIStackView {
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

    private static func createSuggestionsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 2

        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }

    private static func createSuggestionsLabelContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

}
