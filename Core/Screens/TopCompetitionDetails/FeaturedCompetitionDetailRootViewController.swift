//
//  FeaturedCompetitionDetailRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 13/06/2024.
//

import UIKit
import Combine
import Kingfisher

class FeaturedCompetitionDetailRootViewController: UIViewController {

    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()

    private lazy var tableView: UITableView = Self.createTableView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private let loadingSpinnerViewController = LoadingSpinnerViewController()
    
    private var collapsedCompetitionsSections: Set<Int> = []
    private var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    private var viewModel: TopCompetitionDetailsViewModel
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Lifetime and Cycle
    init(viewModel: TopCompetitionDetailsViewModel) {
        
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

        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: MatchLineTableViewCell.identifier)

        self.tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        self.tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)

        self.tableView.register(BannerTournamentTableViewHeader.self, forHeaderFooterViewReuseIdentifier: BannerTournamentTableViewHeader.identifier)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }

        self.showLoading()

        self.bind(toViewModel: self.viewModel)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.floatingShortcutsView.resetAnimations()
    
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = .clear
                
        self.backgroundImageView.backgroundColor = .clear
    }
    
    // MARK: - Bindings
    private func bind(toViewModel viewModel: TopCompetitionDetailsViewModel) {

        self.viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadTableView()
            })
            .store(in: &self.cancellables)

    }
    
    // MARK: - Actions
    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.tableView.reloadData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }
    
    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
    }
    
    private func openTopCompetitionDetails(_ competition: Competition) {
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
        self.loadingSpinnerViewController.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingSpinnerViewController.stopAnimating()
    }
    
    func scrollToTop() {

        let topOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.setContentOffset(topOffset, animated: true)

    }
}

// MARK: - TableView Protocols
//
extension FeaturedCompetitionDetailRootViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfItems(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let contentType = self.viewModel.contentType(forIndexPath: indexPath)
        else {
            fatalError()
        }

        switch contentType {
        case .outrightMarket(let competition):
            if let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                as? OutrightCompetitionLargeLineTableViewCell {

                cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.openTopCompetitionDetails(competition)
                }
                return cell
            }
        case .match(let match):
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self) {

                let viewModel = self.viewModel.matchLineTableCellViewModel(forMatch: match)
                cell.configure(withViewModel: viewModel)

                cell.shouldShowCountryFlag(true)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.openMatchDetails(match)
                }
                return cell
            }
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BannerTournamentTableViewHeader.identifier)
                as? BannerTournamentTableViewHeader,
            let competition = self.viewModel.competitionForSection(forSection: section)
        else {
            fatalError()
        }
        
        headerView.configure(competition: competition)
        
        headerView.didTapFavoriteCompetitionAction = { [weak self] competition in
            
            if !Env.userSessionStore.isUserLogged() {
                self?.presentLoginViewController()
            }
            else {
                self?.viewModel.markCompetitionAsFavorite(competition: competition)
                tableView.reloadData()
            }
            
        }
    
        return headerView
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let contentType = self.viewModel.contentType(forIndexPath: indexPath) {
            switch contentType {
            case .outrightMarket:
                switch StyleHelper.cardsStyleActive() {
                case .normal: return 145
                case .small: return 110
                }
            case .match:
                return UITableView.automaticDimension
            }
        }

        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let contentType = self.viewModel.contentType(forIndexPath: indexPath) {
            switch contentType {
            case .outrightMarket:
                switch StyleHelper.cardsStyleActive() {
                case .normal: return 145
                case .small: return 110
                }
            case .match:
                return StyleHelper.cardsStyleHeight() + 20
            }
        }

        return .leastNonzeroMagnitude
    }

    func needReloadSection(_ section: Int) {

        guard
            let competition = self.viewModel.competitionForSection(forSection: section)
        else {
            return
        }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: rows, with: .automatic)
        self.tableView.endUpdates()
    }

}

extension FeaturedCompetitionDetailRootViewController: UIGestureRecognizerDelegate {

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
extension FeaturedCompetitionDetailRootViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        // tableView.contentInset = UIEdgeInsets(top: -, left: 0, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
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
    
    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let featuredCompetitionBackground = Env.businessSettingsSocket.clientSettings.featuredCompetition?.pageDetailBackground {
            if let url = URL(string: featuredCompetitionBackground) {
                imageView.kf.setImage(with: url)
            }
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private func setupSubviews() {

        self.view.addSubview(self.backgroundImageView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.floatingShortcutsView)

        self.view.addSubview(self.loadingBaseView)
        
        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])

    }
}
