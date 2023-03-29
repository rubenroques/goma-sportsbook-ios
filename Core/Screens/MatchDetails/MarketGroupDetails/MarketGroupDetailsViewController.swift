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

    private lazy var backgroundGradientView: GradientView = Self.createBackgroundGradientView()

    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var expandedMarketGroupIds: Set<String> = []
    private var viewModel: MarketGroupDetailsViewModel
    private var betBuilderGrayoutsState: BetBuilderGrayoutsState = BetBuilderGrayoutsState()
    
    private var cancellables: Set<AnyCancellable> = []

    // ScrollView content offset
    private var lastContentOffset: CGFloat = 0
    var shouldScrollToTop: ((Bool) -> Void)?
    var enableAutoScroll: (() -> Void?)?

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

        self.backgroundGradientView.colors = [(UIColor.App.backgroundGradient1, 0.0),
                                              (UIColor.App.backgroundGradient2, 1.0)]
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
                
                print("grayoutdebug vc refreshing tableview")
            }
            .store(in: &cancellables)
        
    }

    // MARK: - Actions

    // MARK: - Convenience
    func reloadContent() {
        self.reloadTableView()
    }

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

    func firstMarket() -> Market? {
        return viewModel.firstMarket()
    }

    private func openQuickbet(_ bettingTicket: BettingTicket) {

        if let userSession = UserSessionStore.loggedUserSession() {
            let quickbetViewModel = QuickBetViewModel(bettingTicket: bettingTicket)

            let quickbetViewController = QuickBetViewController(viewModel: quickbetViewModel)

            quickbetViewController.modalPresentationStyle = .overCurrentContext
            quickbetViewController.modalTransitionStyle = .crossDissolve

            self.present(quickbetViewController, animated: true)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
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
                self?.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId),
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
                self?.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId),
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
                self?.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseCellAction = {  [weak self] marketGroupOrganizerId in
                self?.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId),
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let scrollViewTop = scrollView.frame.origin.y
        let currentYPosition = scrollView.contentOffset.y
        let currentBottomYPosition = scrollView.frame.size.height + currentYPosition

        if scrollViewTop == scrollView.contentOffset.y && self.lastContentOffset != 0 {
            self.shouldScrollToTop?(true)
            self.enableAutoScroll?()
        }
        else if self.lastContentOffset > scrollViewTop {
            self.shouldScrollToTop?(false)
        }

        if scrollView.contentOffset.y > self.lastContentOffset {
            self.tableView.bounces = true
        }
        else {
            if currentBottomYPosition < scrollView.contentSize.height + scrollView.contentInset.bottom {

                self.tableView.bounces = false
            }
        }

        self.lastContentOffset = scrollView.contentOffset.y
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.enableAutoScroll?()
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
    private static func createBackgroundGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.backgroundGradientView)
        self.view.addSubview(self.tableView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

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
