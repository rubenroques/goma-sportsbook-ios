//
//  BettingPracticesQuestionnaireViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 29/01/2025.
//

import UIKit
import Combine

class BettingPracticesQuestionnaireViewController: UIViewController {

    // MARK: Private Properties
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var progressView: TallProgressBarView = Self.createProgressView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var stepsScrollView: UIScrollView = Self.createStepsScrollView()
    private lazy var stepsContentStackView: UIStackView = Self.createStepsContentStackView()
    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()
    
    private let viewModel: BettingPracticesQuestionnaireViewModel

    private var questionFormStepViews: [QuestionFormStepView] = []
    private var questionnaireCompletionPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and Cycle
    init(viewModel: BettingPracticesQuestionnaireViewModel) {
        
        self.viewModel = BettingPracticesQuestionnaireViewModel()
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubviews()
        self.setupWithTheme()
        
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        
        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
        
        self.viewModel.progressPercentage
            .withPrevious()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] previousPercentage, progressPercentage in
                self?.animateProgress(toPercentage: progressPercentage, previousPercentage: previousPercentage ?? 0.0)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.shouldShowSuccessScreen = { [weak self] in
            self?.showSuccessScreen()
        }
        
        self.createSteps()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    // MARK: Theme and layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    
    private func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary
        
        self.navigationTitleLabel.textColor = UIColor.App.textPrimary
        
        self.cancelButton.backgroundColor = .clear
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        
        self.contentBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.stepsScrollView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.continueButton)
    }
    
    // MARK: Functions
    private func createSteps() {
        
        self.questionFormStepViews = []
        
        let questionnaireFormFactory = QuestionnaireFormFactory()
        
        for (index, questionnaireStep) in self.viewModel.questionnaireSteps.enumerated() {
            
            let formStep = questionnaireStep.form
            
            let questionFormStepView = QuestionFormStepView(formStep: formStep)
            
            questionFormStepView.didAnswerQuestion = { [weak self] questionNumber, question, answer in
                self?.viewModel.storeQuestionAnswered(number: questionNumber, question: question, answer: answer)
            }
                        
            self.addStepView(questionFormStepView: questionFormStepView)
        }

        self.configureQuestionnaireCompletionPublisher()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    private func addStepView(questionFormStepView: QuestionFormStepView) {

        questionFormStepView.alpha = 0.0

        self.stepsContentStackView.addArrangedSubview(questionFormStepView)

        NSLayoutConstraint.activate([
            questionFormStepView.heightAnchor.constraint(equalTo: self.contentBaseView.heightAnchor)
        ])

        self.questionFormStepViews.append(questionFormStepView)

    }
    
    private func animateProgress(toPercentage percentage: Float, previousPercentage: Float) {
        
        UIView.animate(withDuration: 0.45) {
            self.progressView.setProgress(percentage, animated: true)
        }

    }
    
    func configureQuestionnaireCompletionPublisher() {

        self.questionnaireCompletionPublisher?.cancel()

        let questionnairePerStepPublisher = self.questionFormStepViews.map(\.isFormComplete).combineLatest()
        self.questionnaireCompletionPublisher = Publishers.CombineLatest(self.viewModel.currentStep, questionnairePerStepPublisher)
            .map { (currentPage, completionPerStepArray) -> Bool in
                let isStepCompleted = completionPerStepArray[safe: currentPage] ?? false
                return isStepCompleted
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isCurrentStepCompleted in
                self?.continueButton.isEnabled = isCurrentStepCompleted
            })
    }
    
    private func scrollToPreviousStep() {
        let currentPage = self.viewModel.currentStep.value
        
        guard
            let questionFormStepView = self.questionFormStepViews[safe: currentPage]
        else {
            return
        }

        if let previousQuestionFormStepView = self.questionFormStepViews[safe: currentPage-1] {
            self.viewModel.scrollToPreviousStep()
        }
        else {
            self.showCancelAlert()
        }

    }
    
    private func scrollToNextStep() {

        let currentPage = self.viewModel.currentStep.value
        
        guard
            let questionFormStepView = self.questionFormStepViews[safe: currentPage]
        else {
            return
        }

        let nextQuestionFormStepView = self.questionFormStepViews[safe: currentPage+1]

        if !questionFormStepView.isFormComplete.value {
            return
        }

        if self.viewModel.isLastStep(index: self.viewModel.currentStep.value) {
            self.viewModel.createQuestionnaireResult()
        }
        else {
            self.viewModel.scrollToNextStep()
        }

    }
    
    // Alerts
    private func showCancelAlert(isDismiss: Bool = false) {
        
        let alert = UIAlertController(title: localized("progress_not_saved"),
                                      message: localized("leave_questionnaire"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { [weak self] _ in
            
            if isDismiss {
                self?.dismiss(animated: true)
            }
            else {
                self?.navigationController?.popViewController(animated: true)
            }
            
        }))

        alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorAlert() {
        
        let alert = UIAlertController(title: localized("error"),
                                      message: localized("gen_error_something_wrong_text"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessScreen() {
        let genericSuccessViewController = GenericAvatarSuccessViewController()
        
        genericSuccessViewController.setTextInfo(title: localized("success"), subtitle: localized("questionnaire_success"), buttonText: localized("back_home"))
        
        genericSuccessViewController.didTapCloseAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        genericSuccessViewController.didTapContinueAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        self.navigationController?.pushViewController(genericSuccessViewController, animated: true)
        
    }
    
    // MARK: Actions
    @objc private func didTapContinueButton() {
        self.scrollToNextStep()

    }
    
    @objc private func didTapBackButton() {
        self.scrollToPreviousStep()

    }
    
    @objc private func didTapCancelButton() {
        self.showCancelAlert(isDismiss: true)
    }
}

extension BettingPracticesQuestionnaireViewController {
    
    private func scrollToItem(newPage: Int, offset: CGFloat, animated: Bool) {

        self.scrollToItem(newPage: newPage, animated: animated)
        self.scrollToOffset(yPosition: offset, animated: animated)

    }

    private func scrollToItem(newPage: Int, animated: Bool) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: animated ? 0.14 : 0.0) {
            for (index, questionFormStepView) in self.questionFormStepViews.enumerated() {
                if index == newPage {
                    questionFormStepView.alpha = 1.0
                }
                else {
                    questionFormStepView.alpha = 0.0
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

extension BettingPracticesQuestionnaireViewController {
    
    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("betting_questionnaire")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
    private static func createProgressView() -> TallProgressBarView {
        let progressView = TallProgressBarView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        return progressView
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
        button.setTitle(localized("continue_"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }
    
    private func setupSubviews() {
        
        self.view.addSubview(self.navigationView)
        
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.navigationTitleLabel)
        self.navigationView.addSubview(self.cancelButton)
        
        self.view.addSubview(self.progressView)
        
        self.view.addSubview(self.contentBaseView)
        
        self.contentBaseView.addSubview(self.stepsScrollView)
        
        self.stepsScrollView.addSubview(self.stepsContentStackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        
        // Navigation bar
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor, constant: -8),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            
            self.cancelButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.progressView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20),
            self.progressView.heightAnchor.constraint(equalToConstant: 12),
        ])
        
        // Content views
        NSLayoutConstraint.activate([
            self.contentBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.progressView.bottomAnchor, constant: 20),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.footerBaseView.topAnchor),

            self.stepsScrollView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
            self.stepsScrollView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),
            self.stepsScrollView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.stepsScrollView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            
            self.stepsContentStackView.leadingAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.leadingAnchor),
            self.stepsContentStackView.trailingAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.trailingAnchor),
            self.stepsContentStackView.topAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.topAnchor),
            self.stepsContentStackView.bottomAnchor.constraint(equalTo: self.stepsScrollView.contentLayoutGuide.bottomAnchor),
            self.stepsContentStackView.widthAnchor.constraint(equalTo: self.stepsScrollView.frameLayoutGuide.widthAnchor),
            
            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 75),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 30),
            self.continueButton.trailingAnchor.constraint(equalTo: self.footerBaseView.trailingAnchor, constant: -30),
            self.continueButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
