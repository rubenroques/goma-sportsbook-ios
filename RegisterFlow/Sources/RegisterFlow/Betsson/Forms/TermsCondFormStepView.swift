//
//  TermsCondFormStepView.swift
//  
//
//  Created by Ruben Roques on 23/01/2023.
//

import UIKit
import Theming
import Extensions
import Combine

class TermsCondFormStepViewModel {

    let title: String

    var isMarketingOn: CurrentValueSubject<Bool, Never> = .init(false)
    var isTermsOn: CurrentValueSubject<Bool, Never> = .init(false)

    init(title: String, isMarketingOn: Bool = false, isTermsOn: Bool = false) {
        self.title = title
        self.isMarketingOn = .init(isMarketingOn)
        self.isTermsOn = .init(isTermsOn)
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return isTermsOn.eraseToAnyPublisher()
    }

}

class TermsCondFormStepView: FormStepView {

    private lazy var readLabelBaseView: UIView = Self.createReadLabelBaseView()
    private lazy var readLabel: UILabel = Self.createReadLabel()

    private lazy var marketingBaseView: UIView = Self.createMarketingBaseView()
    private lazy var marketingLabel: UILabel = Self.createMarketingLabel()
    private lazy var marketingSwitch: UISwitch = Self.createMarketingSwitch()

    private lazy var termsBaseView: UIView = Self.createTermsBaseView()
    private lazy var termsLabel: UILabel = Self.createTermsLabel()
    private lazy var termsSwitch: UISwitch = Self.createTermsSwitch()

    let viewModel: TermsCondFormStepViewModel

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: TermsCondFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {

        self.readLabelBaseView.addSubview(self.readLabel)

        self.marketingBaseView.addSubview(self.marketingLabel)
        self.marketingBaseView.addSubview(self.marketingSwitch)

        self.termsBaseView.addSubview(self.termsLabel)
        self.termsBaseView.addSubview(self.termsSwitch)

        self.stackView.addArrangedSubview(self.readLabelBaseView)
        self.stackView.addArrangedSubview(self.marketingBaseView)
        self.stackView.addArrangedSubview(self.termsBaseView)

        NSLayoutConstraint.activate([
            self.readLabelBaseView.heightAnchor.constraint(equalToConstant: 32),
            self.readLabel.heightAnchor.constraint(equalToConstant: 16),
            self.readLabel.leadingAnchor.constraint(equalTo: self.readLabelBaseView.leadingAnchor),
            self.readLabel.topAnchor.constraint(equalTo: self.readLabelBaseView.topAnchor, constant: 4),

            self.marketingBaseView.heightAnchor.constraint(equalToConstant: 40),
            self.marketingSwitch.trailingAnchor.constraint(equalTo: self.marketingBaseView.trailingAnchor),
            self.marketingSwitch.centerYAnchor.constraint(equalTo: self.marketingBaseView.centerYAnchor),

            self.marketingLabel.leadingAnchor.constraint(equalTo: self.marketingBaseView.leadingAnchor),
            self.marketingLabel.trailingAnchor.constraint(equalTo: self.marketingSwitch.leadingAnchor, constant: -8),
            self.marketingLabel.centerYAnchor.constraint(equalTo: self.marketingBaseView.centerYAnchor),

            self.termsBaseView.heightAnchor.constraint(equalToConstant: 40),
            self.termsSwitch.trailingAnchor.constraint(equalTo: self.termsBaseView.trailingAnchor),
            self.termsSwitch.centerYAnchor.constraint(equalTo: self.termsBaseView.centerYAnchor),

            self.termsLabel.leadingAnchor.constraint(equalTo: self.termsBaseView.leadingAnchor),
            self.termsLabel.trailingAnchor.constraint(equalTo: self.termsSwitch.leadingAnchor, constant: -8),
            self.termsLabel.centerYAnchor.constraint(equalTo: self.termsBaseView.centerYAnchor),
        ])

        self.titleLabel.text = self.viewModel.title

        self.readLabel.font = AppFont.with(type: .regular, size: 12)
        self.marketingLabel.font = AppFont.with(type: .semibold, size: 14)
        self.termsLabel.font = AppFont.with(type: .semibold, size: 14)

        self.termsSwitch.addTarget(self, action: #selector(self.termsSwitchValueChanged(_:)), for: .valueChanged)
        self.marketingSwitch.addTarget(self, action: #selector(self.marketingSwitchValueChanged(_:)), for: .valueChanged)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.readLabel.textColor = AppColor.textSecondary
        self.marketingLabel.textColor = AppColor.textPrimary
        self.termsLabel.textColor = AppColor.textPrimary
    }

    @objc private func marketingSwitchValueChanged(_ marketingSwitch: UISwitch) {
        self.viewModel.isMarketingOn.send(marketingSwitch.isOn)
    }

    @objc private func termsSwitchValueChanged(_ termsSwitch: UISwitch) {
        self.viewModel.isTermsOn.send(termsSwitch.isOn)
    }

}

extension TermsCondFormStepView {

    //
    private static func createReadLabelBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createReadLabel() -> UILabel {
        let label = UILabel()
        label.text = "Read about our Terms and Conditions"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    //
    private static func createMarketingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createMarketingLabel() -> UILabel {
        let label = UILabel()
        label.text = "I allow my email to be used for marketing purposes"
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    private static func createMarketingSwitch() -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }

    //
    private static func createTermsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createTermsLabel() -> UILabel {
        let label = UILabel()
        label.text = "Accept Terms & Conditions"
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    private static func createTermsSwitch() -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }

}
