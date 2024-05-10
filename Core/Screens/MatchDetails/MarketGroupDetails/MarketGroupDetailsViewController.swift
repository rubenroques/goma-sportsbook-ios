//
//  MarketGroupDetailsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/03/2022.
//

import Foundation
import UIKit
import Combine
import OrderedCollections

class MarketGroupDetailsViewController: UIViewController {

    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    private let expandCollapseButton = UIButton(type: .system)

    private var seeAllOutcomesMarketGroupIds: Set<String> = []
    private var isCollapsedMarketGroupIds: Set<String> = []

    private var viewModel: MarketGroupDetailsViewModel
    private var betBuilderGrayoutsState: BetBuilderGrayoutsState = BetBuilderGrayoutsState()
    
    private var cancellables: Set<AnyCancellable> = []

    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?

    //
    // MARK: - Stored Properties for Scroll Delegate
    private var dragDirection: InnerScrollDragDirection = .up
    private var oldContentOffset = CGPoint.zero

    //
    // MARK: - Lifetime and Cycle
    init(viewModel: MarketGroupDetailsViewModel) {
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

        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.tableView.separatorStyle = .none
        
        self.tableView.register(SimpleListMarketDetailTableViewCell.nib, forCellReuseIdentifier: SimpleListMarketDetailTableViewCell.identifier)
        self.tableView.register(ThreeAwayMarketDetailTableViewCell.nib, forCellReuseIdentifier: ThreeAwayMarketDetailTableViewCell.identifier)
        self.tableView.register(OverUnderMarketDetailTableViewCell.nib, forCellReuseIdentifier: OverUnderMarketDetailTableViewCell.identifier)

//        self.tableView.bounces = false

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 186, height: 20))
        headerView.backgroundColor = UIColor.clear

        self.expandCollapseButton.setTitle(localized("collapse_all"), for: .normal)
        self.expandCollapseButton.setTitleColor(UIColor.App.textSecondary, for: .normal)
        self.expandCollapseButton.titleLabel?.textAlignment = .right
        self.expandCollapseButton.titleLabel?.font = AppFont.with(type: .medium, size: 11)
        self.expandCollapseButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(self.expandCollapseButton)
        self.expandCollapseButton.addTarget(self, action: #selector(toggleExpandAll), for: .primaryActionTriggered)

        // Set constraints
        NSLayoutConstraint.activate([
            self.expandCollapseButton.widthAnchor.constraint(equalToConstant: 60),
            self.expandCollapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            self.expandCollapseButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            self.expandCollapseButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 1),
        ])

        self.tableView.tableHeaderView = headerView

        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        self.showLoading()

        self.bind(toViewModel: self.viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewModel.fetchMarketGroupDetails()
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = .clear

        self.tableView.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: MarketGroupDetailsViewModel) {

        viewModel.isLoadingPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)

        viewModel.marketGroupOrganizersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.reloadTableView()
            })
            .store(in: &cancellables)
        
        viewModel.grayedOutSelectionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { betBuilderGrayoutsState in
                self.betBuilderGrayoutsState = betBuilderGrayoutsState
                self.reloadTableView()
            }
            .store(in: &cancellables)
        
    }

    // MARK: - Actions

    // MARK: - Convenience
    func reloadContent() {
        self.reloadTableView()
    }
    
    func setUpdatedMatch(match: Match) {
        self.viewModel.match = match
        self.reloadContent()
    }

    private func reloadTableView() {
        self.tableView.reloadData()

        if self.isCollapsedMarketGroupIds.isEmpty {
            self.expandCollapseButton.setTitle(localized("collapse_all"), for: .normal)
        }
        else {
            self.expandCollapseButton.setTitle(localized("expand_all"), for: .normal)
        }
    }

    private func showLoading() {
        self.loadingSpinnerViewController.startAnimating()
        self.loadingBaseView.isHidden = false

    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingSpinnerViewController.stopAnimating()
    }

    func firstMarket() -> Market? {
        return viewModel.firstMarket()
    }

    private func openQuickbet(_ bettingTicket: BettingTicket) {

        if Env.userSessionStore.isUserLogged() {
            let quickbetViewModel = QuickBetViewModel(bettingTicket: bettingTicket)

            let quickbetViewController = QuickBetViewController(viewModel: quickbetViewModel)

            quickbetViewController.modalPresentationStyle = .overCurrentContext
            quickbetViewController.modalTransitionStyle = .crossDissolve
            
            quickbetViewController.shouldShowBetSuccess = { bettingTicket, betPlacedDetails in
                
                quickbetViewController.dismiss(animated: true, completion: {
                    
                    self.showBetSucess(bettingTicket: bettingTicket, betPlacedDetails: betPlacedDetails)
                })
            }

            self.present(quickbetViewController, animated: true)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    private func showBetSucess(bettingTicket: BettingTicket, betPlacedDetails: [BetPlacedDetails]) {
        
        let betSubmissionSuccessViewController = BetSubmissionSuccessViewController(betPlacedDetailsArray: betPlacedDetails,
                                                                                    cashbackResultValue: nil,
                                                                                    usedCashback: false,
        bettingTickets: [bettingTicket])
        
        self.present(Router.navigationController(with: betSubmissionSuccessViewController), animated: true)
    }

    func scrollToTop() {
        let topOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.setContentOffset(topOffset, animated: true)
    }

    @objc func toggleExpandAll(sender: UIButton) {
        if self.isCollapsedMarketGroupIds.isEmpty {
            // Add all to collapsed
            for row in 0..<self.viewModel.numberOfRows() {
                if let marketGroupOrganizer = self.viewModel.marketGroupOrganizer(forRow: row) {
                    self.isCollapsedMarketGroupIds.insert(marketGroupOrganizer.marketId)
                }
            }
        }
        else {
            // Clear collapsed
            self.isCollapsedMarketGroupIds = []
        }

        self.reloadTableView()
    }
}


// MARK: - TableView Protocols
//
extension MarketGroupDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let marketGroupOrganizer = self.viewModel.marketGroupOrganizer(forRow: indexPath.row)
        else {
            return UITableViewCell()
        }

        if marketGroupOrganizer.numberOfColumns == 3 {
            guard
                let cell = tableView.dequeueCellType(ThreeAwayMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.marketId = marketGroupOrganizer.marketId
            cell.match = self.viewModel.match
            
            cell.didExpandCellAction = { [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: self.betBuilderGrayoutsState)

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }

            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 2 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.marketId = marketGroupOrganizer.marketId
            cell.match = self.viewModel.match
            
            cell.didExpandCellAction = {  [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: self.betBuilderGrayoutsState)

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }

            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 1 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.marketId = marketGroupOrganizer.marketId
            cell.match = self.viewModel.match
            
            cell.didExpandCellAction = {  [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: self.betBuilderGrayoutsState)

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(SimpleListMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.match = self.viewModel.match
                        
            cell.market = self.viewModel.match.markets.first(where: {
                $0.id == marketGroupOrganizer.marketId
            })
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer)

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }

            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}

extension MarketGroupDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let delta = scrollView.contentOffset.y - oldContentOffset.y
        let topViewCurrentHeightConst = innerTableViewScrollDelegate?.currentHeaderHeight

        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            if delta > 0, topViewUnwrappedHeight > 0, scrollView.contentOffset.y > 0 {
                dragDirection = .up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }

            if delta < 0, scrollView.contentOffset.y < 0 {
                dragDirection = .down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }

        }

        oldContentOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}

extension MarketGroupDetailsViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
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
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }
}
