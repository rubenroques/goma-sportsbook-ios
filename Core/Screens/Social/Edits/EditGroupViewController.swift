//
//  EditGroupViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import UIKit
import Combine

class EditGroupViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: EditGroupViewModel

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
    init(viewModel: EditGroupViewModel) {
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

        self.isNotificationMuted = false

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

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

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: EditGroupViewModel) {

        viewModel.usernamePublisher
            .sink(receiveValue: { [weak self] username in
                self?.titleLabel.text = username
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
                title: "Cancel",
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
}

//
// MARK: - Subviews Initialization and Setup
//
extension EditGroupViewController {
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

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.titleLabel)

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

    }
}

