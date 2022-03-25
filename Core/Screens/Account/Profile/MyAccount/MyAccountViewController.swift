//
//  MyAccountViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/03/2022.
//

import UIKit

class MyAccountViewController: UIViewController {

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
        let personalInfoView = NavigationCardView()
        personalInfoView.setupView(title: localized("personal_info"), iconTitle: "card_id_profile_icon")
        let personalInfoTap = UITapGestureRecognizer(target: self, action: #selector(didTapPersonalInfo(sender:)))
        personalInfoView.addGestureRecognizer(personalInfoTap)

        let accountSecurityView = NavigationCardView()
        accountSecurityView.setupView(title: localized("account_security"), iconTitle: "password_profile_icon")
        let accountSecurityTap = UITapGestureRecognizer(target: self, action: #selector(didTapAccountSecurity(sender:)))
        accountSecurityView.addGestureRecognizer(accountSecurityTap)

        let documentsView = NavigationCardView()
        documentsView.setupView(title: localized("documents"), iconTitle: "documents_profile_icon")
        let documentsTap = UITapGestureRecognizer(target: self, action: #selector(didTapDocuments(sender:)))
        documentsView.addGestureRecognizer(documentsTap)

        let limitsView = NavigationCardView()
        limitsView.setupView(title: localized("limits_management"), iconTitle: "limits_profile_icon")
        let limitsTap = UITapGestureRecognizer(target: self, action: #selector(didTapLimits(sender:)))
        limitsView.addGestureRecognizer(limitsTap)

        self.stackView.addArrangedSubview(personalInfoView)
        self.stackView.addArrangedSubview(accountSecurityView)
        self.stackView.addArrangedSubview(documentsView)
        self.stackView.addArrangedSubview(limitsView)

    }

}

//
// MARK: - Actions
//
extension MyAccountViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapPersonalInfo(sender: UITapGestureRecognizer) {
        let userSession = UserSessionStore.loggedUserSession()

        let personalInfoViewController = PersonalInfoViewController(userSession: userSession)
        self.navigationController?.pushViewController(personalInfoViewController, animated: true)
    }

    @objc private func didTapAccountSecurity(sender: UITapGestureRecognizer) {

        let passwordViewController = PasswordUpdateViewController()
        self.navigationController?.pushViewController(passwordViewController, animated: true)
    }

    @objc private func didTapDocuments(sender: UITapGestureRecognizer) {

    }

    @objc private func didTapLimits(sender: UITapGestureRecognizer) {
        let profileLimitsManagementViewController = ProfileLimitsManagementViewController()
        self.navigationController?.pushViewController(profileLimitsManagementViewController, animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension MyAccountViewController {

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
        label.text = localized("my_account")
        label.font = AppFont.with(type: .bold, size: 17)
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

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
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
