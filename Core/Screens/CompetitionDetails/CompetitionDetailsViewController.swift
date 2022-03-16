//
//  CompetitionDetailsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/03/2022.
//

import UIKit
import Combine
import OrderedCollections

class CompetitionDetailsViewController: UIViewController {


    // MARK: - Public Properties

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var collapsedCompetitionsSections: Set<Int> = []
    private var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?


    private var viewModel: CompetitionDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: CompetitionDetailsViewModel) {
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

        self.betslipCountLabel.isHidden = true

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        self.tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        self.tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.showLoading()

        self.bind(toViewModel: self.viewModel)
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

        self.betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary

        self.titleLabel.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: CompetitionDetailsViewModel) {
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

        self.viewModel.isLoadingCompetitions
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
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

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

    private func openCompetitionDetails(_ competition: Competition) {
        let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
        let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
    }

    private func openMatchDetails(_ match: Match) {
        let matchMode: MatchDetailsViewController.MatchMode = self.viewModel.isMatchLive(withMatchId: match.id) ? .live : .preLive
        let matchDetailsViewController = MatchDetailsViewController(matchMode: matchMode, match: match)
        self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
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
extension CompetitionDetailsViewController: UITableViewDelegate, UITableViewDataSource {

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
            if let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLineTableViewCell.identifier)
                as? OutrightCompetitionLineTableViewCell {

                cell.configure(withViewModel: OutrightCompetitionLineViewModel(competition: competition, shouldShowSeeAllOption: false))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.openCompetitionDetails(competition)
                }
                return cell
            }
        case .match(let match):
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self) {
                cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)
                cell.setupWithMatch(match, store: self.viewModel.store)
                cell.shouldShowCountryFlag(false)
                cell.tappedMatchLineAction = { [weak self] in
                    self?.openMatchDetails(match)
                }
                return cell
            }
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.viewModel.competitionForSection(forSection: section)
        else {
            fatalError()
        }

        headerView.nameTitleLabel.text = competition.name
        headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
        headerView.sectionIndex = section
        headerView.competition = competition
        headerView.didToggleHeaderViewAction = { [weak self] section in
            guard
                let weakSelf = self
            else { return }

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                weakSelf.collapsedCompetitionsSections.remove(section)
            }
            else {
                weakSelf.collapsedCompetitionsSections.insert(section)
            }
            weakSelf.needReloadSection(section)
        }
        if self.collapsedCompetitionsSections.contains(section) {
            headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
        }
        else {
            headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let contentType = self.viewModel.contentType(forIndexPath: indexPath) {
            switch contentType {
            case .outrightMarket:
                return 146
            case .match:
                return MatchWidgetCollectionViewCell.cellHeight + 20
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
                return 146
            case .match:
                return MatchWidgetCollectionViewCell.cellHeight + 20
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

extension CompetitionDetailsViewController {

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
        titleLabel.textAlignment = .center
        titleLabel.text = "Competition Details"
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
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
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

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.tableView)

        self.betslipButtonView.addSubview(self.betslipCountLabel)
        self.view.addSubview(self.betslipButtonView)

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

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 44),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),
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
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

        // Betslip button
        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
        ])

    }
}
