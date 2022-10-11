//
//  SuggestedBetsListViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/04/2022.
//

import UIKit
import Combine

class SuggestedBetsListViewModel {

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var needsReload: PassthroughSubject<Void, Never> = .init()

    private var suggestedBetsSummaries: [[SuggestedBetSummary]] = []
    private var cachedSuggestedBetViewModels: [Int: SuggestedBetViewModel] = [:]
    private var suggestedCellLoadedPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.getSuggestedBets()
    }

    deinit {
        print("SuggestedBetsListViewModel deinit")

        for cachedBetSuggestedViewModel in self.cachedSuggestedBetViewModels.values {
            cachedBetSuggestedViewModel.unregisterSuggestedBets()
        }

        cachedSuggestedBetViewModels = [:]
    }

    func refreshSuggestedBets() {
        self.suggestedBetsSummaries = []
        self.needsReload.send()

        self.getSuggestedBets()
    }

    func getSuggestedBets() {

        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            },
            receiveValue: { [weak self] gomaBetsArray in
                guard let betsArray = gomaBetsArray else { return }
                self?.suggestedBetsSummaries = betsArray.filter({ suggestedBetSummary in
                    suggestedBetSummary.count > 1
                })
                self?.needsReload.send()
                self?.isLoadingPublisher.send(false)
            })
            .store(in: &cancellables)
    }

    func numberOfRows() -> Int {
        return self.suggestedBetsSummaries.count
    }

    func viewModelForRow(_ row: Int) -> SuggestedBetViewModel {
        if let cachedViewModel = self.cachedSuggestedBetViewModels[row].value {
            return cachedViewModel
        }
        else {
            let betsArray = suggestedBetsSummaries[row]
            let viewModel = SuggestedBetViewModel(suggestedBetCardSummary: SuggestedBetCardSummary(bets: betsArray))
            self.cachedSuggestedBetViewModels[row] = viewModel
            return viewModel
        }
    }

}

class SuggestedBetsListViewController: UIViewController {

    // MARK: - Public Properties

    // MARK: - Private Properties
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var tableHeaderView: UIView = Self.createTableHeaderView()
    private lazy var headerTitleLabel: UILabel = Self.createHeaderTitleLabel()
    private lazy var headerSubtitleLabel: UILabel = Self.createHeaderSubtitleLabel()
    private lazy var emptySharedBetView: BetslipErrorView = Self.createEmptySharedBetView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var viewModel: SuggestedBetsListViewModel
    private var cancellables = Set<AnyCancellable>()

    var isEmptySharedBet: Bool = false {
        didSet {
            self.emptySharedBetView.isHidden = !isEmptySharedBet
            self.headerTitleLabel.isHidden = isEmptySharedBet
            self.headerSubtitleLabel.isHidden = isEmptySharedBet
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: SuggestedBetsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("SuggestedBetsListViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.register(SuggestedBetTableViewCell.self, forCellReuseIdentifier: SuggestedBetTableViewCell.identifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.headerTitleLabel.textColor = UIColor.App.textPrimary
        self.headerSubtitleLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: SuggestedBetsListViewModel) {

        self.viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }.store(in: &cancellables)
        
        self.viewModel.needsReload
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadTableView()
            }
            .store(in: &cancellables)
    }

    // MARK: - Convenience
    func refreshSuggestedBets() {
        self.viewModel.refreshSuggestedBets()
    }

    func reloadTableView() {
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

extension SuggestedBetsListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(SuggestedBetTableViewCell.self)
        else {
            fatalError()
        }
        cell.setupWithViewModel(viewModel: self.viewModel.viewModelForRow(indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
}

extension SuggestedBetsListViewController {

    private static func createTableHeaderView() -> UIView {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 186, height: 110))
        return tableHeaderView
    }

    private static func createHeaderTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = "You don’t have any selections yet."
        return titleLabel
    }

    private static func createHeaderSubtitleLabel() -> UILabel {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.with(type: .bold, size: 20)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "Here are your Suggested Bets!"
        return subtitleLabel
    }

    private static func createEmptySharedBetView() -> BetslipErrorView {
        let view = BetslipErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setDescription(description: localized("shared_bet_unavailable"))
        view.setAlertLayout()
        return view
    }

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

        self.tableHeaderView.addSubview(self.headerTitleLabel)
        self.tableHeaderView.addSubview(self.headerSubtitleLabel)
        self.tableHeaderView.addSubview(self.emptySharedBetView)

        self.tableView.tableHeaderView = self.tableHeaderView

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.headerTitleLabel.heightAnchor.constraint(equalToConstant: 24),
            self.tableHeaderView.centerXAnchor.constraint(equalTo: self.headerTitleLabel.centerXAnchor),
            self.tableHeaderView.leadingAnchor.constraint(equalTo: self.headerTitleLabel.leadingAnchor, constant: -12),
            self.tableHeaderView.centerYAnchor.constraint(equalTo: self.headerTitleLabel.bottomAnchor, constant: 5),

            self.headerSubtitleLabel.heightAnchor.constraint(equalToConstant: 24),
            self.tableHeaderView.centerXAnchor.constraint(equalTo: self.headerSubtitleLabel.centerXAnchor),
            self.tableHeaderView.leadingAnchor.constraint(equalTo: self.headerSubtitleLabel.leadingAnchor, constant: -12),
            self.tableHeaderView.centerYAnchor.constraint(equalTo: self.headerSubtitleLabel.topAnchor, constant: -5),

            self.emptySharedBetView.leadingAnchor.constraint(equalTo: self.tableHeaderView.leadingAnchor),
            self.emptySharedBetView.trailingAnchor.constraint(equalTo: self.tableHeaderView.trailingAnchor),
            self.emptySharedBetView.centerYAnchor.constraint(equalTo: self.tableHeaderView.centerYAnchor)
        ])

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
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }
}
