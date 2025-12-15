//
//  MyFavoritesRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 31/07/2023.
//

import UIKit
import Combine

class MyFavoritesRootViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()

    private lazy var cashbackBaseView: UIView = Self.createCashbackBaseView()
    private lazy var cashbackIconImageView: UIImageView = Self.createCashbackIconImageView()
    private lazy var cashbackValueLabel: UILabel = Self.createCashbackValueLabel()

    private lazy var containerBaseView: UIView = Self.createContainerView()

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource
    private var viewControllers: [UIViewController] = []

    private var myGamesViewController: MyGamesRootViewController
    private var myCompetitionsViewController: MyCompetitionsRootViewController

    private var cancellables = Set<AnyCancellable>()

    var isModalViewController: Bool = false {
        didSet {
            self.backButton.isHidden = isModalViewController
            self.closeButton.isHidden = !isModalViewController
        }
    }
    
    var resumeContentAction: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init() {

        self.myGamesViewController = MyGamesRootViewController(viewModel: MyGamesRootViewModel())
        self.myCompetitionsViewController = MyCompetitionsRootViewController(viewModel: MyCompetitionsRootViewModel())

        self.viewControllers = [self.myCompetitionsViewController, self.myGamesViewController]
        self.viewControllerTabDataSource = TitleTabularDataSource(with: viewControllers)

        self.viewControllerTabDataSource.initialPage = 0

        self.tabViewController = TabularViewController(dataSource: viewControllerTabDataSource)

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()

        self.addChildViewController(tabViewController, toView: self.containerBaseView)
        self.tabViewController.textFont = AppFont.with(type: .bold, size: 16)
        self.tabViewController.setBarDistribution(.parent)

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)

        self.setupWithTheme()

        if let navigationController = self.navigationController {

            self.isModalViewController = false

        }
        else if let presentingViewController = self.presentingViewController {

            self.isModalViewController = true

        }
        else {

            self.isModalViewController = false

        }

        self.setupPublishers()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.isRootModal {
            self.backButton.setImage(UIImage(named: "arrow_close_icon"), for: .normal)
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.containerBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        self.cashbackBaseView.backgroundColor = UIColor.App.highlightPrimaryContrast.withAlphaComponent(0.05)

        self.cashbackValueLabel.textColor = UIColor.App.textSecondary

    }

    // MARK: Functions
    private func setupPublishers() {

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userCashbackBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cashbackBalance in
                if let cashbackBalance = cashbackBalance,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance)) {
                    self?.cashbackValueLabel.text = formattedTotalString
                }
                else {
                    self?.cashbackValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }    }

    @objc private func didTapCloseButton() {
        self.resumeContentAction?()
        self.dismiss(animated: true)

    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }

        self.present(navigationViewController, animated: true, completion: nil)
    }
}

extension MyFavoritesRootViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension MyFavoritesRootViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("my_favorites")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_close_icon"), for: .normal)
        return button
    }

    private static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }

    private static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.squareView
        view.layer.masksToBounds = true
        return view
    }

    private static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plus_small_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.text = localized("loading")
        return label
    }

    private static func createCashbackBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cashback_icon")
        return imageView
    }

    private static func createCashbackValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButton)
        self.navigationBaseView.addSubview(self.closeButton)
        self.navigationBaseView.addSubview(self.accountValueView)
        self.navigationBaseView.addSubview(self.cashbackBaseView)

        self.accountValueView.addSubview(self.accountPlusView)
        self.accountPlusView.addSubview(self.accountPlusImageView)
        self.accountValueView.addSubview(self.accountValueLabel)

        self.cashbackBaseView.addSubview(self.cashbackIconImageView)
        self.cashbackBaseView.addSubview(self.cashbackValueLabel)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.containerBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),

            self.closeButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),

            self.accountValueView.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueView.trailingAnchor.constraint(equalTo: self.navigationBaseView.trailingAnchor, constant: -12),

            self.accountPlusView.widthAnchor.constraint(equalTo: self.accountPlusView.heightAnchor),
            self.accountPlusView.leadingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor, constant: 4),
            self.accountPlusView.topAnchor.constraint(equalTo: self.accountValueView.topAnchor, constant: 4),
            self.accountPlusView.bottomAnchor.constraint(equalTo: self.accountValueView.bottomAnchor, constant: -4),

            self.accountPlusImageView.widthAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.heightAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.centerXAnchor.constraint(equalTo: self.accountPlusView.centerXAnchor),
            self.accountPlusImageView.centerYAnchor.constraint(equalTo: self.accountPlusView.centerYAnchor),

            self.accountValueLabel.centerYAnchor.constraint(equalTo: self.accountValueView.centerYAnchor),
            self.accountValueLabel.leadingAnchor.constraint(equalTo: self.accountPlusView.trailingAnchor, constant: 4),
            self.accountValueLabel.trailingAnchor.constraint(equalTo: self.accountValueView.trailingAnchor, constant: -4),

            self.cashbackBaseView.trailingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor, constant: -4),
            self.cashbackBaseView.heightAnchor.constraint(equalToConstant: 24),
            self.cashbackBaseView.centerYAnchor.constraint(equalTo: self.accountValueView.centerYAnchor),

            self.cashbackIconImageView.leadingAnchor.constraint(equalTo: self.cashbackBaseView.leadingAnchor, constant: 4),
            self.cashbackIconImageView.topAnchor.constraint(equalTo: self.cashbackBaseView.topAnchor, constant: 4),
            self.cashbackIconImageView.bottomAnchor.constraint(equalTo: self.cashbackBaseView.bottomAnchor, constant: -4),
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 14),

            self.cashbackValueLabel.leadingAnchor.constraint(equalTo: self.cashbackIconImageView.trailingAnchor, constant: 4),
            self.cashbackValueLabel.trailingAnchor.constraint(equalTo: self.cashbackBaseView.trailingAnchor, constant: -4),
            self.cashbackValueLabel.centerYAnchor.constraint(equalTo: self.cashbackBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([

            self.containerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.containerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
}
