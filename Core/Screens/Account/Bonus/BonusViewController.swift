//
//  BonusViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2022.
//

import UIKit
import Combine

class BonusViewController: UIViewController {

    // MARK: Private Properties
    private lazy var promoCodeBaseView: UIView = Self.createPromoCodeBaseView()
    private lazy var promoCodeStackView: UIStackView = Self.createPromoCodeStackView()
    private lazy var promoCodeLabel: UILabel = Self.createPromoCodeLabel()
    private lazy var promoCodeTextFieldView: ActionTextFieldView = Self.createPromoCodeTextFieldView()
    private lazy var promoCodeLineSeparatorView: UIView = Self.createPromoCodeLineSeparatorView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    private var availableBonusEmptyViewTopConstraint = NSLayoutConstraint()
    private var otherBonusEmptyViewTopConstraint = NSLayoutConstraint()

    // MARK: Data Sources
    private var bonusAvailableDataSource = BonusAvailableDataSource()
    private var bonusActiveDataSource = BonusActiveDataSource()
    private var bonusHistoryDataSource = BonusHistoryDataSource()
    private var bonusQueuedDataSource = BonusActiveDataSource()

    // MARK: Public Properties
    var viewModel: BonusViewModel
    var redeemedBonus: ((String) -> Void)?
    var reloadAllBonusData: (() -> Void)?

    var isPromoCodeViewHidden: Bool = false {
        didSet {
            if isPromoCodeViewHidden {
                self.promoCodeBaseView.isHidden = true
            }
            else {
                self.promoCodeBaseView.isHidden = false
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            if isEmptyState {
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
            }
            else {
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
            }
            else {
                self.loadingScreenBaseView.isHidden = true
            }
        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: BonusViewModel) {
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

        self.bind(toViewModel: self.viewModel)

        self.setupPublishersAndActions()

        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.promoCodeStackView.backgroundColor = .clear
        self.promoCodeBaseView.backgroundColor = .clear
        self.promoCodeLabel.textColor = UIColor.App.textPrimary
        self.promoCodeLineSeparatorView.backgroundColor = UIColor.App.buttonTextDisablePrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Publishers and Actions
    private func setupPublishersAndActions() {
        self.promoCodeTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                if text != "" {
                    self?.promoCodeTextFieldView.isActionDisabled = false
                }
                else {
                    self?.promoCodeTextFieldView.isActionDisabled = true
                }
            })
            .store(in: &cancellables)

        self.promoCodeTextFieldView.didTapButtonAction = { [weak self] in
            print("APPLY BONUS!")
            let bonusCode = self?.promoCodeTextFieldView.getTextFieldValue() ?? ""
            self?.promoCodeTextFieldView.resignFirstResponder()
            self?.applyBonus(bonusCode: bonusCode)
        }

        self.bonusAvailableDataSource.requestBonusDetail = { [weak self] bonusIndex in
            if let bonus = self?.bonusAvailableDataSource.bonusAvailable[safe: bonusIndex] {
                if let bonusBannerUrl = self?.viewModel.bonusBannersUrlPublisher.value[bonus.bonus.code] {
                    self?.showBonusDetail(bonus: bonus.bonus, bonusBannerUrl: bonusBannerUrl)
                }
                else {
                    self?.showBonusDetail(bonus: bonus.bonus)
                }
            }
        }

        self.bonusAvailableDataSource.requestApplyBonus = { [weak self] bonusIndex in
            if let bonus = self?.bonusAvailableDataSource.bonusAvailable[safe: bonusIndex] {
                let bonusCode = bonus.bonus.code
                //self?.applyBonus(bonusCode: bonusCode)
                self?.applyAvailableBonus(bonusCode: bonusCode)
            }
        }
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: BonusViewModel) {

        switch viewModel.bonusListType {
        case .available:
            self.isPromoCodeViewHidden = false
            self.availableBonusEmptyViewTopConstraint.isActive = true
            self.otherBonusEmptyViewTopConstraint.isActive = false
        case .active:
            self.isPromoCodeViewHidden = true
            self.availableBonusEmptyViewTopConstraint.isActive = false
            self.otherBonusEmptyViewTopConstraint.isActive = true
        case .queued:
            self.isPromoCodeViewHidden = true
            self.availableBonusEmptyViewTopConstraint.isActive = false
            self.otherBonusEmptyViewTopConstraint.isActive = true
        case .history:
            self.isPromoCodeViewHidden = true
            self.availableBonusEmptyViewTopConstraint.isActive = false
            self.otherBonusEmptyViewTopConstraint.isActive = true
        }

        self.tableView.reloadData()

        viewModel.isBonusHistoryEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isBonusHistoryEmpty in
                if self?.viewModel.bonusListType == .history {
                    self?.isEmptyState = isBonusHistoryEmpty
                }
            })
            .store(in: &cancellables)

        viewModel.isBonusActiveEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isBonusActiveEmpty in
                if self?.viewModel.bonusListType == .active {
                    self?.isEmptyState = isBonusActiveEmpty
                }
            })
            .store(in: &cancellables)

        viewModel.isBonusQueuedEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isBonusQueuedEmpty in
                if self?.viewModel.bonusListType == .queued {
                    self?.isEmptyState = isBonusQueuedEmpty
                }
            })
            .store(in: &cancellables)

        viewModel.isBonusAvailableEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isBonusAvailableEmpty in
                if self?.viewModel.bonusListType == .available {
                    self?.isEmptyState = isBonusAvailableEmpty
                }
            })
            .store(in: &cancellables)

        viewModel.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest3(viewModel.isBonusApplicableLoading, viewModel.isBonusClaimableLoading, viewModel.isBonusGrantedLoading)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { isApplicableLoading, isClaimableLoading, isGrantedLoading in
                if isApplicableLoading || isClaimableLoading || isGrantedLoading {
                    self.isLoading = true
                }
                else if !isApplicableLoading && !isClaimableLoading && !isGrantedLoading {
                    self.isLoading = false
                    self.setupDataSourcesData()
                }

            })
            .store(in: &cancellables)

        viewModel.bonusBannersUrlPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bonusBanners in
                self?.bonusAvailableDataSource.bonusBannersUrl = bonusBanners
            })
            .store(in: &cancellables)

//        viewModel.shouldReloadAllBonusData
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] _ in
//                self?.showAlert(type: .success, text: "Bonus cancelled with success!")
//                self?.reloadAllBonusData?()
//            })
//            .store(in: &cancellables)

        viewModel.shouldShowAlert = { [weak self] alertType in

            switch alertType {
            case .success:
                self?.showAlert(type: .success, text: localized("bonus_cancel_success"))
                self?.reloadAllBonusData?()
            case .error:
                self?.showAlert(type: .error, text: localized("bonus_cancel_error"))

            }
        }

    }

    // MARK: Functions
    private func setupDataSourcesData() {

        self.bonusAvailableDataSource.bonusAvailable = self.viewModel.bonusAvailable
        self.bonusAvailableDataSource.bonusAvailableCellViewModels = self.viewModel.bonusAvailableCellViewModels

        self.bonusActiveDataSource.bonusActive = self.viewModel.bonusActive
        self.bonusActiveDataSource.bonusActiveCellViewModels = self.viewModel.bonusActiveCellViewModels

        self.bonusQueuedDataSource.bonusActive = self.viewModel.bonusQueued
        self.bonusQueuedDataSource.bonusActiveCellViewModels = self.viewModel.bonusQueuedCellViewModels

        self.bonusHistoryDataSource.bonusHistory = self.viewModel.bonusHistory
        self.bonusHistoryDataSource.bonusHistoryCellViewModels = self.viewModel.bonusHistoryCellViewModels

        self.tableView.reloadData()

    }

    private func showBonusDetail(bonus: ApplicableBonus, bonusBannerUrl: URL? = nil) {

        if let bonusBannerUrl = bonusBannerUrl {
            let bonusDetailViewModel = BonusDetailViewModel(bonus: bonus, bonusBannerUrl: bonusBannerUrl)
            let bonusDetailViewController = BonusDetailViewController(viewModel: bonusDetailViewModel)
            self.navigationController?.pushViewController(bonusDetailViewController, animated: true)
        }
        else {
            let bonusDetailViewModel = BonusDetailViewModel(bonus: bonus)
            let bonusDetailViewController = BonusDetailViewController(viewModel: bonusDetailViewModel)
            self.navigationController?.pushViewController(bonusDetailViewController, animated: true)
        }

    }

    private func applyBonus(bonusCode: String) {
        self.isLoading = true

        Env.servicesProvider.redeemBonus(code: bonusCode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("REDEEM BONUS ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        if message == "BONUSPLAN_NOT_FOUND" {
                            self?.showAlert(type: .error, text: localized("invalid_bonus_code"))
                            // self?.redeemedBonus?("BonusID:355")
                        }
                        else {
                            self?.showAlert(type: .error, text: localized("error_bonus_code"))
                        }
                    default:
                        ()
                    }
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] redeemBonusResponse in
                self?.showAlert(type: .success, text: localized("bonus_applied_success"))
                if let bonus = redeemBonusResponse.bonus {
                    self?.redeemedBonus?("\(bonus.id)")
                }
            })
            .store(in: &cancellables)

    }

    func applyAvailableBonus(bonusCode: String) {

        if let partyId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {

            Env.servicesProvider.redeemAvailableBonus(partyId: partyId, code: bonusCode)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in

                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("REDEEM AVAILABLE BONUS ERROR: \(error)")
                        switch error {
                        case .errorMessage(let message):
                            if message == "BONUSPLAN_NOT_FOUND" {
                                self?.showAlert(type: .error, text: localized("invalid_bonus_code"))
                            }
                            else {
                                self?.showAlert(type: .error, text: localized("error_bonus_code"))
                            }
                        default:
                            ()
                        }
                        self?.isLoading = false
                    }
                }, receiveValue: { [weak self] redeemAvailableBonusResponse in
                    self?.showAlert(type: .success, text: localized("bonus_applied_success"))
                    if let bonusMessage = redeemAvailableBonusResponse.message {
                        self?.redeemedBonus?(bonusMessage)
                    }
                })
                .store(in: &cancellables)
        }
    }

    private func showAlert(type: EditAlertView.AlertState, text: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if text != "" {
            popup.setAlertText(text)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            popup.alpha = 1
        }, completion: { _ in
        })
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                popup.alpha = 0
            }, completion: { _ in
                popup.removeFromSuperview()
            })
        }
        self.view.bringSubviewToFront(popup)
    }

}

//
// MARK: TableView Protocols
extension BonusViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.numberOfSections(in: tableView)
        case .active:
            return self.bonusActiveDataSource.numberOfSections(in: tableView)
        case .queued:
            return self.bonusQueuedDataSource.numberOfSections(in: tableView)
        case .history:
            return self.bonusHistoryDataSource.numberOfSections(in: tableView)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, viewForHeaderInSection: section)
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        switch self.viewModel.bonusListType {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .queued:
            return self.bonusQueuedDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

}

//
// MARK: - Actions
//
extension BonusViewController {

    @objc func didTapBackground() {
        self.promoCodeTextFieldView.resignFirstResponder()
    }
}

//
// MARK: Subviews initialization and setup
//
extension BonusViewController {

    private static func createPromoCodeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        return stackView
    }

    private static func createPromoCodeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPromoCodeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = localized("add_promo_code")
        return label
    }

    private static func createPromoCodeTextFieldView() -> ActionTextFieldView {
        let textFieldView = ActionTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.setPlaceholderText(placeholder: localized("bonus_code"))
        textFieldView.setActionButtonTitle(title: localized("add"))
        return textFieldView
    }

    private static func createPromoCodeLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.image = UIImage(named: "bonus_empty_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_bonus")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        return label
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.promoCodeStackView)

        self.promoCodeStackView.addArrangedSubview(self.promoCodeBaseView)

        self.promoCodeBaseView.addSubview(self.promoCodeLabel)
        self.promoCodeBaseView.addSubview(self.promoCodeTextFieldView)
        self.promoCodeBaseView.addSubview(self.promoCodeLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.view.addSubview(self.loadingScreenBaseView)

        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)

        tableView.register(BonusAvailableTableViewCell.self, forCellReuseIdentifier: BonusAvailableTableViewCell.identifier)
        tableView.register(BonusActiveTableViewCell.self, forCellReuseIdentifier: BonusActiveTableViewCell.identifier)
        tableView.register(BonusHistoryTableViewCell.self, forCellReuseIdentifier: BonusHistoryTableViewCell.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.isEmptyState = false
        self.isLoading = false

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.initConstraints()

    }

    private func initConstraints() {

        // Promo code view
        NSLayoutConstraint.activate([
            self.promoCodeStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.promoCodeStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.promoCodeStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),

            self.promoCodeBaseView.leadingAnchor.constraint(equalTo: self.promoCodeStackView.leadingAnchor),
            self.promoCodeBaseView.trailingAnchor.constraint(equalTo: self.promoCodeStackView.trailingAnchor),

            self.promoCodeLabel.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeLabel.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeLabel.topAnchor.constraint(equalTo: self.promoCodeBaseView.topAnchor, constant: 8),

            self.promoCodeTextFieldView.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeTextFieldView.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeTextFieldView.topAnchor.constraint(equalTo: self.promoCodeLabel.bottomAnchor, constant: 8),
            self.promoCodeTextFieldView.bottomAnchor.constraint(equalTo: self.promoCodeLineSeparatorView.topAnchor, constant: -20),

            self.promoCodeLineSeparatorView.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeLineSeparatorView.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.promoCodeLineSeparatorView.bottomAnchor.constraint(equalTo: self.promoCodeBaseView.bottomAnchor),
        ])

        // Table view
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.promoCodeStackView.bottomAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Empty State View
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            //self.emptyStateView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 80),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 110),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 110),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 20)

        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])

        self.availableBonusEmptyViewTopConstraint = self.emptyStateView.topAnchor.constraint(equalTo: self.promoCodeBaseView.bottomAnchor, constant: 8)

        self.otherBonusEmptyViewTopConstraint = self.emptyStateView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8)

    }

}
