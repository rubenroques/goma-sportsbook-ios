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
import Extensions
import Lottie

public class SteppedRegistrationViewModel {

    var registerSteps: [RegisterStep] = []

    public var currentStep: CurrentValueSubject<Int, Never> = .init(0)
    public var numberOfSteps: Int {
        return self.registerSteps.count
    }

    public var progressPercentage: AnyPublisher<Float, Never> {
        return self.currentStep.map { [weak self] currentStep in
            let totalSteps = self?.numberOfSteps ?? 0
            if totalSteps > 0 {
                let calculatedPercentage =  Float(currentStep) / Float(totalSteps-1)
                return calculatedPercentage
            }
            return Float(0.0)
        }.eraseToAnyPublisher()
    }

    public var userRegisterEnvelop: UserRegisterEnvelop

    let serviceProvider: ServicesProviderClient
    let userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)

    public var shouldPushSuccessStep: PassthroughSubject<Void, Never> = .init()
    public var showRegisterErrors: CurrentValueSubject<[RegisterError]?, Never> = .init(nil)

    var confirmationCodeFilled: String?
    
    public var hasReferralCode: Bool = false
    
    public var hasLegalAgeWarning: Bool
    
    var registerFlowType: RegisterFlow.FlowType

    private var cancellables = Set<AnyCancellable>()

    public init(registerSteps: [RegisterStep]? = nil,
                currentStep: Int? = nil,
                userRegisterEnvelop: UserRegisterEnvelop,
                serviceProvider: ServicesProviderClient,
                userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
                hasLegalAgeWarning: Bool = false,
                registerFlowType: RegisterFlow.FlowType) {
        
        self.registerFlowType = registerFlowType
        
        self.hasLegalAgeWarning = hasLegalAgeWarning

        self.userRegisterEnvelop = userRegisterEnvelop

        if let currentStep {
            self.currentStep = .init(currentStep)
        }
        else {
            self.currentStep = .init(self.userRegisterEnvelop.currentRegisterStep(registerFlowType: self.registerFlowType))
        }

        self.serviceProvider = serviceProvider
        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
        
        if let registerSteps {
            self.registerSteps = registerSteps
        }
        else {
            self.registerSteps = self.defaultRegisterSteps()
        }
        
        self.userRegisterEnvelopUpdater.didUpdateUserRegisterEnvelop
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUserRegisterEnvelop in
                self?.userRegisterEnvelop = updatedUserRegisterEnvelop
            }
            .store(in: &self.cancellables)
            
        
    }

    private func defaultRegisterSteps() -> [RegisterStep] {
        switch self.registerFlowType {
        case .goma:
            return [
                RegisterStep(forms: [.personalInfo]),
                RegisterStep(forms: [.avatar]),
                RegisterStep(forms: [.password]),
            ]
        case .betson:
            return [
                RegisterStep(forms: [.gender, .names]),
                RegisterStep(forms: [.avatar, .nickname]),
                RegisterStep(forms: [.ageCountry]),
                RegisterStep(forms: [.address]),
                RegisterStep(forms: [.contacts]),
                RegisterStep(forms: [.password]),
                RegisterStep(forms: [.terms, .promoCodes])
            ]
        }
        
    }

    public func scrollToPreviousStep() {
        var nextStep = currentStep.value - 1
        if nextStep < 0 {
            nextStep = 0
        }
        self.currentStep.send(nextStep)
    }

    public func scrollToNextStep() {
        var nextStep = currentStep.value + 1
        if nextStep > numberOfSteps {
            nextStep = numberOfSteps
        }
        self.currentStep.send(nextStep)
    }

    public func scrollToIndex(_ index: Int) {

        if index > numberOfSteps {
            return
        }
        else if index < 0 {
            return
        }

        self.currentStep.send(index)
    }

    func isLastStep(index: Int) -> Bool {
        return index == self.numberOfSteps-1
    }

    func indexForFormStep(_ formStep: FormStep) -> Int? {
        for (index, registerStep) in registerSteps.enumerated() {
            if registerStep.forms.contains(formStep) {
                return index
            }
        }
        return nil
    }

    public func requestRegister() -> Bool {

        guard
            var form = self.userRegisterEnvelop.convertToSignUpForm()
        else {
            return false
        }

        self.isLoading.send(true)
        
        self.serviceProvider.getAllConsents()
            .flatMap({ [weak self] (consentInfos: [ConsentInfo]) -> AnyPublisher<SignUpResponse, ServiceProviderError> in

                guard
                    let self = self
                else {
                    return Fail(outputType: SignUpResponse.self, failure: ServiceProviderError.unknown).eraseToAnyPublisher()
                }
                
                for consentInfo in consentInfos {
                    switch consentInfo.key.lowercased() {
                    case "terms":
                        form.consentedIds.append(String(consentInfo.consentVersionId))
                        
                    case "sms_promotions", "email_promotions":
                        if form.receiveMarketingEmails ?? false {
                            form.consentedIds.append(String(consentInfo.consentVersionId))
                        }
                        else {
                            form.unConsentedIds.append(String(consentInfo.consentVersionId))
                        }
                    default:
                        print("consentInfos unknown")
                    }
                }
                
                return self.serviceProvider.signUp(form: form).eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("RegisterFlow ServiceProvider.signUp Error \(error)")
                case .finished:
                    ()
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] signUpResponse in
                if signUpResponse.successful {
                    self?.shouldPushSuccessStep.send()
                }
                else {
                    if let signUpErrors = signUpResponse.errors {
                        let errorsDictionary = signUpErrors.map { error in
                            return RegisterError(field: error.field, error: error.error)
                        }
                        self?.showRegisterErrors.send(errorsDictionary)
                    }
                }
            }
            .store(in: &self.cancellables)

        return true
    }
    
    func requestBasicRegister() -> Bool {

        guard
            var form = self.userRegisterEnvelop.convertToBasicSignUpForm()

        else {
            return false
        }

        self.isLoading.send(true)
        
        self.serviceProvider.basicSignUp(form: form)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("RegisterFlow ServiceProvider.basicSignUp Error \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.processRegisterError(errorMessage: message)
                    default:
                        let errorsDictionary = [RegisterError(field: "personalInfo", error: "INVALID_PERSONAL_INFO")]
                        self?.showRegisterErrors.send(errorsDictionary)
                    }
                    
                case .finished:
                    ()
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] basicSignUpResponse in
                if basicSignUpResponse.successful {
                    self?.shouldPushSuccessStep.send()
                }
                else {
                    if let basicSignUpErrors = basicSignUpResponse.errors {
                        let errorsDictionary = basicSignUpErrors.map { error in
                            return RegisterError(field: error.field, error: error.error)
                        }
                        self?.showRegisterErrors.send(errorsDictionary)
                    }
                }
            }
            .store(in: &self.cancellables)
        
        return true
    }

    func processRegisterError(errorMessage: String) {
        var errorsDictionary = [RegisterError]()
        
        if errorMessage.contains("1 more error") {
            let registerError = RegisterError(field: "personalInfo", error: "INVALID_PERSONAL_INFO")
            errorsDictionary.append(registerError)
        }
        else if errorMessage.contains("The email has already been taken") {
            let registerError = RegisterError(field: "personalInfo", error: "EMAIL_DUPLICATE")
            errorsDictionary.append(registerError)
        }
        else if errorMessage.contains("The username has already been taken") {
            let registerError = RegisterError(field: "personalInfo", error: "USERNAME_DUPLICATE")
            errorsDictionary.append(registerError)
        }
        
        self.showRegisterErrors.send(errorsDictionary)
    }
}

public class SteppedRegistrationViewController: UIViewController {

    public var didRegisteredUserAction: (UserRegisterEnvelop) -> Void = { _ in }
    public var sendRegisterEventAction: ((String) -> Void)?

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var legalAgeImageView: UIImageView = Self.createLegalAgeImageView()

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var progressView: TallProgressBarView = Self.createProgressView()

    private lazy var progressEndContainerView: UIView = Self.createProgressEndContainerView()
    var progressEndContainerViewWidth: NSLayoutConstraint?
    private lazy var progressEndLottieView: LottieAnimationView = Self.createProgressEndLottieView()

    private lazy var progressEndImageView: UIImageView = Self.createProgressImageView()

    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var stepsScrollView: UIScrollView = Self.createStepsScrollView()
    private lazy var stepsContentStackView: UIStackView = Self.createStepsContentStackView()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()
    
    // Constraints
    private lazy var headerViewTopToBannerConstraint: NSLayoutConstraint = Self.createHeaderViewTopToBannerConstraint()
    private lazy var headerViewTopToScreenConstraint: NSLayoutConstraint = Self.createHeaderViewTopToScreenConstraint()

    private let viewModel: SteppedRegistrationViewModel

    private var registerStepViews: [RegisterStepView] = []
    private var formStepViews: [FormStepView] = []

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

    private func animateProgress(toPercentage percentage: Float, previousPercentage: Float) {

        UIView.animate(withDuration: 0.1, animations: {
            // Show lottie
            if previousPercentage < percentage {
                self.progressEndLottieView.alpha = 1.0
            }
        }, completion: { completion in

            UIView.animate(withDuration: 0.45) {
                // 2 - animate progress
                self.progressView.setProgress(percentage, animated: true)

                let newWidth = self.progressView.frame.width * CGFloat(percentage)
                self.progressEndContainerViewWidth?.constant = newWidth
                self.headerBaseView.setNeedsLayout()
                self.headerBaseView.layoutIfNeeded()

            } completion: { completed in
//                UIView.animate(withDuration: 0.22, delay: 1.5) {
//                    // 3 - Hide lottie after 3 seconds
//                    if percentage >= 1.0 {
//                        self.progressEndLottieView.alpha = 1.0
//                    }
//                    else {
//                        self.progressEndLottieView.alpha = 0.0
//                    }
//                }
            }
        })


    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
        
        if self.viewModel.hasLegalAgeWarning {
            self.headerViewTopToScreenConstraint.isActive = false
            self.headerViewTopToBannerConstraint.isActive = true
        }
        else {
            self.headerViewTopToScreenConstraint.isActive = true
            self.headerViewTopToBannerConstraint.isActive = false
        }

        self.viewModel.progressPercentage
            .withPrevious()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] previousPercentage, progressPercentage in
                self?.animateProgress(toPercentage: progressPercentage, previousPercentage: previousPercentage ?? 0.0)
            }
            .store(in: &self.cancellables)

        self.viewModel.currentStep
            .receive(on: DispatchQueue.main)
            .sink { currentStep in
                if currentStep == 0 {
                    self.backButton.alpha = 0.0
                    self.backButton.isHidden = false
                    self.cancelButton.isHidden = false
                    self.progressView.isHidden = false
                }
                else {
                    self.backButton.alpha = 1.0
                    self.backButton.isHidden = false
                    self.cancelButton.isHidden = false
                    self.progressView.isHidden = false
                }
            }
            .store(in: &self.cancellables)

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

        self.viewModel.showRegisterErrors
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errors in
                self?.presentRegisterErrors(errors)
            }
            .store(in: &self.cancellables)

        self.createSteps()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.progressEndLottieView.play()

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
        self.continueButton.setTitleColor(AppColor.buttonTextDisablePrimary, for: .disabled)

        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.continueButton.layer.cornerRadius = 8
        self.continueButton.layer.masksToBounds = true
        self.continueButton.backgroundColor = .clear

        self.registerStepViews.forEach { registerStepView in
            registerStepView.setupWithTheme()
        }
    }

    private func createSteps() {
        self.formStepViews = []

        for (index, registerStep) in self.viewModel.registerSteps.enumerated() {

            let registerStepViewModel = RegisterStepViewModel(index: index)
            let registerStepView = RegisterStepView(viewModel: registerStepViewModel)

            for formStep in registerStep.forms {
                var hasReferralCode: Bool? = nil
                
                if formStep == .promoCodes {
                    hasReferralCode = self.viewModel.hasReferralCode
                }
                
                let formStepView = FormStepViewFactory.formStepView(forFormStep: formStep,
                                                                    serviceProvider: self.viewModel.serviceProvider,
                                                                    userRegisterEnvelop: self.viewModel.userRegisterEnvelop,
                                                                    userRegisterEnvelopUpdater: self.viewModel.userRegisterEnvelopUpdater, hasReferralCode: hasReferralCode,
                                                                    registerFlowType: self.viewModel.registerFlowType)
                registerStepView.addFormView(formView: formStepView)
                self.formStepViews.append(formStepView)
            }

            self.addStepView(registerStepView: registerStepView)

            registerStepView
                .requestNextFormSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.scrollToNextStep()
                }
                .store(in: &self.cancellables)
        }

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

        self.registerStepViews.append(registerStepView)
    }

    func configureRegistrationCompletionPublisher() {

        self.registrationCompletionPublisher?.cancel()

        let registrationPerStepPublisher = self.registerStepViews.map(\.isRegisterStepCompleted).combineLatest()
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
        self.scrollToNextStep()
    }

    @objc private func didTapBackButton() {
        self.scrollToPreviousStep()
    }

    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }

    private func didRegisteredUser() {
        self.didRegisteredUserAction(self.viewModel.userRegisterEnvelop)
    }

    private func scrollToPreviousStep() {
        // Check with the register step and inside forms if we can go back
        let currentPage = self.viewModel.currentStep.value
        guard
            let registerStepView = self.registerStepViews[safe: currentPage]
        else {
            return
        }

        let previousRegisterStepView = self.registerStepViews[safe: currentPage-1]

        if !registerStepView.canMoveToPreviousStep {
            return
        }

        if previousRegisterStepView?.shouldSkipStep ?? false {
            self.viewModel.scrollToIndex(self.viewModel.currentStep.value-2)
        }
        else {
            self.viewModel.scrollToPreviousStep()
        }

    }

    private func scrollToNextStep() {

        // Check with the register step and inside forms if we can go to the next
        let currentPage = self.viewModel.currentStep.value
        guard
            let registerStepView = self.registerStepViews[safe: currentPage]
        else {
            return
        }

        // Optimove initiate register step
        if currentPage == 1 {
            let username = self.viewModel.userRegisterEnvelop.nickname ?? ""
            self.sendRegisterEventAction?(username)
        }

        let nextRegisterStepView = self.registerStepViews[safe: currentPage+1]

        if !registerStepView.canMoveToNextStep {
            return
        }

        if self.viewModel.isLastStep(index: self.viewModel.currentStep.value) {
            self.requestSignUp()
        }
        else {
            if nextRegisterStepView?.shouldSkipStep ?? false {
                self.viewModel.scrollToIndex(self.viewModel.currentStep.value+2)
            }
            else {
                self.viewModel.scrollToNextStep()
            }
        }

    }

}

public extension SteppedRegistrationViewController {

    func requestSignUp() {
        switch self.viewModel.registerFlowType {
        case .goma:
            _ = self.viewModel.requestBasicRegister()
        case .betson:
            _ = self.viewModel.requestRegister()
        }
        
    }

    func presentRegisterErrors(_ registerErrors: [RegisterError]) {

        for registerError in registerErrors {
            for formStepView in self.formStepViews {
                if let associatedFormStep = registerError.associatedFormStep {
                    formStepView.presentError(registerError, forFormStep: associatedFormStep)
                }
            }
        }

        for formStepView in self.formStepViews {
            for registerError in registerErrors {
                if let associatedFormStep = registerError.associatedFormStep {
                    if formStepView.canPresentError(forFormStep: associatedFormStep),
                       let firstErrorIndex = self.viewModel.indexForFormStep(associatedFormStep)
                    {
                        self.viewModel.scrollToIndex(firstErrorIndex)
                        return
                    }
                }
            }
        }

    }

}

public extension SteppedRegistrationViewController {

    private func scrollToItem(newPage: Int, offset: CGFloat, animated: Bool) {

        self.scrollToItem(newPage: newPage, animated: animated)
        self.scrollToOffset(yPosition: offset, animated: animated)

        if let registerStepView = self.registerStepViews[safe: newPage] {
            registerStepView.didBecomeMainCenterStep()
        }

    }

    private func scrollToItem(newPage: Int, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: animated ? 0.14 : 0.0) {
            for (index, registerStepView) in self.registerStepViews.enumerated() {
                if index == newPage {
                    registerStepView.alpha = 1.0
                }
                else {
                    registerStepView.alpha = 0.0
                }
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
    
    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "banner_register", in: Bundle.module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createLegalAgeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "minus_18_icon", in: Bundle.module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    private static func createProgressView() -> TallProgressBarView {
        let progressView = TallProgressBarView()
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle(Localization.localized("close"), for: .normal)
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
        button.setTitle(Localization.localized("continue_"), for: .normal)
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

    private static func createProgressEndLottieView() -> LottieAnimationView {
        let animationView = LottieAnimationView()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let starAnimation = LottieAnimation.named("progress_bar_fire_ball")

        animationView.animation = starAnimation
        animationView.loopMode = .loop

        return animationView
    }

    private static func createProgressImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress_bar_animation", in: Bundle.module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createProgressEndContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }
    
    // Constraints
    private static func createHeaderViewTopToBannerConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createHeaderViewTopToScreenConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.stepsScrollView.isScrollEnabled = false
        self.stepsScrollView.bounces = false
        self.stepsScrollView.bouncesZoom = false
        
        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)
        self.continueButton.addTarget(self, action: #selector(self.didTapContinueButton), for: .primaryActionTriggered)
        self.cancelButton.addTarget(self, action: #selector(self.didTapCancelButton), for: .primaryActionTriggered)

        self.initConstraints()
    }

    private func initConstraints() {
        self.view.addSubview(self.topSafeAreaView)
        
        self.view.addSubview(self.bannerImageView)
        
        self.bannerImageView.addSubview(self.legalAgeImageView)

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.progressView)
        self.headerBaseView.addSubview(self.cancelButton)
        self.headerBaseView.addSubview(self.progressEndContainerView)

        self.progressEndContainerView.addSubview(self.progressEndLottieView)
        self.progressEndContainerView.addSubview(self.progressEndImageView)

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.stepsScrollView)
        self.stepsScrollView.addSubview(self.stepsContentStackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.loadingBaseView.addSubview(self.loadingView)
        self.view.addSubview(self.loadingBaseView)

        self.progressEndContainerViewWidth = self.progressEndContainerView.widthAnchor.constraint(equalToConstant: 0)


        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            
            self.bannerImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bannerImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.bannerImageView.heightAnchor.constraint(equalToConstant: 70),
            
            self.legalAgeImageView.trailingAnchor.constraint(equalTo: self.bannerImageView.trailingAnchor, constant: -5),
            self.legalAgeImageView.centerYAnchor.constraint(equalTo: self.bannerImageView.centerYAnchor),
            self.legalAgeImageView.heightAnchor.constraint(equalToConstant: 60),
            self.legalAgeImageView.widthAnchor.constraint(equalTo: self.bannerImageView.heightAnchor),

//            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: Self.headerHeight),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -18),

            self.progressView.heightAnchor.constraint(equalToConstant: 12),
            self.progressView.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.progressView.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 7),
            self.progressView.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor, constant: -26),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.footerBaseView.topAnchor),

            self.stepsScrollView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
            self.stepsScrollView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),
            self.stepsScrollView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.stepsScrollView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.stepsContentStackView.leadingAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.leadingAnchor),
            self.stepsContentStackView.topAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.topAnchor),
            self.stepsContentStackView.trailingAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.trailingAnchor),
            self.stepsContentStackView.bottomAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.bottomAnchor),

            self.stepsContentStackView.widthAnchor.constraint(equalTo: self.stepsScrollView.frameLayoutGuide.widthAnchor),

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
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),

            self.progressEndContainerView.heightAnchor.constraint(equalToConstant: 1),
            self.progressEndContainerView.leadingAnchor.constraint(equalTo: self.progressView.leadingAnchor, constant: -7),
            self.progressEndContainerView.centerYAnchor.constraint(equalTo: self.progressView.centerYAnchor),

            self.progressEndContainerView.trailingAnchor.constraint(equalTo: self.progressEndLottieView.centerXAnchor),
            self.progressEndContainerView.centerYAnchor.constraint(equalTo: self.progressEndLottieView.centerYAnchor),

            self.progressEndLottieView.widthAnchor.constraint(equalToConstant: 92),
            self.progressEndLottieView.heightAnchor.constraint(equalToConstant: 92),

            self.progressEndContainerViewWidth!,

            self.progressEndImageView.trailingAnchor.constraint(equalTo: self.progressEndLottieView.trailingAnchor, constant: -20),
            self.progressEndImageView.centerYAnchor.constraint(equalTo: self.progressEndLottieView.centerYAnchor),

            self.progressEndImageView.widthAnchor.constraint(equalToConstant: 23),
            self.progressEndImageView.heightAnchor.constraint(equalToConstant: 23),
        ])
        
        // Constraints
        self.headerViewTopToScreenConstraint = NSLayoutConstraint(item: self.headerBaseView,
                                                                  attribute: .top,
                                                                    relatedBy: .equal,
                                                                  toItem: self.view.safeAreaLayoutGuide,
                                                                  attribute: .top,
                                                                    multiplier: 1,
                                                                    constant: 0)
        self.headerViewTopToScreenConstraint.isActive = true
        
        self.headerViewTopToBannerConstraint = NSLayoutConstraint(item: self.headerBaseView,
                                                                  attribute: .top,
                                                                    relatedBy: .equal,
                                                                  toItem: self.bannerImageView,
                                                                  attribute: .bottom,
                                                                    multiplier: 1,
                                                                    constant: 0)
        self.headerViewTopToBannerConstraint.isActive = false
    }
}
