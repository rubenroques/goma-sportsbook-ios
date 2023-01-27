//
//  SteppedRegistrationViewController.swift
//  
//
//  Created by Ruben Roques on 11/01/2023.
//

import Foundation
import Combine
import UIKit
import ServicesProvider
import Theming

public class SteppedRegistrationViewModel {

    var currentStep: CurrentValueSubject<Int, Never> = .init(0)
    var numberOfSteps: CurrentValueSubject<Int, Never> = .init(0)

    var userRegisterEnvelop: UserRegisterEnvelop

    let serviceProvider: ServicesProviderClient
    let userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldPushPhoneConfirmationStep: PassthroughSubject<Void, Never> = .init()
    var shouldPushSuccessStep: PassthroughSubject<Void, Never> = .init()

    var suggestedNickname: AnyPublisher<String?, Never> {
        return self.userRegisterEnvelopUpdater.didUpdateUserRegisterEnvelop
            .map { updatedUserRegisterEnvelop -> String? in
                let firstLetter = (updatedUserRegisterEnvelop.name ?? "").first
                let surname = updatedUserRegisterEnvelop.surname?.replacingOccurrences(of: " ", with: "")
                if let firstLetter, let surname {
                    let suggestion = "\(String(firstLetter))\(surname)"
                    return suggestion.lowercased()
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    var confirmationCodeFilled: String?

    private var cancellables = Set<AnyCancellable>()

    public init(userRegisterEnvelop: UserRegisterEnvelop,
                serviceProvider: ServicesProviderClient,
                userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.userRegisterEnvelop = userRegisterEnvelop
        self.currentStep = .init( self.userRegisterEnvelop.currentRegisterStep() )
        self.numberOfSteps = .init(0)
        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
        
    }

    func scrollToPreviousStep() {
        var nextStep = currentStep.value - 1
        if nextStep < 0 {
            nextStep = 0
        }
        self.currentStep.send(nextStep)
    }

    func scrollToNextStep() {
        var nextStep = currentStep.value + 1
        if nextStep > numberOfSteps.value {
            nextStep = numberOfSteps.value
        }
        self.currentStep.send(nextStep)
    }

    func scrollToIndex(_ index: Int) {
        self.currentStep.send(index)
    }

    func setNumberOfSteps(_ totalSteps: Int) {
        self.numberOfSteps.send(totalSteps)
    }

    func requestRegister() -> Bool {

        guard
            let form = self.registerFormFromRegisterEnvelop(self.userRegisterEnvelop)
        else {
            return false
        }

        self.isLoading.send(true)

        serviceProvider.signUp(form: form)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in

                switch completion {
                case .failure(let error):
                    print("Error \(error)")
                case .finished:
                    ()
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] userCreated in
                if userCreated {
                    print("Created \(userCreated)")
                    self?.shouldPushSuccessStep.send()
                }
            }
            .store(in: &self.cancellables)

        return true
    }
//
//    func confirmPhoneCode() -> Bool {
//        guard
//            let email = self.userRegisterEnvelop.email,
//            let code = self.confirmationCodeFilled
//        else {
//            return false
//        }
//
//        self.isLoading.send(true)
//
//        serviceProvider
//            .signupConfirmation(email, confirmationCode: code)
//            .sink { [weak self] completion in
//                switch completion {
//                case .failure(let serviceProviderError):
//                    print("Error \(serviceProviderError)")
//                    self?.isLoading.send(false)
//                case .finished:
//                    print("Finished")
//                }
//            } receiveValue: { [weak self] phoneConfirmation in
//                if self?.completeUserRegistration() ?? false {
//                    // confirmation sent
//                }
//                else {
//                    // send error on completion
//                }
//            }
//            .store(in: &self.cancellables)
//
//        return true
//    }
//
//    func completeUserRegistration() -> Bool {
//
//        guard
//            let form = self.completeRegisterFormFromRegisterEnvelop(self.userRegisterEnvelop)
//        else {
//            return false
//        }
//
//        self.serviceProvider.signUpCompletion(form: form)
//            .sink { [weak self] completion in
//                switch completion {
//                case .failure(let serviceProviderError):
//                    print("Error \(serviceProviderError)")
//
//                case .finished:
//                    print("Finished")
//                }
//                self?.isLoading.send(false)
//            } receiveValue: { [weak self] phoneConfirmation in
//                self?.shouldPushSuccessStep.send()
//            }
//            .store(in: &self.cancellables)
//
//        return true
//    }

    private func registerFormFromRegisterEnvelop(_ envelop: UserRegisterEnvelop) -> ServicesProvider.SignUpForm? {

        guard
            let email = envelop.email,
            let username = envelop.nickname,
            let password = envelop.password,
            let mobilePrefix = envelop.phonePrefixCountry?.phonePrefix,
            let mobileNumber = envelop.phoneNumber,
            let countryBirthIsoCode = envelop.countryBirth?.iso2Code,
            let firstName = envelop.name,
            let lastName = envelop.surname,
            let gender = envelop.gender,
            let streetAddress = envelop.streetAddress,
            let birthDate = envelop.dateOfBirth,
            let placeAddress = envelop.placeAddress
        else {
            return nil
        }

        var genderString = ""
        switch gender {
        case .male:
            genderString = "M"
        case .female:
            genderString = "F"
        }

        return ServicesProvider.SignUpForm.init(email: email,
                                                username: username,
                                                password: password,
                                                birthDate: birthDate,
                                                mobilePrefix: mobilePrefix,
                                                mobileNumber: mobileNumber,
                                                nationalityIsoCode: countryBirthIsoCode,
                                                currencyCode: "EUR",
                                                firstName: firstName,
                                                lastName: lastName,
                                                gender: genderString,
                                                address: streetAddress,
                                                province: nil,
                                                city: placeAddress,
                                                countryIsoCode: countryBirthIsoCode,
                                                bonusCode: envelop.promoCode,
                                                receiveMarketingEmails: envelop.acceptedMarketing,
                                                avatarName: envelop.avatarName,
                                                placeOfBirth: envelop.placeBirth,
                                                additionalStreetAddress: envelop.additionalStreetAddress,
                                                godfatherCode: envelop.godfatherCode)
    }

}

public class SteppedRegistrationViewController: UIViewController {

    public var didRegisteredUserAction: (UserRegisterEnvelop) -> Void = { _ in }

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var progressView: UIProgressView = Self.createProgressView()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var stepsScrollView: UIScrollView = Self.createStepsScrollView()
    private lazy var stepsContentStackView: UIStackView = Self.createStepsContentStackView()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()

    private let viewModel: SteppedRegistrationViewModel

    private var stepsViews: [RegisterStepView] = []

    private var registrationCompletionPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: SteppedRegistrationViewModel) {

        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        Publishers.CombineLatest(self.viewModel.currentStep, self.viewModel.numberOfSteps)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentStep, totalSteps in
                if totalSteps > 0 {
                    let progress = Float(currentStep) / Float(totalSteps)
                    self?.progressView.setProgress(progress, animated: true)
                }
                else {
                    self?.progressView.setProgress(0.0, animated: false)
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.currentStep
            .receive(on: DispatchQueue.main)
            .sink { currentStep in
                if currentStep == 0 {
                    self.backButton.alpha = 0.5
                    self.backButton.isHidden = false
                    self.cancelButton.isHidden = false
                    self.progressView.isHidden = false
                }
                else if currentStep == 7 {
                    self.backButton.isHidden = true
                    self.cancelButton.isHidden = true
                    self.progressView.isHidden = true
                }
                else {
                    self.backButton.alpha = 1.0
                    self.backButton.isHidden = false
                    self.cancelButton.isHidden = false
                    self.progressView.isHidden = false
                }
            }
            .store(in: &self.cancellables)

//        self.viewModel.shouldPushPhoneConfirmationStep
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                self?.showPhoneVerification()
//            }
//            .store(in: &self.cancellables)

        self.viewModel.shouldPushSuccessStep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.didRegisteredUser()
            }
            .store(in: &self.cancellables)

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.loadingBaseView.isHidden = !loading

                if loading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &self.cancellables)

        self.createSteps()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let currentStepPublisher = self.viewModel.currentStep
            .removeDuplicates()
            .map { [weak self] (currentPage: Int) -> (currentPage: Int, yOffset: CGFloat) in
                return (currentPage, (self?.contentBaseView.frame.height ?? 0.0) * CGFloat(currentPage))
            }
            .receive(on: DispatchQueue.main)

        currentStepPublisher.first()
            .sink { [weak self] pageTupple in
                self?.scrollToItem(newPage: pageTupple.currentPage, offset: pageTupple.yOffset, animated: false)
            }
            .store(in: &self.cancellables)

        currentStepPublisher.dropFirst()
            .sink { [weak self] pageTupple in
                self?.scrollToItem(newPage: pageTupple.currentPage, offset: pageTupple.yOffset, animated: true)
            }
            .store(in: &self.cancellables)

    }

    // MARK: - Layout and Theme
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)

        self.topSafeAreaView.backgroundColor = AppColor.backgroundPrimary
        self.headerBaseView.backgroundColor = AppColor.backgroundPrimary
        self.progressView.backgroundColor = AppColor.backgroundPrimary
        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary
        self.stepsScrollView.backgroundColor = AppColor.backgroundPrimary
        self.stepsContentStackView.backgroundColor = AppColor.backgroundPrimary
        self.footerBaseView.backgroundColor = AppColor.backgroundPrimary
        self.bottomSafeAreaView.backgroundColor = AppColor.backgroundPrimary

        //
        self.progressView.trackTintColor = AppColor.backgroundSecondary
        self.progressView.progressTintColor = AppColor.highlightSecondary

        // Continue button styling
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.continueButton.setTitleColor(AppColor.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.continueButton.layer.cornerRadius = 8
        self.continueButton.layer.masksToBounds = true
        self.continueButton.backgroundColor = .clear
    }

    private func createSteps() {

        let defaultCountryIso3Code = "FRA"

        // Step 1
        let nameRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))

        var gender: GenderFormStepViewModel.Gender? = nil
        if let filledGender = self.viewModel.userRegisterEnvelop.gender {
            switch filledGender {
            case .male:
                gender = .male
            case .female:
                gender = .female
            }
        }

        let genderFormStepViewModel = GenderFormStepViewModel(title: "Gender", selectedGender: gender, userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater)
        let genderFormStepView = GenderFormStepView(viewModel: genderFormStepViewModel)

        let namesFormStepView = NamesFormStepView(viewModel: NamesFormStepViewModel(title: "Names",
                                                                                    firstName: self.viewModel.userRegisterEnvelop.name,
                                                                                    lastName: self.viewModel.userRegisterEnvelop.surname,
                                                                                    userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))

        nameRegisterStepView.addFormView(formView: genderFormStepView)
        nameRegisterStepView.addFormView(formView: namesFormStepView)

        self.addStepView(registerStepView: nameRegisterStepView)
        //


        // Step 2
        let avatarNickRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))

        let avatarFormStepView = AvatarFormStepView(viewModel: AvatarFormStepViewModel(title: "Avatar",
                                                                                       subtitle: "Choose one of our standard avatars for your icon.",
                                                                                       avatarIconNames: [
                                                                                        "avatar1",
                                                                                        "avatar2",
                                                                                        "avatar3",
                                                                                        "avatar4",
                                                                                        "avatar5",
                                                                                        "avatar6",
                                                                                       ],
                                                                                       selectedAvatarName: self.viewModel.userRegisterEnvelop.avatarName,
                                                                                      userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))

        let nicknameFormStepViewModel = NicknameFormStepViewModel(title: "Nickname",
                                                                  nickname: self.viewModel.userRegisterEnvelop.nickname,
                                                                  serviceProvider: self.viewModel.serviceProvider,
                                                                  userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater)
        let nicknameFormStepView = NicknameFormStepView(viewModel: nicknameFormStepViewModel)


        self.viewModel.suggestedNickname
            .removeDuplicates()
            .compactMap({ $0 })
            .sink { suggestedNickname in
                nicknameFormStepViewModel.setGeneratedNickname(suggestedNickname)
            }
            .store(in: &self.cancellables)

        avatarNickRegisterStepView.addFormView(formView: avatarFormStepView)
        avatarNickRegisterStepView.addFormView(formView: nicknameFormStepView)

        self.addStepView(registerStepView: avatarNickRegisterStepView)
        //


        // Step 3
        //
        let ageCountryRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
        let viewModel = AgeCountryFormStepViewModel.init(title: "Age and Country",
                                                         defaultCountryIso3Code: defaultCountryIso3Code,
                                                         birthDate: self.viewModel.userRegisterEnvelop.dateOfBirth,
                                                         selectedCountry: self.viewModel.userRegisterEnvelop.countryBirth,
                                                         placeBirth: self.viewModel.userRegisterEnvelop.placeBirth,
                                                         serviceProvider: self.viewModel.serviceProvider,
                                                         userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater)
        ageCountryRegisterStepView.addFormView(formView: AgeCountryFormStepView(viewModel: viewModel))

        self.addStepView(registerStepView: ageCountryRegisterStepView)
        //

        // -----

        // Step 4
        let addressRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
        let addressFormStepView = AddressFormStepView(viewModel: AddressFormStepViewModel(title: "Address",
                                                                                          place: self.viewModel.userRegisterEnvelop.placeAddress,
                                                                                          street: self.viewModel.userRegisterEnvelop.streetAddress,
                                                                                          additionalStreet: self.viewModel.userRegisterEnvelop.additionalStreetAddress,
                                                                                          userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))
        addressRegisterStepView.addFormView(formView: addressFormStepView)
        self.addStepView(registerStepView: addressRegisterStepView)
        //


        // Step 5
        //
        let contactsRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
        let contactsFormStepView = ContactsFormStepView(viewModel: ContactsFormStepViewModel(title: "Contacts",
                                                                                             email: self.viewModel.userRegisterEnvelop.email,
                                                                                             phoneNumber: self.viewModel.userRegisterEnvelop.phoneNumber,
                                                                                             prefixCountry: self.viewModel.userRegisterEnvelop.phonePrefixCountry,
                                                                                             defaultCountryIso3Code: defaultCountryIso3Code,
                                                                                             serviceProvider: self.viewModel.serviceProvider,
                                                                                             userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))

        contactsRegisterStepView.addFormView(formView: contactsFormStepView)
        self.addStepView(registerStepView: contactsRegisterStepView)
        //
        //

        // Step 6
        //
        let passwordRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
        let passwordFormStepView = PasswordFormStepView(viewModel: PasswordFormStepViewModel(title: "Security",
                                                                  password: self.viewModel.userRegisterEnvelop.password,
                                                                  userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))
        passwordRegisterStepView.addFormView(formView: passwordFormStepView)
        self.addStepView(registerStepView: passwordRegisterStepView)
        //
        //

        // Step 7
        //
        let termsPromoRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))

        let termsCondFormStepView = TermsCondFormStepView(viewModel: TermsCondFormStepViewModel(title: "Terms and Conditions",
                                                                                                isMarketingOn: self.viewModel.userRegisterEnvelop.acceptedMarketing,
                                                                                                isTermsOn: self.viewModel.userRegisterEnvelop.acceptedTerms,
                                                                                                userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))


        let promoCodeFormStepView = PromoCodeFormStepView(viewModel: PromoCodeFormStepViewModel.init(title: "Promo",
                                                                                                     promoCode: self.viewModel.userRegisterEnvelop.promoCode,
                                                                                                     godfatherCode: self.viewModel.userRegisterEnvelop.godfatherCode,
                                                                                                     userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))

        termsPromoRegisterStepView.addFormView(formView: termsCondFormStepView)
        termsPromoRegisterStepView.addFormView(formView: promoCodeFormStepView)

        self.addStepView(registerStepView: termsPromoRegisterStepView)
        //
        //

//
//        //
//        // Step 8
//        let confirmationCodeRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
//
//        let confirmationCodeFormStepViewModel = ConfirmationCodeFormStepViewModel(title: "Confirmation Code", userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater)
//        let confirmationCodeFormStepView = ConfirmationCodeFormStepView(viewModel: confirmationCodeFormStepViewModel)
//        confirmationCodeFormStepView.didUpdateConfirmationCode = { [weak self] code in
//            self?.viewModel.confirmationCodeFilled = code
//        }
//
//        confirmationCodeRegisterStepView.addFormView(formView: confirmationCodeFormStepView)
//
//        self.addStepView(registerStepView: confirmationCodeRegisterStepView)
//        //
//        //

        //
        // Step 8
//        let successSignUpRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel(serviceProvider: self.viewModel.serviceProvider))
//        let successSignUpFormStepView = SuccessSignUpFormStepView(viewModel: SuccessSignUpFormStepViewModel(title: "Sign Up",
//                                                                                                            userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater))
//
//        successSignUpRegisterStepView.addFormView(formView: successSignUpFormStepView)
//        self.addStepView(registerStepView: successSignUpRegisterStepView)
//        //
        //

        //
        //
        self.configureRegistrationCompletionPublisher()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func addStepView(registerStepView: RegisterStepView) {

        registerStepView.alpha = 0.0

        self.stepsContentStackView.addArrangedSubview(registerStepView)

        NSLayoutConstraint.activate([
            registerStepView.heightAnchor.constraint(equalTo: self.contentBaseView.heightAnchor)
        ])

        self.stepsViews.append(registerStepView)

        self.viewModel.setNumberOfSteps(self.stepsViews.count)
    }

    func configureRegistrationCompletionPublisher() {

        self.registrationCompletionPublisher?.cancel()

        let registrationPerStepPublisher = self.stepsViews.map(\.isRegisterStepCompleted).combineLatest()
        self.registrationCompletionPublisher = Publishers.CombineLatest(self.viewModel.currentStep, registrationPerStepPublisher)
            .map { (currentPage, completionPerStepArray) -> Bool in
                let isStepCompleted = completionPerStepArray[safe: currentPage] ?? false
                return isStepCompleted
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isCurrentStepCompleted in
                self?.continueButton.isEnabled = isCurrentStepCompleted
            })

    }

}

public extension SteppedRegistrationViewController {

    @objc private func didTapContinueButton() {

        switch self.viewModel.currentStep.value {
        case 6:
            self.requestSignUp()
        default:
            self.viewModel.scrollToNextStep()
        }

    }

    @objc private func didTapBackButton() {
        self.viewModel.scrollToPreviousStep()
    }

    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }

    private func didRegisteredUser() {
        self.didRegisteredUserAction(self.viewModel.userRegisterEnvelop)
    }

}

public extension SteppedRegistrationViewController {

    func requestSignUp() {
        _ = self.viewModel.requestRegister()
    }

}

public extension SteppedRegistrationViewController {

    private func scrollToItem(newPage: Int, offset: CGFloat, animated: Bool) {

        self.scrollToItem(newPage: newPage, animated: animated)
        self.scrollToOffset(yPosition: offset, animated: animated)

    }

    private func scrollToItem(newPage: Int, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: animated ? 0.14 : 0.0) {
            if self.viewModel.currentStep.value == newPage {
                self.stepsViews[safe: newPage]?.alpha = 1.0
            }
            else {
                self.stepsViews[safe: self.viewModel.currentStep.value]?.alpha = 0.0
                self.stepsViews[safe: newPage]?.alpha = 1.0
            }
        }
        CATransaction.commit()
    }

    private func scrollToOffset(yPosition: CGFloat, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: animated ? 0.89 : 0.0) {
            self.stepsScrollView.contentOffset = CGPoint(x: 0.0, y: yPosition)
        }
        CATransaction.commit()
    }

}

public extension SteppedRegistrationViewController {

    private static var headerHeight: CGFloat {
        68
    }

    private static var footerHeight: CGFloat {
        76
    }

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "back_icon", in: Bundle.module, with: nil)
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createProgressView() -> UIProgressView {
        let progressView = UIProgressView()
        progressView.progress = 0.5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStepsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createStepsContentStackView() -> UIStackView {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.stepsScrollView.isScrollEnabled = false

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)
        self.continueButton.addTarget(self, action: #selector(self.didTapContinueButton), for: .primaryActionTriggered)
        self.cancelButton.addTarget(self, action: #selector(self.didTapCancelButton), for: .primaryActionTriggered)

        self.initConstraints()
    }

    private func initConstraints() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.progressView)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.stepsScrollView)
        self.stepsScrollView.addSubview(self.stepsContentStackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.loadingBaseView.addSubview(self.loadingView)
        self.view.addSubview(self.loadingBaseView)

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: Self.headerHeight),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

            self.progressView.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.progressView.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 7),
            self.progressView.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor, constant: -19),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.footerBaseView.topAnchor),

            self.stepsScrollView.frameLayoutGuide.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
            self.stepsScrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),
            self.stepsScrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.stepsScrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.stepsContentStackView.topAnchor.constraint(equalTo: self.stepsScrollView.topAnchor),
            self.stepsContentStackView.bottomAnchor.constraint(equalTo: self.stepsScrollView.bottomAnchor),
            self.stepsContentStackView.leadingAnchor.constraint(equalTo: self.stepsScrollView.leadingAnchor),
            self.stepsContentStackView.trailingAnchor.constraint(equalTo: self.stepsScrollView.trailingAnchor),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: Self.footerHeight),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.continueButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.continueButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.footerBaseView.topAnchor),

            self.loadingView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),

        ])

        let stepsViewCenterY = self.stepsContentStackView.centerYAnchor.constraint(equalTo: self.stepsScrollView.centerYAnchor)
        stepsViewCenterY.priority = .defaultLow

        let stepsViewHeight = self.stepsContentStackView.heightAnchor.constraint(greaterThanOrEqualTo: self.contentBaseView.heightAnchor)
        stepsViewHeight.priority = .defaultLow

        NSLayoutConstraint.activate([
            self.stepsContentStackView.centerXAnchor.constraint(equalTo: self.stepsScrollView.centerXAnchor),
            stepsViewCenterY,
            stepsViewHeight
        ])

    }

}
