//
//  FormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import Foundation
import UIKit
import Combine
import Theming

protocol FormStepCompleter {
    var isFormCompleted: AnyPublisher<Bool, Never> { get }
}

protocol RegisterErrorPresenter {
    func canPresentError(forFormStep: FormStep) -> Bool
    func presentError(_ error: RegisterError, forFormStep: FormStep)
}

public class FormStepView: UIView, FormStepCompleter, RegisterErrorPresenter {

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }

    var requestNextFormSubject: PassthroughSubject<Void, Never> = .init()

    var canMoveToNextForm: Bool { return true }
    var canMoveToPreviousForm: Bool { return true }

    var shouldSkipForm: Bool { return false }

    lazy var contentView: UIView = Self.createContentView()
    lazy var stackView: UIStackView = Self.createStackView()

    lazy var headerView: UIView = Self.createHeaderView()
    lazy var titleLabel: UILabel = Self.createTitleLabel()

    public init() {
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
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func canPresentError(forFormStep: FormStep) -> Bool {
        return false
    }

    func presentError(_ error: RegisterError, forFormStep: FormStep) {
        
    }

    func setupWithTheme() {
        self.backgroundColor = AppColor.backgroundPrimary

        self.contentView.backgroundColor = AppColor.backgroundPrimary
        self.stackView.backgroundColor = AppColor.backgroundPrimary

        self.titleLabel.textColor = AppColor.textPrimary
    }

    func didBecomeMainCenterStep() {

    }

}

extension FormStepView {

    private static var headerHeight: CGFloat {
        return 80
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = AppFont.with(type: .bold, size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }

    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        return stackView
    }

    func setupSubviews() {

        self.initConstraints()
    }

    func initConstraints() {
        self.addSubview(self.contentView)

        self.contentView.addSubview(self.headerView)
        self.headerView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Self.headerHeight),
            self.headerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 34),
            self.titleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 8),

            self.stackView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -24),
        ])

    }

}

