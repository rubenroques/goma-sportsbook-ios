//
//  PopularDetailsViewController.swift
//  ShowcaseProd
//
//  Created by Ruben Roques on 14/03/2022.
//

import UIKit
import Combine
import OrderedCollections

class PopularDetailsViewController: UIViewController {

    // MARK: - Public Properties

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backgroundGradientView: GradientView = Self.createBackgroundGradientView()

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var tableView: UITableView = Self.createTableView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()

    private let refreshControl = UIRefreshControl()

    private var collapsedCompetitionsSections: Set<Int> = []

    private var viewModel: PopularDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: PopularDetailsViewModel) {
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)

        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)

        self.tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        self.tableView.register(OutrightCompetitionLargeLineTableViewCell.self,
                                forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)

        self.tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        self.tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
        
        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)
        self.accountValueView.isHidden = true

        self.showLoading()

        self.bind(toViewModel: self.viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.floatingShortcutsView.resetAnimations()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tableView.backgroundColor = .clear

        self.titleLabel.backgroundColor = .clear

        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        if TargetVariables.shouldUseGradientBackgrounds {
            self.backgroundGradientView.colors = [(UIColor.App.backgroundGradient1, NSNumber(0.0)),
                                                  (UIColor.App.backgroundGradient2, NSNumber(1.0))]
        }
        else {
            self.backgroundGradientView.colors = []
            self.backgroundGradientView.backgroundColor = UIColor.App.backgroundPrimary
        }
        
    }
    
    // MARK: - Bindings
    private func bind(toViewModel viewModel: PopularDetailsViewModel) {

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil { // Is Logged In
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &cancellables)

//        Env.userSessionStore.userBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
//                    let accountValue = bonusWallet.amount + value
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
//
//                }
//                else {
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
//                }
//            }
//            .store(in: &cancellables)
//
//        Env.userSessionStore.userBonusBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
//                    let accountValue = currentWallet.amount + value
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
//                }
//            }
//            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total))
                {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)
        
        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                    self?.refreshControl.endRefreshing()
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadTableView()
            })
            .store(in: &self.cancellables)

        self.viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &self.cancellables)

    }

    // MARK: - Actions
    @objc private func refreshControllPulled() {
        self.viewModel.refresh()
    }

    @objc private func didTapBackButton() {
        if self.isModal {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func didTapBetslipView() {
        self.openBetslipModal()
    }

    private func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadTableView()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }
    
    @objc func didTapChatView() {
        self.openChatModal()
    }
    
    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    private func openCompetitionDetails(_ competition: Competition) {
        let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
        let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
    }

    private func openMatchDetails(_ match: Match) {
        let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
        self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
        
        self.present(navigationViewController, animated: true, completion: nil)
    }

    // MARK: - Convenience
    private func reloadTableView() {
        self.tableView.reloadData()
    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

}

// MARK: - TableView Protocols
//
extension PopularDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfItems(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            guard
                let match = self.viewModel.match(forRow: indexPath.row),
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self)
            else {
                fatalError()
            }

            cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)

            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.viewModel = viewModel

            cell.shouldShowCountryFlag(true)
            cell.tappedMatchLineAction = { [weak self] match in
                self?.openMatchDetails(match)
            }
            return cell

        case 1:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.viewModel.outrightCompetition(forRow: indexPath.row)
            else {
                fatalError()
            }
            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.openCompetitionDetails(competition)
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) else {
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return StyleHelper.competitionCardsStyleHeight() + 20 // 145 // outrightMarket lines
        case 2:
            return 80
        default:
            return .leastNonzeroMagnitude
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return StyleHelper.cardsStyleHeight() + 20
        case 1:
            return StyleHelper.competitionCardsStyleHeight() + 20 // 145 // outrightMarket lines
        case 2:
            return 80
        default:
            return .leastNonzeroMagnitude
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2, self.viewModel.shouldShowLoadingCell() {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.viewModel.requestNextPage()
        }
    }

}

extension PopularDetailsViewController: UIGestureRecognizerDelegate {

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

// MARK: - User Interface setup
//
extension PopularDetailsViewController {

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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .left
        titleLabel.text = localized("popular_matches")
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createSeparatorHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
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
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
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

    private static func createBackgroundGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.view.addSubview(self.backgroundGradientView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)

        self.accountValueView.addSubview(self.accountPlusView)
        self.accountPlusView.addSubview(self.accountPlusImageView)
        self.accountValueView.addSubview(self.accountValueLabel)
        self.navigationView.addSubview(self.accountValueView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.floatingShortcutsView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 40),

            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 8),

            self.accountValueView.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueView.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -12),

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
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loadingBaseView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.navigationView.bottomAnchor.constraint(equalTo: self.loadingBaseView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }
}
