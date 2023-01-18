//
//  SteppedRegistrationViewController.swift
//  
//
//  Created by Ruben Roques on 11/01/2023.
//

import Foundation
import Combine
import UIKit

public class SteppedRegistrationViewModel {

    var currentStep: CurrentValueSubject<Int, Never> = .init(0)
    var numberOfSteps: Int = 0

    public init(currentStep: Int, numberOfSteps: Int) {
        self.currentStep = .init(0)
        self.numberOfSteps = numberOfSteps
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
        if nextStep > numberOfSteps {
            nextStep = numberOfSteps
        }
        self.currentStep.send(nextStep)
    }

}

public class SteppedRegistrationViewController: UIViewController {

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var progressView: UIProgressView = Self.createProgressView()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var stepsScrollView: UIScrollView = Self.createStepsScrollView()
    private lazy var stepsContentStackView: UIStackView = Self.createStepsContentStackView()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    private let viewModel: SteppedRegistrationViewModel

    private var currentStep: Int = 0
    private var stepsViews: [RegisterStepView] = []

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

        let publisher = self.viewModel.currentStep
            .removeDuplicates()
            .map { [weak self] (currentPage: Int) -> (currentPage: Int, yOffset: CGFloat) in
                return (currentPage, (self?.contentBaseView.frame.height ?? 0.0) * CGFloat(currentPage))
            }
            .receive(on: DispatchQueue.main)

        publisher.first()
            .sink { [weak self] pageTupple in
                self?.scrollToItem(newPage: pageTupple.currentPage, offset: pageTupple.yOffset, animated: false)
            }
            .store(in: &cancellables)

        publisher.dropFirst()
            .sink { [weak self] pageTupple in
                self?.scrollToItem(newPage: pageTupple.currentPage, offset: pageTupple.yOffset, animated: true)
            }
            .store(in: &cancellables)

        self.createSteps()
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

        self.backButton.tintColor = .white
        self.cancelButton.setTitleColor(.white, for: .normal)
        self.continueButton.setTitleColor(.white, for: .normal)
        self.continueButton.backgroundColor = .red

        self.headerBaseView.backgroundColor = .black
        self.progressView.backgroundColor = .black
        self.contentBaseView.backgroundColor = .black
        self.stepsScrollView.backgroundColor = .black
        self.stepsContentStackView.backgroundColor = .black
        self.footerBaseView.backgroundColor = .black
    }

    private func createSteps() {

        let nameRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel())

        let genderFormStepView = GenderFormStepView(viewModel: GenderFormStepViewModel(title: "Gender",
                                                                                       selectedGender: nil))

        let namesFormStepView = NamesFormStepView(viewModel: NamesFormStepViewModel(title: "Names",
                                                            firstNamePlaceholder: "First Name",
                                                            lastNamePlaceholder: "Last Name"))

        nameRegisterStepView.addFormView(formView: genderFormStepView)
        nameRegisterStepView.addFormView(formView: namesFormStepView)

        self.addStepView(registerStepView: nameRegisterStepView)
        //

        //
        let avatarNickRegisterStepView = RegisterStepView(viewModel: RegisterStepViewModel())

        let avatarFormStepView = AvatarFormStepView(viewModel: AvatarFormStepViewModel(title: "Avatar",
                                                              avatarIconNames: []))

        let nicknameFormStepView = NicknameFormStepView(viewModel: NicknameFormStepViewModel(title: "Nickname",
                                                                  nickname: nil,
                                                                  nicknamePlaceholder: "Nickname"))

        avatarNickRegisterStepView.addFormView(formView: avatarFormStepView)
        avatarNickRegisterStepView.addFormView(formView: nicknameFormStepView)

        self.addStepView(registerStepView: avatarNickRegisterStepView)
        //

        //

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
    }

    @objc private func didTapContinueButton() {
        self.viewModel.scrollToNextStep()
    }

    @objc private func didTapBackButton() {
        self.viewModel.scrollToPreviousStep()
    }

    private func scrollToItem(newPage: Int, offset: CGFloat, animated: Bool) {
        self.scrollToItem(newPage: newPage, animated: animated)
        self.scrollToOffset(yPosition: offset, animated: animated)
    }

    private func scrollToItem(newPage: Int, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: animated ? 0.14 : 0.0) {
            let oldStep = self.stepsViews[safe: self.currentStep]
            let newStep = self.stepsViews[safe: newPage]
            oldStep?.alpha = 0.0
            newStep?.alpha = 1.0
            self.currentStep = newPage
        }
        CATransaction.commit()
    }

    private func scrollToOffset(yPosition: CGFloat, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: animated ? 0.85 : 0.0) {
            self.stepsScrollView.contentOffset = CGPoint(x: 0.0, y: yPosition)
        }
        CATransaction.commit()
    }

}

public extension SteppedRegistrationViewController {

    private static var headerHeight: CGFloat {
        80
    }

    private static var footerHeight: CGFloat {
        80
    }

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }

    private static func createProgressView() -> UIProgressView {
        let progressView = UIProgressView()
        progressView.trackTintColor = .gray
        progressView.progressTintColor = .blue
        progressView.progress = 0.4
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }


    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.stepsScrollView.isScrollEnabled = false

        self.headerBaseView.backgroundColor = .white

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)

        self.backButton.backgroundColor = .lightGray

        self.contentBaseView.backgroundColor = .white
        self.stepsScrollView.backgroundColor = .white
        self.stepsContentStackView.backgroundColor = .white
        self.footerBaseView.backgroundColor = .white

        self.continueButton.addTarget(self, action: #selector(self.didTapContinueButton), for: .primaryActionTriggered)

        self.initConstraints()
    }

    private func initConstraints() {

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.progressView)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.stepsScrollView)
        self.stepsScrollView.addSubview(self.stepsContentStackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

        NSLayoutConstraint.activate([
            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: Self.headerHeight),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 8),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -8),

            self.progressView.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.progressView.centerXAnchor.constraint(equalTo: self.headerBaseView.centerXAnchor),
            self.progressView.leadingAnchor.constraint(greaterThanOrEqualTo: self.backButton.trailingAnchor, constant: 20),
            self.progressView.trailingAnchor.constraint(greaterThanOrEqualTo: self.cancelButton.leadingAnchor, constant: -20),

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
            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 24),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),
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
