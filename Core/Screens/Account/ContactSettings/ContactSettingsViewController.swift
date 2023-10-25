//
//  ContactSettingsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2023.
//

import UIKit
import Combine

class ContactSettingsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var contactsStackView: UIStackView = Self.createContactsStackView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    private var smsSettingView: SettingsRowView?
    private var emailSettingView: SettingsRowView?

    // MARK: Public Properties
    var viewModel: ContactSettingsViewModel

    // MARK: Lifetime and Cycle
    init(viewModel: ContactSettingsViewModel) {
        self.viewModel = viewModel
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

        self.setupContactsStackView()

        self.bind(toViewModel: self.viewModel)

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

        self.contactsStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray
    }

    private func setupContactsStackView() {
        let allowSportsbookView = SettingsRowView()
        allowSportsbookView.setTitle(title: localized("allow_sportsbook_to_contact"))

        let smsView = SettingsRowView()
        smsView.setTitle(title: localized("sms"))
        smsView.hasSeparatorLineView = true
        smsView.hasSwitchButton = true

        smsView.didTappedSwitch = { [weak self] isSwitchOn in
            self?.viewModel.updateSmsSetting(enabled: isSwitchOn)
        }

        self.smsSettingView = smsView

        let emailView = SettingsRowView()
        emailView.setTitle(title: localized("email"))
        emailView.hasSwitchButton = true

        emailView.didTappedSwitch = { [weak self] isSwitchOn in
            self?.viewModel.updateEmailSetting(enabled: isSwitchOn)
        }

        self.emailSettingView = emailView

        // Check options
//        if let notificationsUserSettings = self.viewModel.notificationsUserSettings {
//            if notificationsUserSettings.notificationsSms {
//                smsView.isSwitchOn = true
//            }
//            else {
//                smsView.isSwitchOn = false
//            }
//
//            if notificationsUserSettings.notificationsEmail {
//                emailView.isSwitchOn = true
//            }
//            else {
//                emailView.isSwitchOn = false
//            }
//        }

        self.contactsStackView.addArrangedSubview(allowSportsbookView)
        self.contactsStackView.addArrangedSubview(smsView)
        self.contactsStackView.addArrangedSubview(emailView)

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ContactSettingsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.loadingBaseView.isHidden = !isLoading

                if !isLoading {
                    if let notificationsUserSettings = self?.viewModel.notificationsUserSettings {
                        if notificationsUserSettings.notificationsSms {
                            self?.smsSettingView?.isSwitchOn = true
                        }
                        else {
                            self?.smsSettingView?.isSwitchOn = false
                        }

                        if notificationsUserSettings.notificationsEmail {
                            self?.emailSettingView?.isSwitchOn = true
                        }
                        else {
                            self?.emailSettingView?.isSwitchOn = false
                        }
                    }
                }
                })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.viewModel.updateTerms()
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension ContactSettingsViewController {

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
        label.text = localized("contact_settings")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createContactsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.contactsStackView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

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

        // Contacts StackView
        NSLayoutConstraint.activate([
            self.contactsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.contactsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.contactsStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8)
        ])

        // Loading view
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

    }

}
