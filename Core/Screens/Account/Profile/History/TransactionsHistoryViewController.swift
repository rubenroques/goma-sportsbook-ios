//
//  TransactionsHistoryViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/04/2022.
//

import UIKit
import Combine

class TransactionsHistoryViewController: UIViewController {

    // MARK: - Private Properties
    // Sub Views
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var tableView: UITableView = Self.createTableView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var emptyStateSecondaryLabel: UILabel = Self.createEmptyStateSecondaryLabel()
    private lazy var emptyStateButton: UIButton = Self.createEmptyStateButton()

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: TransactionsHistoryViewModel
    private var filterSelectedOption: Int = 0

    private let rightGradientMaskLayer = CAGradientLayer()

    // MARK: Public Properties
    var shouldReloadData: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: TransactionsHistoryViewModel = TransactionsHistoryViewModel(transactionsType: .deposit, filterApplied: .past30Days)) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        self.setupSubviews()
        self.setupWithTheme()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier) // fallback
        self.tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.identifier)

        self.tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)

        self.emptyStateButton.addTarget(self, action: #selector(self.didTapMakeDeposit), for: .primaryActionTriggered)

        self.tableView.isHidden = false
        self.emptyStateBaseView.isHidden = true

        self.viewModel.listStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] listStatePublisher in

                switch listStatePublisher {
                case .loading:
                    self?.showLoading()
                    self?.emptyStateBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .empty:
                    self?.hideLoading()
                    self?.emptyStateBaseView.isHidden = false
                    self?.tableView.isHidden = true
                case .noUserFoundError:
                    self?.hideLoading()
                    self?.emptyStateBaseView.isHidden = false
                case .serverError:
                    self?.hideLoading()
                    self?.emptyStateBaseView.isHidden = false
                case .loaded:
                    self?.hideLoading()
                    self?.emptyStateBaseView.isHidden = true
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                }

            })
            .store(in: &self.cancellables)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.emptyStateButton.layer.cornerRadius = 2.5
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateSecondaryLabel.textColor = UIColor.App.textPrimary

        self.emptyStateButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.emptyStateButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        self.emptyStateButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.emptyStateButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray

        StyleHelper.styleButton(button: self.emptyStateButton)
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: TransactionsHistoryViewModel) {

        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.title = title
            })
            .store(in: &self.cancellables)

        viewModel.shouldShowAlert = { [weak self] alertType in

            let alertMessage = alertType == .success ? localized("cancel_withdraw_success") : localized("cancel_withdraw_error")

            self?.showAlert(alertType: alertType, text: alertMessage)
        }

    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

    func reloadDataWithFilter(newFilter: FilterHistoryViewModel.FilterValue) {
        self.viewModel.filterApplied = newFilter
        self.viewModel.refreshContent()
    }

    private func showAlert(alertType: AlertType, text: String) {

        let alertView = GenericAlertView()

        alertView.configure(alertType: alertType, text: text)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            alertView.alpha = 1
        }, completion: { _ in
        })

        alertView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(alertView)

        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            alertView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                alertView.alpha = 0
            }, completion: { _ in
                alertView.removeFromSuperview()
            })
        }

        self.view.bringSubviewToFront(alertView)

        if alertType == .success {
            self.shouldReloadData?()
        }
    }

//    private func showAlert(type: AlertType) {
//        switch type {
//        case .success:
//            let alert = UIAlertController(title: localized("pending_withdrawal_cancel_success"),
//                                          message: localized("pending_withdrawal_cancel_success_message"),
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
//
//                self.shouldReloadData?()
//
//            }))
//            self.present(alert, animated: true, completion: nil)
//        case .error:
//            let alert = UIAlertController(title: localized("pending_withdrawal_cancel_error"),
//                                          message: localized("pending_withdrawal_cancel_success_message"),
//                                          preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
//        }
//
//    }

    private func showCancelConfirmationAlert(paymentId: Int) {
        let alert = UIAlertController(title: localized("cancel_withdraw"),
                                      message: localized("cancel_withdraw_description"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
            self?.viewModel.cancelPendingTransaction(paymentId: paymentId)
        }))

        alert.addAction(UIAlertAction(title: localized("go_back"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

//
// MARK: - TableView Protocols
//
extension TransactionsHistoryViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.viewModel.numberOfRows()
        switch section {
        case 0:
            return self.viewModel.numberOfRows()
        case 1:
            return self.viewModel.shouldShowLoadingCell() ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.identifier, for: indexPath) as? TransactionsTableViewCell,
                let transaction = self.viewModel.transactionForRow(atIndex: indexPath.row)
            else {
                return UITableViewCell()
            }
            
            cell.configure(withTransactionHistoryEntry: transaction, transactionType: viewModel.transactionsType)

            if self.viewModel.pendingWithdrawals.contains(where: {
                $0.paymentId == transaction.paymentId
            }) {
                cell.hasPendingTransaction = true

                cell.shouldCancelPendingTransaction = { [weak self] paymentId in

                    self?.showCancelConfirmationAlert(paymentId: paymentId)
                }
            }
            
            return cell
        case 1:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, self.viewModel.shouldShowLoadingCell() {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.viewModel.requestNextPage()

        }
    }

}

//
// MARK: - Actions
//
extension TransactionsHistoryViewController {

    @objc func didTapMakeDeposit(sender: UITapGestureRecognizer) {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
        
        self.present(navigationViewController, animated: true, completion: nil)
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension TransactionsHistoryViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        return imageView
    }

    private static func createEmptyStateButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.setTitle(localized("make_a_deposit"), for: .normal)
        return button
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("empty_transactions_history_title")
        return label
    }

    private static func createEmptyStateSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("second_empty_no_transactions")
        return label
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
        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateBaseView)
        self.view.addSubview(self.loadingBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateButton)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24),

            self.emptyStateSecondaryLabel.centerYAnchor.constraint(equalTo: self.emptyStateBaseView.centerYAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateSecondaryLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateSecondaryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.emptyStateSecondaryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.emptyStateSecondaryLabel.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 16),

            self.emptyStateButton.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateButton.heightAnchor.constraint(equalToConstant: 44),
            self.emptyStateButton.widthAnchor.constraint(equalToConstant: 250),
            self.emptyStateButton.topAnchor.constraint(equalTo: self.emptyStateSecondaryLabel.bottomAnchor, constant: 50),
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
