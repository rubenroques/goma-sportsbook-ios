//
//  ConfirmationCodeFormStepView.swift
//  
//
//  Created by Ruben Roques on 25/01/2023.
//

import Foundation
import UIKit
import Theming
import Extensions
import Combine
import HeaderTextField
import ServicesProvider

class ConfirmationCodeFormStepViewModel {

    struct PhoneVerificationResponse: Decodable {
        let id: String?
        let method: String?
        let status: String?
        let errorCode: Int?
        let message: String?
        let reference: String?
    }

    enum PhoneVerificationError: Error {

        case nonMatchingCode
        case emptyPhoneNumber
        case networkError
        case serverError(statusCode: Int)
        case decodingError
        case authorizationError
        case customError(message: String)

        var errorDescription: String? {
            switch self {
            case .nonMatchingCode:
                return "Non Matching Code"
            case .emptyPhoneNumber:
                return "Empty phone code"
            case .networkError:
                return "There was a problem connecting to the server. Please check your internet connection and try again."
            case .serverError(let statusCode):
                return "The server returned an error (code \(statusCode))."
            case .decodingError:
                return "There was a problem decoding the server's response."
            case .authorizationError:
                return "Failed to authorize with the provided API credentials."
            case .customError(let message):
                return message
            }
        }

    }

    let title: String

    var phoneNumber: CurrentValueSubject<String, Never> = .init("")

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.verifiedCode.map { verifiedCode in
            if let verifiedCodeValue = verifiedCode, verifiedCodeValue.count > 1 {
                return true
            }
            return false
        }
        .eraseToAnyPublisher()
    }

    var isVerified: Bool {
        return self.isVerifiedSubject.value
    }

    var isVerifiedPublisher: AnyPublisher<Bool, Never> {
        return self.isVerifiedSubject.eraseToAnyPublisher()
    }

    private var verifiedCode: CurrentValueSubject<String?, Never>
    private var isVerifiedSubject: CurrentValueSubject<Bool, Never> = .init(false)

    private let serviceProvider: ServicesProviderClient
    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    private var cancellables = Set<AnyCancellable>()

    init(title: String,
         serviceProvider: ServicesProviderClient,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.verifiedCode = .init(nil)

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater

        self.serviceProvider = serviceProvider
        
        self.userRegisterEnvelopUpdater
            .fullPhoneNumberPublisher
            .sink { [weak self] fullPhoneNumber in
                self?.phoneNumber.send(fullPhoneNumber)
            }
            .store(in: &self.cancellables)
    }

    func setConfirmationCode(_ code: String) {
        self.verifiedCode.send(code)
    }

    func setVerified(_ success: Bool, requestId: String?) {
        self.isVerifiedSubject.send(success)
        if success {
            self.userRegisterEnvelopUpdater.setVerifiedPhoneNumber(self.phoneNumber.value)
            self.userRegisterEnvelopUpdater.setMobileVerificationRequestId(requestId)
        }
        else {
            self.userRegisterEnvelopUpdater.setVerifiedPhoneNumber(nil)
            self.userRegisterEnvelopUpdater.setMobileVerificationRequestId(nil)
        }
    }
    
    var shouldSkipForm: Bool {
        return self.userRegisterEnvelopUpdater.isPhoneNumberVerified
    }

    //
    // Request Code
    func requestVerifyCode() -> AnyPublisher<PhoneVerificationResponse, PhoneVerificationError> {
        if !self.phoneNumber.value.isEmpty {
//            let response = PhoneVerificationResponse(id: "123", method: "sms", status: nil, errorCode: nil, message: nil, reference: nil)
//            return Just(response).setFailureType(to: PhoneVerificationError.self).eraseToAnyPublisher()
            return self.requestVerifyCode(self.phoneNumber.value)
        }
        else {
            return Fail(error: PhoneVerificationError.emptyPhoneNumber).eraseToAnyPublisher()
        }
    }

    private func requestVerifyCode(_ phoneNumber: String) -> AnyPublisher<PhoneVerificationResponse, PhoneVerificationError> {
        let formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                                                                        
        return self.serviceProvider.getMobileVerificationCode(forMobileNumber: formattedPhoneNumber)
            .map { response -> PhoneVerificationResponse in
                return PhoneVerificationResponse(id: nil,
                                                 method: nil,
                                                 status: nil,
                                                 errorCode: nil,
                                                 message: nil,
                                                 reference: nil)
                
            }
            .mapError { error -> PhoneVerificationError in
                if let verificationError = error as? PhoneVerificationError {
                    return verificationError
                }
                return .customError(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
                                                                    
                                                                    }

    //
    // Verify Code
    func checkVerificationCode(requestId: String, code: String) -> AnyPublisher<PhoneVerificationResponse, PhoneVerificationError> {
        return self.serviceProvider.verifyMobileCode(code: code, requestId: requestId)
            .map { response -> PhoneVerificationResponse in
                return PhoneVerificationResponse(id: nil,
                                                 method: nil,
                                                 status: nil,
                                                 errorCode: nil,
                                                 message: nil,
                                                 reference: nil)
                
            }
            .mapError { error -> PhoneVerificationError in
                if let verificationError = error as? PhoneVerificationError {
                    return verificationError
                }
                return .customError(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }


}

class ConfirmationCodeFormStepView: FormStepView {

    public var didUpdateConfirmationCode: (String) -> Void = { _ in }

    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var codeHeaderTextFieldView: HeaderTextFieldView = Self.createCodeHeaderTextFieldView()

    private lazy var resendBaseView: UIView = Self.createResendBaseView()
    private lazy var resendStackview: UIStackView = Self.createResendStackview()
    private lazy var resendLabel: UILabel = Self.createResendLabel()
    private lazy var resendButton: UIButton = Self.createResendButton()

    private let viewModel: ConfirmationCodeFormStepViewModel

    private var requestId: String = ""

    private var countdownTimer: Timer?
    private var totalTime = 60

    private var cancellables = Set<AnyCancellable>()

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: ConfirmationCodeFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()

        self.viewModel.isVerifiedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVerified in
                if isVerified {
                    self?.requestNextFormSubject.send()
                }
            }
            .store(in: &self.cancellables)

    }

    func configureSubviews() {

        self.viewModel.phoneNumber
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] updatedPhoneNumber in
                // We've sent a text to {phoneNumber} with the verification code.
                self?.subtitleLabel.text = Localization.localized("sent_text_message").replacingOccurrences(of: "{phoneNumber}", with: updatedPhoneNumber)
            })
            .store(in: &self.cancellables)

        self.stackView.addArrangedSubview(self.subtitleLabel)
        self.stackView.addArrangedSubview(self.codeHeaderTextFieldView)

        self.resendStackview.addArrangedSubview(self.resendLabel)
        self.resendStackview.addArrangedSubview(self.resendButton)
        self.resendBaseView.addSubview(self.resendStackview)

        NSLayoutConstraint.activate([
            self.resendButton.widthAnchor.constraint(equalToConstant: 94),
            self.resendStackview.topAnchor.constraint(equalTo: self.resendBaseView.topAnchor, constant: 0),
            self.resendStackview.leadingAnchor.constraint(equalTo: self.resendBaseView.leadingAnchor, constant: 8),
            self.resendStackview.trailingAnchor.constraint(equalTo: self.resendBaseView.trailingAnchor, constant: -8),
            self.resendStackview.bottomAnchor.constraint(equalTo: self.resendBaseView.bottomAnchor),
        ])

        self.stackView.addArrangedSubview(self.resendBaseView)

        NSLayoutConstraint.activate([
            self.codeHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
        ])

        self.titleLabel.text = self.viewModel.title

        self.resendButton.addTarget(self, action: #selector(self.didTapResendButton), for: .primaryActionTriggered)
        self.resendButton.isEnabled = false
        self.resendButton.alpha = 0.6

        self.codeHeaderTextFieldView.setTextContentType(.oneTimeCode)
        self.codeHeaderTextFieldView.setKeyboardType(.numberPad)

        self.codeHeaderTextFieldView.setPlaceholderText("Code")
        self.codeHeaderTextFieldView.setReturnKeyType(.send)
        self.codeHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.codeHeaderTextFieldView.resignFirstResponder()
        }

        self.codeHeaderTextFieldView.textPublisher
            .sink { [weak self] text in
                self?.codeHeaderTextFieldView.hideTipAndError()
                self?.viewModel.setConfirmationCode(text)
            }
            .store(in: &self.cancellables)



    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.codeHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.codeHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.codeHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.resendLabel.textColor = AppColor.textSecondary
        self.resendButton.setTitleColor(AppColor.highlightSecondary, for: .normal)
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .phoneConfirmation: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
    }

    override func didBecomeMainCenterStep() {
        super.didBecomeMainCenterStep()

        self.codeHeaderTextFieldView.becomeFirstResponder()

        self.sendCode()
    }

    override var canMoveToNextForm: Bool {

        if self.viewModel.isVerified {
            return true
        }
        else {
            self.viewModel
                .checkVerificationCode(requestId: self.requestId, code: self.codeHeaderTextFieldView.text)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        switch error {
                        case .nonMatchingCode:
                            self?.codeHeaderTextFieldView.showError(withMessage: "It looks like your code doesn't match")
                        case .emptyPhoneNumber:
                            self?.codeHeaderTextFieldView.showError(withMessage: "It looks like your code is empty")
                        case .decodingError:
                            self?.codeHeaderTextFieldView.showError(withMessage: "Something went wrong, please try again")
                        default:
                            self?.codeHeaderTextFieldView.showError(withMessage: "Something went wrong, please try again")
                        }
                        self?.viewModel.setVerified(false, requestId: nil)
                    }
                } receiveValue: { [weak self] response in
                    print("checkVerificationCode \(response)")
                    if response.errorCode == nil,
                       let method = response.method, method == "sms",
                       let status = response.status, status.lowercased() == "successful" {
                        self?.viewModel.setVerified(true, requestId: self?.requestId)
                    }
                }
                .store(in: &self.cancellables)

            return false
        }

    }

    override var shouldSkipForm: Bool {
        return self.viewModel.shouldSkipForm
    }

    private func startCountdown() {
        self.totalTime = 60

        self.countdownTimer?.invalidate()
        self.countdownTimer = nil

        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    private func sendCode() {

        self.resendButton.isEnabled = false
        self.resendButton.alpha = 0.6
        self.resendLabel.text = "Didn’t receive it?\nGet a new code in 01:00"

        self.startCountdown()

        self.viewModel.setVerified(false, requestId: nil)

        self.codeHeaderTextFieldView.setText("")

        self.viewModel
            .requestVerifyCode()
            .receive(on: DispatchQueue.main)
            .sink { completion in

            } receiveValue: { response in
                print("checkInputCode \(response)")
                if response.errorCode == nil, let id = response.id {
                    self.requestId = id
                }
            }
            .store(in: &self.cancellables)

    }

    @objc private func didTapResendButton() {
        self.sendCode()
    }

    @objc private func updateCountdown() {
        self.totalTime -= 1

        let minutes = self.totalTime / 60
        let seconds = self.totalTime % 60

        self.resendLabel.text = String(format: "Didn’t receive it?\nGet a new code in %02d:%02d", minutes, seconds)

        if self.totalTime <= 0 {
            self.resendLabel.text = "Didn’t receive it?\nGet a new code."
            self.resendButton.isEnabled = true
            self.resendButton.alpha = 1.0
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil
        }
    }

}

extension ConfirmationCodeFormStepView {

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private static func createResendBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }

    private static func createResendStackview() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }

    private static func createResendLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .left
        label.text = "Didn’t receive it?\nGet a new code in 01:00"

        return label
    }

    private static func createResendButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("Resend", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createCodeHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

}
