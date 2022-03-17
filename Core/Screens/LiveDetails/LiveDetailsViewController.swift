//
//  LiveDetailsViewController.swift
//  ShowcaseProd
//
//  Created by Ruben Roques on 14/03/2022.
//

import UIKit
import Combine
import OrderedCollections

class LiveDetailsViewModel {

    var store: AggregatorsRepository

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var isLoading: CurrentValueSubject<Bool, Never> = .init(true)
    var titlePublisher: CurrentValueSubject<String, Never>

    private var matchesPublisher: AnyCancellable?
    private var matchesRegister: EndpointPublisherIdentifiable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []

    private var matchesCount = 10
    private var matchesPage = 1
    private var matchesHasNextPage = true

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport

        self.titlePublisher = .init("\(self.sport.name) - Live Matches")

        self.refresh()
    }

    func refresh() {
        self.resetPageCount()
        self.isLoading.send(true)

        self.fetchLocations()
            .sink { [weak self] locations in
                self?.store.storeLocations(locations: locations)
                self?.fetchMatches()
            }
            .store(in: &cancellables)
    }

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

    }

    private func resetPageCount() {
        self.matchesCount = 10
        self.matchesPage = 1
        self.matchesHasNextPage = true
    }

    private func fetchPopularMatchesNextPage() {
        if !matchesHasNextPage {
            return
        }
        self.matchesPage += 1
        self.fetchMatches()
    }

    private func fetchMatches() {

        if let matchesRegister = matchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchesRegister)
        }

        let matchesCount = self.matchesCount * self.matchesPage

        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: self.sport.id,
                                                        matchesCount: matchesCount)
        self.matchesPublisher?.cancel()
        self.matchesPublisher = nil

        self.matchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoading.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.matchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeAggregatorProcessor(aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateWithAggregatorProcessor(aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    private func storeAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)

        let matches = self.store.matchesForListType(.popularEvents)
        if matches.count < self.matchesCount * self.matchesPage {
            self.matchesHasNextPage = false
        }

        self.matches = matches

        self.isLoading.send(false)

        self.refreshPublisher.send()
    }

    private func updateWithAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregator(aggregator)
    }

}

extension LiveDetailsViewModel {

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func isMatchLive(withMatchId matchId: String) -> Bool {
        return self.store.hasMatchesInfoForMatch(withId: matchId)
    }

}

extension LiveDetailsViewModel {

    func numberOfSection() -> Int {
        return 1
    }

    func numberOfItems(forSection section: Int) -> Int {
        return self.matches.count
    }

    func match(forIndexPath indexPath: IndexPath) -> Match? {
        return self.matches[safe: indexPath.row]
    }

}

class LiveDetailsViewController: UIViewController {

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
    private let refreshControl = UIRefreshControl()

    private var collapsedCompetitionsSections: Set<Int> = []

    private var viewModel: LiveDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: LiveDetailsViewModel) {
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

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)

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
    private func bind(toViewModel viewModel: LiveDetailsViewModel) {
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
    @objc func refreshControllPulled() {
        self.viewModel.refresh()
    }
    
    @objc func didTapBackButton() {
        if self.isModal {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
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
extension LiveDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfItems(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let match = self.viewModel.match(forIndexPath: indexPath),
            let cell = tableView.dequeueCellType(MatchLineTableViewCell.self)
        else {
            fatalError()
        }

        cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)
        cell.setupWithMatch(match, store: self.viewModel.store)
        cell.shouldShowCountryFlag(false)
        cell.tappedMatchLineAction = { [weak self] in
            self?.openMatchDetails(match)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MatchWidgetCollectionViewCell.cellHeight + 20
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return MatchWidgetCollectionViewCell.cellHeight + 20
    }

}

extension LiveDetailsViewController {

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
        titleLabel.text = "Live Matches"
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
