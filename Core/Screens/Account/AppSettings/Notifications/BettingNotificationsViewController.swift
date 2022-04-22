//
//  BettingNotificationsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit
import Combine

class BettingNotificationsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: BettingNotificationViewModel

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = BettingNotificationViewModel()
        super.init(nibName: nil, bundle: nil)

        self.bind(toViewModel: self.viewModel)
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
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

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: BettingNotificationViewModel) {

    }

    private func setupTopStackView() {
        let betsFinalView = SettingsRowView()
        betsFinalView.setTitle(title: localized("notify_bets_final_result"))
        betsFinalView.hasSeparatorLineView = true
        betsFinalView.hasSwitchButton = true
        self.viewModel.setBetsSelectedOption(view: betsFinalView, settingType: .betFinal)
        betsFinalView.didTappedSwitch = { [weak self] in
            self?.viewModel.updateBetsSetting(isSettingEnabled: betsFinalView.isSwitchOn, settingType: .betFinal)
        }

        let betsOptionsView = SettingsRowView()
        betsOptionsView.setTitle(title: localized("notify_bets_options_results"))
        betsOptionsView.hasSwitchButton = true
        self.viewModel.setBetsSelectedOption(view: betsOptionsView, settingType: .betSelection)
        betsOptionsView.didTappedSwitch = { [weak self] in
            self?.viewModel.updateBetsSetting(isSettingEnabled: betsOptionsView.isSwitchOn, settingType: .betSelection)
        }

        self.topStackView.addArrangedSubview(betsFinalView)
        self.topStackView.addArrangedSubview(betsOptionsView)

    }

}

//
// MARK: - Actions
//
extension BettingNotificationsViewController {
    @objc private func didTapBackButton() {
        self.viewModel.setUserSettings()
        self.navigationController?.popViewController(animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension BettingNotificationsViewController {

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
        label.text = localized("betting_notifications")
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

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.topStackView)

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

    }

}
