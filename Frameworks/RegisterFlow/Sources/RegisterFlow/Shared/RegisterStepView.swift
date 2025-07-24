//
//  RegisterStepView.swift
//  
//
//  Created by Ruben Roques on 11/01/2023.
//

import Foundation
import ServicesProvider
import UIKit
import Combine
import Extensions
import Theming

public struct RegisterStepViewModel {

    let index: Int

    public init(index: Int) {
        self.index = index
    }

}

public class RegisterStepView: UIView {

    var isRegisterStepCompleted: AnyPublisher<Bool, Never> {
        let publishers = self.formStepViews.map(\.isFormCompleted)

        return publishers.combineLatest()
            .map { forms in
                return forms.reduce(true, { $0 && $1 })
            }
            .eraseToAnyPublisher()
    }

    var requestNextFormSubject: AnyPublisher<Void, Never> {
        return Publishers.MergeMany(self.formStepViews.map(\.requestNextFormSubject))
            .eraseToAnyPublisher()
    }

    var canMoveToNextStep: Bool {
        return self.formStepViews.reduce(true) { partialResult, formStepView in
            return partialResult && formStepView.canMoveToNextForm
        }
    }

    var canMoveToPreviousStep: Bool {
        return self.formStepViews.reduce(true) { partialResult, formStepView in
            return partialResult && formStepView.canMoveToPreviousForm
        }
    }

    var shouldSkipStep: Bool {
        return self.formStepViews.reduce(true) { partialResult, formStepView in
            return partialResult && formStepView.shouldSkipForm
        }
    }

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollInnerView: UIView = Self.createScrollInnerView()

    private lazy var stackView: UIStackView = Self.createStackView()

    private let viewModel: RegisterStepViewModel
    private var formStepViews: [FormStepView] = []

    private var cancellables = Set<AnyCancellable>()


    public init(viewModel: RegisterStepViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        
        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required public override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        self.setupSubviews()

        let topPlaceholderView = UIView()
        topPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        topPlaceholderView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            topPlaceholderView.heightAnchor.constraint(equalToConstant: 1)
        ])

        self.stackView.addArrangedSubview(topPlaceholderView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setupWithTheme() {
        self.backgroundColor = AppColor.backgroundPrimary

        self.scrollView.backgroundColor = AppColor.backgroundPrimary
        self.scrollInnerView.backgroundColor = AppColor.backgroundPrimary

        self.formStepViews.forEach { formStepView in
            formStepView.setupWithTheme()
        }
    }

    func addFormView(formView: FormStepView) {
        self.formStepViews.append(formView)
        self.stackView.addArrangedSubview(formView)
    }

    func didBecomeMainCenterStep() {
        for form in self.formStepViews {
            form.didBecomeMainCenterStep()
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension RegisterStepView {

    private static func createScrollInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func setupSubviews() {
        self.initConstraints()
    }

    private func initConstraints() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.scrollInnerView)

        self.scrollInnerView.addSubview(self.stackView)

        let topConstraint = self.scrollInnerView.topAnchor.constraint(greaterThanOrEqualTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 0)
        topConstraint.priority = UILayoutPriority.init(rawValue: 1000)

        let stepsViewCenterY = self.scrollView.centerYAnchor.constraint(equalTo: self.scrollInnerView.centerYAnchor, constant: 40)
        stepsViewCenterY.priority = UILayoutPriority.init(rawValue: 999)

        NSLayoutConstraint.activate([
            self.scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: self.topAnchor),
            self.scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            self.scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.scrollInnerView.bottomAnchor),
            self.scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: self.scrollInnerView.leadingAnchor),
            self.scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: self.scrollInnerView.trailingAnchor),

            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.scrollInnerView.widthAnchor),

            self.stackView.leadingAnchor.constraint(equalTo: self.scrollInnerView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollInnerView.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollInnerView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollInnerView.bottomAnchor),

            stepsViewCenterY,
            topConstraint
        ])
    }
}
