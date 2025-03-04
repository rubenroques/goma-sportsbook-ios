//
//  CloseAccountViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/03/2023.
//

import UIKit
import Combine

class CloseAccountViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var shouldShowAlert: CurrentValueSubject<AlertType, Never> = .init(.success)

    // MARK: Cycles
    init() {

    }

     // MARK: Functions
    // MARK: Functions
    func lockPlayer() {

        Env.servicesProvider.lockPlayer(isPermanent: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("LOCK PLAYER ERROR: \(error)")
                    self?.shouldShowAlert.send(.error)
                }

            }, receiveValue: { [weak self] _ in

                self?.shouldShowAlert.send(.success)

            })
            .store(in: &cancellables)

    }
}

class CloseAccountViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var closeAccountButton: UIButton = Self.createCloseAccountButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: CloseAccountViewModel

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
            }
        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: CloseAccountViewModel) {

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.closeAccountButton.addTarget(self, action: #selector(didTapCloseAccountButton), for: .touchUpInside)

        self.bind(toViewModel: self.viewModel)

        self.isLoading = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.messageLabel.textColor = UIColor.App.textPrimary

        self.closeAccountButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.closeAccountButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.closeAccountButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.closeAccountButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: CloseAccountViewModel) {

        viewModel.shouldShowAlert
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] alertType in

                switch alertType {
                case .success:
                    self?.showAlert(alertType: .success)
                case .error:
                    self?.showAlert(alertType: .error)
                }
            })
            .store(in: &cancellables)
    }

    private func showConfirmationAlert() {

        let alert = UIAlertController(title: localized("close_account"),
                                      message: localized("close_account_alert_text"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            self?.viewModel.lockPlayer()
        }))

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func showAlert(alertType: AlertType) {

        switch alertType {
        case .success:
            let alert = UIAlertController(title: localized("close_account_success"),
                                          message: localized("close_account_success_message"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                Env.userSessionStore.logout()
                self?.dismiss(animated: true)
            }))

            self.present(alert, animated: true, completion: nil)
        case .error:
            let alert = UIAlertController(title: localized("close_account_error"),
                                          message: localized("close_account_error_message"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

    }
}

//
// MARK: - Actions
//
extension CloseAccountViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCloseAccountButton() {

        self.showConfirmationAlert()
    }
}

//
// MARK: Subviews initialization and setup
//
extension CloseAccountViewController {

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
        label.text = localized("close_account")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }

    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("close_account_alert_text")
        label.font = AppFont.with(type: .semibold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createCloseAccountButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        StyleHelper.styleButton(button: button)
        button.setTitle(localized("confirm_close_account_button"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
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

        self.view.addSubview(self.messageLabel)

        self.view.addSubview(self.closeAccountButton)

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

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Main view
        NSLayoutConstraint.activate([

            self.messageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.messageLabel.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 30),

            self.closeAccountButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.closeAccountButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.closeAccountButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeAccountButton.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 30)
        ])

        // Loading View
        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
    }

}
