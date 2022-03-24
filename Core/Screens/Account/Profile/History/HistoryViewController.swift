//
//  HistoryViewController.swift
//  ShowcaseProd
//
//  Created by Teresa on 14/02/2022.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class HistoryViewController: UIViewController {
    
    // MARK: - Private Properties
    // Sub Views
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var optionSegmentControlBaseView: UIView = Self.createSimpleView()
    private lazy var optionSegmentControl: UISegmentedControl = Self.createSegmentedControl()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var topSliderSeparatorView: UIView = Self.createSimpleView()
    private lazy var topSliderView: UIView = Self.createSimpleView()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var filterBaseView: UIView = Self.createSimpleView()
    private lazy var filtersButtonImage: UIImageView = Self.createFilterImageView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: SpinnerViewController = SpinnerViewController()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createImageView()
    private lazy var emptyStateLabel: UILabel = Self.createTopLabel()
    private lazy var emptyStateSecondaryLabel: UILabel = Self.createTopLabel()
    private lazy var emptyStateButton: UIButton = Self.createButton()
    
    private lazy var leftGradientBaseView: UIView = Self.createSimpleView()
    private lazy var rightGradientBaseView: UIView = Self.createSimpleView()
    
    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HistoryViewModel
    private var filterSelectedOption: Int = 0
    
    private let rightGradientMaskLayer = CAGradientLayer()
    
    // MARK: - Lifetime and Cycle
    init(viewModel: HistoryViewModel = HistoryViewModel()) {
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
        
        // Configure post-loading and self-dependent properties
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.bottom = 12
        
        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib, forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        
        self.tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.identifier)
        self.tableView.register(BettingsTableViewCell.self, forCellReuseIdentifier: BettingsTableViewCell.identifier)
        
        self.view.bringSubviewToFront(self.loadingBaseView.view)
        
        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        self.filterBaseView.addGestureRecognizer(tapFilterGesture)
        self.filterBaseView.isUserInteractionEnabled = true
        self.filterBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let tapDepositGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapMakeDeposit))
        self.emptyStateButton.isUserInteractionEnabled = true
        self.emptyStateButton.addGestureRecognizer(tapDepositGestureRecognizer)
        StyleHelper.styleButton(button: self.emptyStateButton)
        
        self.optionSegmentControl.addTarget(self, action: #selector(self.didChangeSegmentValue(_:)), for: .valueChanged)
        
        if filterSelectedOption == 0 {
            self.viewModel.ticketsTypePublisher.send(.resolved)
            
        }
        
        let color = UIColor.App.backgroundPrimary
        self.rightGradientBaseView.backgroundColor = color
        self.rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        self.rightGradientMaskLayer.locations = [0, 0.45, 1]
        self.rightGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.rightGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.rightGradientBaseView.layer.mask = self.rightGradientMaskLayer
        
        self.loadingBaseView.view.isHidden = true
        self.tableView.isHidden = false
        self.emptyStateBaseView.isHidden = true
        self.bind(toViewModel: viewModel)
        
    }
    
    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.filterBaseView.layer.cornerRadius = self.filterBaseView.frame.height / 2
        
        self.rightGradientMaskLayer.frame = self.rightGradientBaseView.bounds
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        
        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.topSliderSeparatorView.backgroundColor = UIColor.App.separatorLine
                
        self.topSliderCollectionView.backgroundView?.backgroundColor = .clear
        self.topSliderCollectionView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.topLabel.textColor = UIColor.App.textPrimary
        
        self.filterBaseView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .selected)
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary
        ], for: .normal)
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary.withAlphaComponent(0.5)
        ], for: .disabled)
        
        self.optionSegmentControl.selectedSegmentTintColor = UIColor.App.highlightPrimary
        self.optionSegmentControl.backgroundColor = UIColor.App.backgroundTertiary
        
        self.emptyStateBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.emptyStateImageView.image = UIImage(named: "no_content_icon")
        
        self.emptyStateLabel.font = AppFont.with(type: .bold, size: 22)
        self.emptyStateSecondaryLabel.font = AppFont.with(type: .bold, size: 16)
        
        self.emptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateSecondaryLabel.textColor = UIColor.App.textPrimary
        
        self.emptyStateLabel.numberOfLines = 4
        self.emptyStateSecondaryLabel.numberOfLines = 4
        
        self.emptyStateLabel.textAlignment = .center
        self.emptyStateSecondaryLabel.textAlignment = .center
        
        self.emptyStateButton.layer.cornerRadius = 2.5
        
        self.emptyStateButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        
    }
    
    // MARK: - Bindings
    private func bind(toViewModel viewModel: HistoryViewModel) {
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                if isLoading {
                    self?.emptyStateBaseView.isHidden = true
                    self?.loadingBaseView.view.isHidden = false
                    self?.tableView.isHidden = true
                }
                else {
                    self?.viewModel.listTypePublisher.send(.transactions)
                    self?.viewModel.transactionsTypePublisher.send(.deposit)
                    if let numberOfRows = self?.viewModel.numberOfRowsInTable() {
                        if numberOfRows == 0 {
                            self?.loadingBaseView.view.isHidden = true
                            self?.emptyStateBaseView.isHidden = false
                        }
                        else {
                            self?.loadingBaseView.view.isHidden = true
                            self?.tableView.isHidden = false
                            self?.emptyStateBaseView.isHidden = true
                            self?.tableView.reloadData()
                        }
                    }
                }
                
            })
            .store(in: &self.cancellables)
    }
    
}

//
// MARK: - TableView Protocols
//
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.viewModel.numberOfRowsInTable() == 0 {
            self.emptyStateBaseView.isHidden = false
            self.tableView.isHidden = true
            
            self.setupEmptyState()
        }
        else {
            self.emptyStateBaseView.isHidden = true
            self.tableView.isHidden = false
        }
        return self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInTable()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.viewModel.listTypePublisher.value {
        case .transactions:
            let ticket: EveryMatrix.TransactionHistory?
            switch self.viewModel.transactionsTypePublisher.value {
            case .deposit:
                ticket = self.viewModel.deposits.value[safe: indexPath.row] ?? nil
            case .withdraw:
                ticket = self.viewModel.deposits.value[safe: indexPath.row] ?? nil
            }
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.identifier, for: indexPath) as? TransactionsTableViewCell,
                let ticketValue = ticket
            else {
                fatalError("")
            }
            
            cell.configure(withTransactionHistoryEntry: ticketValue, transactionType: viewModel.transactionsTypePublisher.value)
            return cell
            
        case .bettings:
            let ticket: BetHistoryEntry?
            
            switch self.viewModel.ticketsTypePublisher.value {
            case .cashout:
                ticket =  self.viewModel.cashoutTickets.value[safe: indexPath.row] ?? nil
            case .resolved:
                ticket = self.viewModel.resolvedTickets.value[safe: indexPath.row] ?? nil
            case .opened:
                ticket =  self.viewModel.openedTickets.value[safe: indexPath.row] ?? nil
            case .won:
                ticket =  self.viewModel.wonTickets.value[safe: indexPath.row] ?? nil
            }
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BettingsTableViewCell.identifier, for: indexPath) as? BettingsTableViewCell,
                let ticketValue = ticket
            else {
                fatalError("")
            }
            
            cell.configure(withBetHistoryEntry: ticketValue)
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch self.viewModel.listTypePublisher.value {
        case .transactions:
            return 80
        case .bettings:
            return 130
        }
        
    }
    
}

//
// MARK: - CollectionView Protocols
//

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfShortcuts(forSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        cell.setupWithTitle( self.viewModel.shortcutTitle(forIndex: indexPath.row) ?? "")
    
        if filterSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.filterSelectedOption = indexPath.row
        
        if self.optionSegmentControl.selectedSegmentIndex == 0 {
            self.viewModel.listTypePublisher.send(.transactions)
            
            if indexPath.row == 0 {
                self.viewModel.transactionsTypePublisher.send(.deposit)
            }
            else {
                self.viewModel.transactionsTypePublisher.send(.withdraw)
            }
        }
        else {
            if indexPath.row == 0 {
                
                self.viewModel.ticketsTypePublisher.send(.resolved)
            }
            else if indexPath.row == 1 {
                
                self.viewModel.ticketsTypePublisher.send(.opened)
                self.viewModel.loadOpenedTickets(page: 0)
            }
            else if indexPath.row == 2 {
                
                self.viewModel.ticketsTypePublisher.send(.won)
                self.viewModel.loadWonTickets(page: 0)
            }
            else if indexPath.row == 3 {
                
                self.viewModel.ticketsTypePublisher.send(.cashout)
            }
            self.viewModel.listTypePublisher.send(.bettings)
        }
        
        self.viewModel.didSelectShortcut(atSection: indexPath.section)
        
        self.topSliderCollectionView.reloadData()
        self.tableView.reloadData()
        self.topSliderCollectionView.layoutIfNeeded()
        self.topSliderCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
}

//
// MARK: - Actions
//
extension HistoryViewController {
  
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        // print("clicou nos filtros")
    }
    
    @objc func didTapMakeDeposit(sender: UITapGestureRecognizer) {
        let depositViewController = Router.navigationController(with: DepositViewController())
        self.present(depositViewController, animated: true, completion: nil)
    }

    @objc func didChangeSegmentValue(_ sender: UISegmentedControl) {
        if self.optionSegmentControl.selectedSegmentIndex == 0 {
            self.viewModel.listTypePublisher.send(.transactions)
            self.viewModel.transactionsTypePublisher.send(.deposit)
        }
        else {
            self.viewModel.listTypePublisher.send(.bettings)
            self.viewModel.ticketsTypePublisher.send(.resolved)
            self.tableView.reloadData()
        }
        
        self.filterSelectedOption = 0
        
        self.tableView.reloadData()
        self.topSliderCollectionView.reloadData()
        
    }
    
}

//
// MARK: - Subviews Initialization and Setup
//
extension HistoryViewController {
    
    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFilterImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "match_filters_icons")
        
        return imageView
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    private static func createSegmentedControl() -> UISegmentedControl {
        let segment = UISegmentedControl(items: ["Transactions", "Betting"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }
    
    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.text = localized("history")
        label.font = AppFont.with(type: .bold, size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }
    
    private static func createTopSliderCollectionView() -> UICollectionView {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        return collectionView
    }
    
    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }
    
    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.enableButton()
        
        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        button.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        
        return button
    }
    
    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }
    
    private func setupEmptyState() {
    
        switch self.viewModel.listTypePublisher.value {
        case .transactions:
            
            self.emptyStateLabel.text = "There’s no transations here!"
            self.emptyStateSecondaryLabel.text = "You haven’t made a transation yet, it’s time to deposit some money and start betting on your favourites."
            
            self.emptyStateButton.setTitle("Make a deposit", for: .normal)
            self.emptyStateButton.setTitle("Make a deposit", for: .disabled)
            
        case .bettings:
            self.emptyStateLabel.text = "There’s no bets here!"
            self.emptyStateSecondaryLabel.text = "You haven’t made a bet yet, it’s time to bet on your favourites."
            
            self.emptyStateButton.setTitle("Go to popular games", for: .normal)
            self.emptyStateButton.setTitle("Go to popular games", for: .disabled)
            
        }
        
    }
    
    private func setupSubviews() {
        
        // Add subviews to self.view or each other
        self.navigationBaseView.addSubview(self.topLabel)
        self.navigationBaseView.addSubview(self.backButton)
        
        self.view.addSubview(self.navigationBaseView)
        
        self.optionSegmentControlBaseView.addSubview(self.optionSegmentControl)
        
        self.view.addSubview(self.optionSegmentControlBaseView)
        
        self.topSliderView.addSubview(self.topSliderCollectionView)
        self.topSliderView.addSubview(self.rightGradientBaseView)
        self.topSliderView.addSubview(self.filterBaseView)
        
        self.filterBaseView.addSubview(self.filtersButtonImage)
        
        self.view.addSubview(self.topSliderView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.loadingBaseView.view)
        
        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateButton)
        self.view.addSubview(self.emptyStateBaseView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 44),

            self.topLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.topLabel.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            
        ])
        
        NSLayoutConstraint.activate([
            
            self.optionSegmentControlBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.optionSegmentControlBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.optionSegmentControlBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.optionSegmentControlBaseView.heightAnchor.constraint(equalToConstant: 70),
            
            self.optionSegmentControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.optionSegmentControl.centerYAnchor.constraint(equalTo: self.optionSegmentControlBaseView.centerYAnchor),
            self.optionSegmentControl.centerXAnchor.constraint(equalTo: self.optionSegmentControlBaseView.centerXAnchor),
            
        ])
    
        NSLayoutConstraint.activate([
            
            self.topSliderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSliderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSliderView.topAnchor.constraint(equalTo: self.optionSegmentControlBaseView.bottomAnchor),
            self.topSliderView.heightAnchor.constraint(equalToConstant: 70),
            
            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.topSliderView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topSliderView.topAnchor),
            self.topSliderCollectionView.bottomAnchor.constraint(equalTo: self.topSliderView.topAnchor, constant: 70),
            
            self.filterBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.heightAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            self.filterBaseView.centerYAnchor.constraint(equalTo: self.topSliderCollectionView.centerYAnchor),
            
            self.filtersButtonImage.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor, constant: -8),
            self.filtersButtonImage.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor, constant: 8),
            self.filtersButtonImage.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor, constant: -6),
            self.filtersButtonImage.centerYAnchor.constraint(equalTo: self.filterBaseView.centerYAnchor),
            
            self.rightGradientBaseView.widthAnchor.constraint(equalToConstant: 55),
            self.rightGradientBaseView.topAnchor.constraint(equalTo: self.topSliderView.topAnchor),
            self.rightGradientBaseView.bottomAnchor.constraint(equalTo: self.topSliderView.bottomAnchor),
            self.rightGradientBaseView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.topSliderView.bottomAnchor, constant: 8),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    
        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.topSliderView.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.topSliderView.bottomAnchor, constant: 4),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateBaseView.topAnchor, constant: 30),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),
            
            self.emptyStateLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 16),
            
            self.emptyStateSecondaryLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateSecondaryLabel.leadingAnchor.constraint(equalTo: self.topSliderView.leadingAnchor, constant: 16),
            self.emptyStateSecondaryLabel.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor, constant: -16),
            self.emptyStateSecondaryLabel.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 16),
            
            self.emptyStateButton.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateButton.heightAnchor.constraint(equalToConstant: 40),
            self.emptyStateButton.widthAnchor.constraint(equalToConstant: 250),
            self.emptyStateButton.topAnchor.constraint(equalTo: self.emptyStateSecondaryLabel.bottomAnchor, constant: 50),
            
        ])
    }
    
}
