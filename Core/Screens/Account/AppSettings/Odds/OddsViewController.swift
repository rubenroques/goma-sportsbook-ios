//
//  OddsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit
import Combine

class OddsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()

    // MARK: Public Properties
    var cancellables = Set<AnyCancellable>()
    var viewModel: OddsViewModel

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = OddsViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.setupTopStackView()
        self.setupBottomStackView()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.viewModel.storeBettingUserSettings()
    }
    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.topStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.bottomStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    private func setupTopStackView() {
        let themeColorView = SettingsRowView()
        themeColorView.setTitle(title: localized("odds_format"))

        let euOddView = SettingsRadioRowView()
        euOddView.setTitle(title: localized("odds_format_eu"))
        euOddView.viewId = 1
        euOddView.hasSeparatorLineView = true
        self.viewModel.oddsFormatRadioButtonViews.append(euOddView)

        let ukOddView = SettingsRadioRowView()
        ukOddView.setTitle(title: localized("odds_format_uk"))
        ukOddView.viewId = 2
        ukOddView.hasSeparatorLineView = true
        self.viewModel.oddsFormatRadioButtonViews.append(ukOddView)

        let usOddView = SettingsRadioRowView()
        usOddView.setTitle(title: localized("odds_format_us"))
        usOddView.viewId = 3
        self.viewModel.oddsFormatRadioButtonViews.append(usOddView)

        self.viewModel.setOddsFormatSelectedValues()

        self.topStackView.addArrangedSubview(themeColorView)
        self.topStackView.addArrangedSubview(euOddView)
        self.topStackView.addArrangedSubview(ukOddView)
        self.topStackView.addArrangedSubview(usOddView)

    }

    private func setupBottomStackView() {
        let oddsVariationView = SettingsRowView()
        oddsVariationView.setTitle(title: localized("odds_variation"))

        let acceptHigherView = SettingsRadioRowView()
        acceptHigherView.setTitle(title: localized("accept_higher"))
        acceptHigherView.viewId = 1
        acceptHigherView.hasSeparatorLineView = true
        self.viewModel.oddsVariationRadioButtonViews.append(acceptHigherView)

        let acceptAnyView = SettingsRadioRowView()
        acceptAnyView.setTitle(title: localized("accept_any"))
        acceptAnyView.viewId = 2
        self.viewModel.oddsVariationRadioButtonViews.append(acceptAnyView)

        self.viewModel.setOddsVariationSelectedValues()

        self.bottomStackView.addArrangedSubview(oddsVariationView)
        self.bottomStackView.addArrangedSubview(acceptHigherView)
        self.bottomStackView.addArrangedSubview(acceptAnyView)

    }

}

//
// MARK: - Actions
//
extension OddsViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension OddsViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("odds")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private static func createBottomStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.topStackView)

        self.view.addSubview(self.bottomStackView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Top StackView
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),

        ])

        // Bottom StackView
        NSLayoutConstraint.activate([
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.bottomStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 16)

        ])

    }

}
