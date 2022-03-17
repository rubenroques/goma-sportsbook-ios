//
//  HomeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/02/2022.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: - Public Properties
    var didTapBetslipButtonAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    // MARK: - Private Properties
    // Sub Views
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HomeViewModel

    private var shortcutSelectedOption: Int = -1
    
    // MARK: - Lifetime and Cycle
    init(viewModel: HomeViewModel = HomeViewModel()) {
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

        self.tableView.register(SportMatchDoubleLineTableViewCell.self, forCellReuseIdentifier: SportMatchDoubleLineTableViewCell.identifier)
        self.tableView.register(SportMatchSingleLineTableViewCell.self, forCellReuseIdentifier: SportMatchSingleLineTableViewCell.identifier)
        self.tableView.register(TopCompetitionLineTableViewCell.self, forCellReuseIdentifier: TopCompetitionLineTableViewCell.identifier)
        self.tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        self.tableView.register(SuggestedBetLineTableViewCell.self, forCellReuseIdentifier: SuggestedBetLineTableViewCell.identifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)

        self.loadingBaseView.isHidden = true

        self.betslipCountLabel.isHidden = true

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.tintColor = UIColor.gray

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: HomeViewModel) {

        viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &self.cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in
                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
                }
            })
            .store(in: &cancellables)

    }

    private func openCompetitionDetails(competitionId: String, sport: Sport) {
        let competitionDetailsViewModel = CompetitionDetailsViewModel(competitionsIds: [competitionId], sport: sport, store: AggregatorsRepository())
        let competitionDetailsViewController = CompetitionDetailsViewController(viewModel: competitionDetailsViewModel)
        self.navigationController?.pushViewController(competitionDetailsViewController, animated: true)
    }

    private func openOutrightCompetition(competition: Competition) {
        let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
        let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
    }

    private func openMatchDetails(match: Match) {
        let matchMode: MatchDetailsViewController.MatchMode = self.viewModel.isMatchLive(withMatchId: match.id) ? .live : .preLive
        let matchDetailsViewController = MatchDetailsViewController(matchMode: matchMode, match: match)
        self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
    }

    private func openPopularDetails(_ sport: Sport) {
        let viewModel =  PopularDetailsViewModel(sport: sport, store: AggregatorsRepository())
        let popularDetailsViewController = PopularDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(popularDetailsViewController, animated: true)
    }

    private func openLiveDetails(_ sport: Sport) {
        let viewModel =  LiveDetailsViewModel(sport: sport, store: AggregatorsRepository())
        let liveDetailsViewController = LiveDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(liveDetailsViewController, animated: true)
    }

    @objc private func didTapOpenFavorites() {
        self.openFavorites()
    }

    private func openFavorites() {
        let myFavoritesViewController = MyFavoritesViewController()
        self.present(Router.navigationController(with: myFavoritesViewController), animated: true, completion: nil)
    }
}

//
// MARK: - TableView Protocols
//
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            fatalError()
        }

        switch contentType {
        case .userMessage:
            return UITableViewCell()
        case .bannerLine:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BannerScrollTableViewCell.identifier) as? BannerScrollTableViewCell,
                let sportMatchLineViewModel = self.viewModel.bannerLineViewModel()
            else {
                fatalError()
            }
            cell.configure(withViewModel: sportMatchLineViewModel)
            return cell

        case .userFavorites:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: MatchLineTableViewCell.identifier) as? MatchLineTableViewCell,
                let match = self.viewModel.favoriteMatch(forIndex: indexPath.row)
            else {
                fatalError()
            }

            cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)
            cell.setupWithMatch(match, store: self.viewModel.store)
            cell.setupFavoriteMatchInfoPublisher(match: match)
            cell.tappedMatchLineAction = { [weak self] in
                self?.openMatchDetails(match: match)
            }
            cell.didTapFavoriteMatchAction = { [weak self] match in
                self?.viewModel.markAsFavorite(match: match)
            }
           
            return cell

        case .suggestedBets:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedBetLineTableViewCell.identifier) as? SuggestedBetLineTableViewCell,
                let suggestedBetLineViewModel = self.viewModel.getSuggestedBetLineViewModel()
            else {
                fatalError()
            }
            cell.configure(withViewModel: suggestedBetLineViewModel)
            cell.betNowCallbackAction = { [weak self] in
                self?.didTapBetslipButtonAction?()
            }
            return cell

        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                fatalError()
            }
            
            switch sportMatchLineViewModel.loadingPublisher.value {
            case .loading, .empty:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                
                return cell
            case.loaded:
                ()
                
            }
            
            switch sportMatchLineViewModel.layoutTypePublisher.value {
            case .doubleLine:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SportMatchDoubleLineTableViewCell.identifier)
                        as? SportMatchDoubleLineTableViewCell
                else {
                    fatalError()
                }

                cell.matchStatsViewModelForMatch = { [weak self] match in
                    self?.viewModel.matchStatsViewModel(forMatch: match)
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.openMatchDetails(match: match)
                }
                cell.didSelectSeeAllLive = { [weak self] sport in
                    self?.openLiveDetails(sport)
                }
                cell.didSelectSeeAllPopular = { [weak self] sport in
                    self?.openPopularDetails(sport)
                }
                cell.didSelectSeeAllCompetitionAction = { [weak self] competition in
                    self?.openOutrightCompetition(competition: competition)
                }
                
                cell.didTapFavoriteMatchAction = { [weak self] match in
                    if UserSessionStore.isUserLogged() {
                        self?.viewModel.markAsFavorite(match: match)
                    }
                    else {
                        let loginViewController = Router.navigationController(with: LoginViewController())
                        self?.present(loginViewController, animated: true, completion: nil)
                    }
                    
                }
                
                return cell

            case .singleLine:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SportMatchSingleLineTableViewCell.identifier)
                        as? SportMatchSingleLineTableViewCell
                else {
                    fatalError()
                }
                cell.matchStatsViewModelForMatch = { [weak self] match in
                    self?.viewModel.matchStatsViewModel(forMatch: match)
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.openMatchDetails(match: match)
                }
                cell.didSelectSeeAllLive = { [weak self] sport in
                    self?.openLiveDetails(sport)
                }
                cell.didSelectSeeAllPopular = { [weak self] sport in
                    self?.openPopularDetails(sport)
                }
                
                cell.didTapFavoriteMatchAction = { [weak self] match in
                    if UserSessionStore.isUserLogged() {
                        self?.viewModel.markAsFavorite(match: match)
                    }
                    else {
                        let loginViewController = Router.navigationController(with: LoginViewController())
                        self?.present(loginViewController, animated: true, completion: nil)
                    }
                }
                
                return cell
                
            case .competition:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: TopCompetitionLineTableViewCell.identifier)
                        as? TopCompetitionLineTableViewCell
                else {
                    fatalError()
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.didSelectSeeAllCompetitionAction = { [weak self] sport, competition in
                    self?.openCompetitionDetails(competitionId: competition.id, sport: sport)
                }
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return UITableView.automaticDimension
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return 180
        case .userFavorites:
            return UITableView.automaticDimension
        case .suggestedBets:
            return 336
        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                return UITableView.automaticDimension
            }
            
            if sportMatchLineViewModel.loadingPublisher.value == .empty {
                return .leastNormalMagnitude
            }
            else if sportMatchLineViewModel.loadingPublisher.value == .loading {
                return .leastNormalMagnitude
            }
            else {
                switch sportMatchLineViewModel.layoutTypePublisher.value {
                case .doubleLine: return 437
                case .singleLine: return 277
                case .competition: return 200
                }
            }
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return 356
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return 180
        case .userFavorites:
            return MatchWidgetCollectionViewCell.cellHeight + 20
        case .suggestedBets:
            return 336
        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                return UITableView.automaticDimension
            }

            if sportMatchLineViewModel.loadingPublisher.value == .empty {
                return .leastNormalMagnitude
            }
            else if sportMatchLineViewModel.loadingPublisher.value == .loading {
                return .leastNormalMagnitude
            }
            else {
                switch sportMatchLineViewModel.layoutTypePublisher.value {
                case .doubleLine: return 437
                case .singleLine: return 277
                case .competition: return 200
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let titleView = UIView()
        titleView.backgroundColor = UIColor.App.backgroundPrimary

        let titleStackView = UIStackView()
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .fill
        titleStackView.spacing = 8

        let sportImageView = UIImageView()
        sportImageView.translatesAutoresizingMaskIntoConstraints = false
        sportImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 17)

        titleView.addSubview(titleStackView)
        titleStackView.addArrangedSubview(sportImageView)
        titleStackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            sportImageView.widthAnchor.constraint(equalTo: sportImageView.heightAnchor, multiplier: 1),
            sportImageView.widthAnchor.constraint(equalToConstant: 17),

            titleStackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 18),
            titleStackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 18),

            titleStackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
        ])

        if let title = self.viewModel.title(forSection: section) {
            titleLabel.text = title
        }
        if let imageName = self.viewModel.iconName(forSection: section) {
            sportImageView.image = UIImage(named: "sport_type_icon_\(imageName)")
        }
        else {
            sportImageView.isHidden = true
        }

        return titleView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowTitle(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowTitle(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard
            self.viewModel.shouldShowFooter(forSection: section)
        else {
            return UIView()
        }

        let baseView = UIView()
        baseView.backgroundColor = UIColor.App.backgroundPrimary

        let seeAllView = UIView()
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        seeAllView.layer.borderColor = UIColor.gray.cgColor
        seeAllView.layer.borderWidth = 0
        seeAllView.layer.cornerRadius = 6

        let seeAllLabel = UILabel()
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = "Open Favorites"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center

        seeAllView.addSubview(seeAllLabel)
        baseView.addSubview(seeAllView)

        NSLayoutConstraint.activate([
            seeAllLabel.centerYAnchor.constraint(equalTo: seeAllView.centerYAnchor),
            seeAllLabel.centerXAnchor.constraint(equalTo: seeAllView.centerXAnchor),
            seeAllLabel.leadingAnchor.constraint(equalTo: seeAllView.leadingAnchor),

            seeAllView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            seeAllView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            seeAllView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 2),
            seeAllView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 16),
        ])

        seeAllView.backgroundColor = UIColor.App.backgroundTertiary
        seeAllLabel.textColor = UIColor.App.textPrimary

        seeAllView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOpenFavorites)))

        return baseView

    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowFooter(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowFooter(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

}

extension HomeViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {
            guard
                let contentType = self.viewModel.contentType(forSection: indexPath.section)
            else {
                return
            }

            switch contentType {
            case .userMessage:
                ()
            case .bannerLine:
                _ = self.viewModel.bannerLineViewModel()
            case .userFavorites:
                ()
            case .suggestedBets:
                _ = self.viewModel.getSuggestedBetLineViewModel()
            case .sport:
                _ = self.viewModel.sportGroupViewModel(forSection: indexPath.section)
            }
        }
    }
}

//
// MARK: - Actions
//
extension HomeViewController {

    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension HomeViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }

    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createBetslipCountLabel() -> UILabel {
        let betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        return betslipCountLabel
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

    private func setupSubviews() {

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)

        // Initialize constraints
        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    private func initConstraints() {

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
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),

            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
        ])

    }

}
