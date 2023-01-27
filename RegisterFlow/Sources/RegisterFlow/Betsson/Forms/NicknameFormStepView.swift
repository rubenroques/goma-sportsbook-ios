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

    enum NicknameState: Equatable {
        case empty
        case needsValidation
        case validating
        case serverError
        case alreadyInUse(suggestions: [String])
        case valid
    }


    let title: String

    let nickname: CurrentValueSubject<String?, Never>
    let generatedNickname: CurrentValueSubject<String?, Never>?

    let nicknameState: CurrentValueSubject<NicknameState, Never> = .init(.empty)
    var shouldUseGeneratedNickname: Bool = true

    var nicknameSuggestions: [String] {
        switch self.nicknameState.value {
        case let .alreadyInUse(suggestions):
            return suggestions
        default:
            return []
        }
    }

    private let serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    private var validateNicknameCancellables: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(title: String,
         nickname: String?,
         serviceProvider: ServicesProviderClient,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {
        self.title = title

        self.nickname = .init(nickname)

        if nickname != nil {
            self.shouldUseGeneratedNickname = false
            self.generatedNickname = nil
        }
        else {
            self.generatedNickname = .init(nickname)
        }

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.userRegisterEnvelopUpdater.setAvatarName("avatar1")

        //
        let clearedEmailState = self.nicknameState.removeDuplicates()
        let clearedEmail = self.nickname.removeDuplicates()

        self.nickname
            .removeDuplicates()
            .print("DEBUG-NICK: 1 ")
            .sink { [weak self] newNickname in

                self?.userRegisterEnvelopUpdater.setNickname(nil)
                self?.validateNicknameCancellables?.cancel()

                guard
                    let newNickname
                else {
                    self?.nicknameState.send(.empty)
                    return
                }

                if newNickname.isEmpty {
                    self?.nicknameState.send(.empty)
                }
                else {
                    self?.nicknameState.send(.needsValidation)
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(clearedEmailState, clearedEmail)
            .print("DEBUG-NICK: 2 ")
            .filter { nicknameState, nickname in
                return nicknameState == .needsValidation
            }
            .map { _, nickname -> String? in
                return nickname
            }
            .compactMap({ $0 })
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.validateNickname(nickname)
            }
            .store(in: &self.cancellables)

        // Cache valid nickname
        Publishers.CombineLatest(self.nicknameState, self.nickname)
            .filter { nicknameState, nickname in
                return nicknameState == .valid
            }
            .map { _, nickname -> String? in
                return nickname
            }
            .compactMap({ $0 })
            .print("DEBUG-NICK: 3 ")
            .sink { validNickname in
                self.userRegisterEnvelopUpdater.setNickname(validNickname)
            }
            .store(in: &self.cancellables)
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.nicknameState
            .map { nicknameState in
                return nicknameState == .valid
            }
            .eraseToAnyPublisher()
    }

    func setGeneratedNickname(_ generatedNickname: String?) {
        if shouldUseGeneratedNickname {
            self.generatedNickname?.send(generatedNickname)
        }
        else {
            print("DEBUG-NICK: ignoring generated nickname \(generatedNickname)")
        }
    }

    func setNickname(_ nickname: String?) {
        self.nickname.send(nickname)
    }

    func validateNickname(_ nickname: String) {
        print("DEBUG-NICK: Will Validate \(nickname)")
        if nickname.isEmpty {
            self.nicknameState.send(.empty)
            return
        }

        self.nicknameState.send(.validating)

        self.validateNicknameCancellables = self.serviceProvider
            .validateUsername(nickname)
            .sink { [weak self]  completion in
                switch completion {
                case .failure:
                    self?.nicknameState.send(.serverError)
                case .finished:
                    ()
                }
            } receiveValue: { [weak self] usernameValidation in
                if usernameValidation.isAvailable {
                    self?.nicknameState.send(.valid)
                }
                else {
                    self?.nicknameState.send(.alreadyInUse(suggestions: usernameValidation.suggestedUsernames ?? []))
                }
            }
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

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: NicknameFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
        self.configureBindings()
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
        self.nicknameHeaderTextFieldView.setPlaceholderText("Nickname")

        self.nicknameHeaderTextFieldView.textPublisher
            .sink { newNickname in
                self.viewModel.setNickname(newNickname)
            }
            .store(in: &self.cancellables)

        self.nicknameHeaderTextFieldView.shouldBeginEditing = { [weak self] in
            self?.viewModel.shouldUseGeneratedNickname = false
            return true
        }

        self.viewModel.nicknameState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nicknameState in
                switch nicknameState {
                case .empty:
                    self?.nicknameHeaderTextFieldView.hideTipAndError()
                    self?.suggestionsLabelContainerView.isHidden = true
                    self?.loadingView.stopAnimating()
                case .needsValidation:
                    self?.nicknameHeaderTextFieldView.hideTipAndError()
                    self?.suggestionsLabelContainerView.isHidden = true
                    self?.loadingView.stopAnimating()
                case .validating:
                    self?.nicknameHeaderTextFieldView.hideTipAndError()
                    self?.suggestionsLabelContainerView.isHidden = true
                    self?.loadingView.startAnimating()
                case .serverError:
                    self?.nicknameHeaderTextFieldView.showErrorOnField(text: "Sorry we could not validate this nickname.")
                    self?.suggestionsLabelContainerView.isHidden = true
                    self?.loadingView.stopAnimating()
                case .alreadyInUse(let suggestions):
                    self?.nicknameHeaderTextFieldView.showErrorOnField(text: "This nickname is already in use.")
                    self?.configureWithSuggestedNicknames(suggestions)
                    self?.suggestionsLabelContainerView.isHidden = false
                    self?.loadingView.stopAnimating()
                case .valid:
                    self?.nicknameHeaderTextFieldView.hideTipAndError()
                    self?.suggestionsLabelContainerView.isHidden = true
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &self.cancellables)

        if let nickname = self.viewModel.nickname.value {
            self.nicknameHeaderTextFieldView.setText(nickname, slideUp: true)
        }

        self.viewModel.generatedNickname?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] generatedNickname in
                if let generatedNickname, !generatedNickname.isEmpty {
                    self?.nicknameHeaderTextFieldView.setText(generatedNickname)
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
        for suggestion in self.viewModel.nicknameSuggestions {
            let suggestionRange = (text as NSString).range(of: suggestion)
            if gesture.didTapAttributedTextInLabel(label: self.suggestionsLabel, inRange: suggestionRange, alignment: .left) {

                self.nicknameHeaderTextFieldView.setText(suggestion, slideUp: true)
                self.viewModel.shouldUseGeneratedNickname = false

                break
            }

        }
    }

}

extension NicknameFormStepView {

    private static func createNicknameHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
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
