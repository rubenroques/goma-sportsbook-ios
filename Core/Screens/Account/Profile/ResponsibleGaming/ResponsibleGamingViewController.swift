//
//  ResponsibleGamingViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/03/2023.
//

import UIKit

class ResponsibleGamingViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var stackView: UIStackView = Self.createStackView()

    // MARK: Lifetime and Cycle
    init() {
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.setupStackView()
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.stackView.backgroundColor = .clear
    }

    // MARK: Functions
    private func setupStackView() {
        let casualGamblingView = NavigationCardView()
        casualGamblingView.setupView(title: localized("casual_vs_pathologic_gambling"), iconTitle: "casual_gambling_icon")
        let casualGamblingTap = UITapGestureRecognizer(target: self, action: #selector(didTapCasualGambling(sender:)))
        casualGamblingView.addGestureRecognizer(casualGamblingTap)

        let tipsControlView = NavigationCardView()
        tipsControlView.setupView(title: localized("tips_keep_control"), iconTitle: "responsible_gaming_icon")
        let tipsControlTap = UITapGestureRecognizer(target: self, action: #selector(didTapTipsControl(sender:)))
        tipsControlView.addGestureRecognizer(tipsControlTap)

        let limitsView = NavigationCardView()
        limitsView.setupView(title: localized("limits_management"), iconTitle: "limits_profile_icon")
        let limitsTap = UITapGestureRecognizer(target: self, action: #selector(didTapLimits(sender:)))
        limitsView.addGestureRecognizer(limitsTap)

        let selfExclusionView = NavigationCardView()
        selfExclusionView.setupView(title: localized("self_exclusion"), iconTitle: "self_exclusion_icon")
        let selfExclusionTap = UITapGestureRecognizer(target: self, action: #selector(didTapSelfExclusion(sender:)))
        selfExclusionView.addGestureRecognizer(selfExclusionTap)

        let closeAccountView = NavigationCardView()
        closeAccountView.setupView(title: localized("close_account"), iconTitle: "close_account_icon")
        let closeAccountTap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseAccount(sender:)))
        closeAccountView.addGestureRecognizer(closeAccountTap)

        self.stackView.addArrangedSubview(casualGamblingView)
        self.stackView.addArrangedSubview(tipsControlView)
        self.stackView.addArrangedSubview(limitsView)
        self.stackView.addArrangedSubview(selfExclusionView)
        self.stackView.addArrangedSubview(closeAccountView)

    }
}

//
// MARK: - Actions
//
extension ResponsibleGamingViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCasualGambling(sender: UITapGestureRecognizer) {
        let casualGamblingViewController = CasualGamblingViewController()

        self.navigationController?.pushViewController(casualGamblingViewController, animated: true)
    }

    @objc private func didTapTipsControl(sender: UITapGestureRecognizer) {

        let tipsControlViewController = TipsControlViewController()

        self.navigationController?.pushViewController(tipsControlViewController, animated: true)

    }

    @objc private func didTapLimits(sender: UITapGestureRecognizer) {
        let profileLimitsManagementViewController = ProfileLimitsManagementViewController()

        self.navigationController?.pushViewController(profileLimitsManagementViewController, animated: true)
    }

    @objc private func didTapSelfExclusion(sender: UITapGestureRecognizer) {

        let selfExclusionViewModel = SelfExclusionViewModel()

        let selfExclusionViewController = SelfExclusionViewController(viewModel: selfExclusionViewModel)

        self.navigationController?.pushViewController(selfExclusionViewController, animated: true)

    }

    @objc private func didTapCloseAccount(sender: UITapGestureRecognizer) {

        let closeAccountViewModel = CloseAccountViewModel()

        let closeAccoutViewController = CloseAccountViewController(viewModel: closeAccountViewModel)

        self.navigationController?.pushViewController(closeAccoutViewController, animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension ResponsibleGamingViewController {

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
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("responsible_gaming")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.stackView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Stackview
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.stackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 20)
        ])

    }

}
