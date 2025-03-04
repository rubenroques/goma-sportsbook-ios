//
//  EditContactViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import UIKit
import Combine

class EditContactViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()
    private lazy var userInfoView: UserInfoView = Self.createUserInfoView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var blockButton: UIButton = Self.createBlockButton()
    private lazy var reportButton: UIButton = Self.createReportButton()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: EditContactViewModel

    var isNotificationMuted: Bool = true {
        didSet {
            if isNotificationMuted {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_on_icon"), for: UIControl.State.normal)
            }
            else {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_icon"), for: UIControl.State.normal)
            }
        }
    }

    var shouldCloseChat: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: EditContactViewModel) {
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

        self.bind(toViewModel: self.viewModel)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationButton), for: .primaryActionTriggered)

        self.blockButton.addTarget(self, action: #selector(didTapBlockButton), for: .primaryActionTriggered)

        self.reportButton.addTarget(self, action: #selector(didTapReportButton), for: .primaryActionTriggered)

        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)

        self.isNotificationMuted = false

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.backButton.backgroundColor = .clear

        self.notificationsButton.backgroundColor = .clear

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.blockButton.backgroundColor = .clear
        self.blockButton.tintColor = UIColor.App.highlightSecondary
        self.blockButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.reportButton.backgroundColor = .clear
        self.reportButton.tintColor = UIColor.App.highlightSecondary
        self.reportButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.deleteButton.backgroundColor = .clear
        self.deleteButton.tintColor = UIColor.App.inputError
        self.deleteButton.setTitleColor(UIColor.App.inputError, for: .normal)

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: EditContactViewModel) {

        viewModel.usernamePublisher
            .sink(receiveValue: { [weak self] username in
                self?.userInfoView.setupViewInfo(title: username)
            })
            .store(in: &cancellables)

        viewModel.shouldCloseChat
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldCloseChat in
                if shouldCloseChat {
                    self?.shouldCloseChat?()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
            .store(in: &cancellables)

        viewModel.isOnlinePublisher
            .sink(receiveValue: { [weak self] isOnline in
                self?.userInfoView.isOnline = isOnline
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapNotificationButton() {

        if self.isNotificationMuted == false {
            let alert = UIAlertController(
                title: "Mute notifications",
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "For 15 minutes",
                style: .default,
                handler: { _ in
                    print("15MIN")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: "For 1 hour",
                style: .default,
                handler: { _ in
                    print("1H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 8 hours",
                style: .default,
                handler: { _ in
                    print("8H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 24 hours",
                style: .default,
                handler: { _ in
                    print("24H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "Until I turn it back on",
                style: .default,
                handler: { _ in
                    print("ALWAYS")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: localized("cancel"),
                style: .cancel,
                handler: { _ in
                print("CANCEL")
            }))
            present(alert,
                    animated: true,
                    completion: nil
            )
        }
        else {
            self.isNotificationMuted = false
        }
    }

    @objc func didTapBlockButton() {
        print("BLOCK!")
    }

    @objc func didTapReportButton() {
        print("REPORT!")

    }

    @objc func didTapDeleteButton() {
        print("DELETE!")

        let deleteAlert = UIAlertController(title: localized("delete_contact"),
                                                 message: localized("delete_contact_message"),
                                                 preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in

            self.viewModel.deleteContact()
        }))

        deleteAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.present(deleteAlert, animated: true, completion: nil)
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension EditContactViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createNotificationsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "notifications_status_on_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("edit_contact")
        return label
    }

    private static func createUserInfoView() -> UserInfoView {
        let view = UserInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.isOnline = true
        return view
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBlockButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "block_user_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -3, left: -15, bottom: 0, right: 0)
        button.setTitle(localized("block_contact"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createReportButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "report_user_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -3, left: -15, bottom: 0, right: 0)
        button.setTitle(localized("report"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "delete_user_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -3, left: -15, bottom: 0, right: 0)
        button.setTitle(localized("delete"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.userInfoView)

        self.view.addSubview(self.separatorLineView)

        self.view.addSubview(self.blockButton)

        self.view.addSubview(self.reportButton)

        self.view.addSubview(self.deleteButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),

            self.notificationsButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.notificationsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.notificationsButton.widthAnchor.constraint(equalToConstant: 40),
            self.notificationsButton.heightAnchor.constraint(equalTo: self.notificationsButton.widthAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -10)
        ])

        // User info view
        NSLayoutConstraint.activate([
            self.userInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.userInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.userInfoView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 15),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.separatorLineView.topAnchor.constraint(equalTo: self.userInfoView.bottomAnchor, constant: 15),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([

            self.blockButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.blockButton.heightAnchor.constraint(equalToConstant: 30),
            self.blockButton.bottomAnchor.constraint(equalTo: self.reportButton.topAnchor, constant: -10),

            self.reportButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.reportButton.heightAnchor.constraint(equalToConstant: 30),
            self.reportButton.bottomAnchor.constraint(equalTo: self.deleteButton.topAnchor, constant: -10),

            self.deleteButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 30),
            self.deleteButton.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor, constant: -10)
        ])

    }
}
