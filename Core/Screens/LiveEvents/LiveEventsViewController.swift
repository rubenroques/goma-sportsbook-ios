//
//  LiveEventsViewController+Programmatic.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/03/2025.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class LiveEventsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var filtersBarBaseView: UIView = Self.createFiltersBarBaseView()
    private lazy var filtersChipsBaseView: UIView = Self.createFiltersChipsBaseView()
    private lazy var filtersSeparatorLineView: UIView = Self.createFiltersSeparatorLineView()
    private lazy var tableView: UITableView = Self.createTableView()
    
    private lazy var sportsSelectorButtonView: UIView = Self.createSportsSelectorButtonView()
    private lazy var sportTypeIconImageView: UIImageView = Self.createSportTypeIconImageView()
    private lazy var sportsSelectorExpandImageView: UIImageView = Self.createSportsSelectorExpandImageView()
    
    private lazy var sportTypeNameLabel: UILabel = Self.createSportTypeNameLabel()
    private lazy var leftGradientBaseView: UIView = Self.createLeftGradientBaseView()
    
    private lazy var rightGradientBaseView: UIView = Self.createRightGradientBaseView()
    private lazy var filtersButtonView: UIView = Self.createFiltersButtonView()
    
    private lazy var filtersCountLabel: UILabel = Self.createFiltersCountLabel()
    
    private lazy var emptyBaseView: UIView = Self.createEmptyBaseView()
    private lazy var firstTextFieldEmptyStateLabel: UILabel = Self.createFirstTextFieldEmptyStateLabel()
    private lazy var secondTextFieldEmptyStateLabel: UILabel = Self.createSecondTextFieldEmptyStateLabel()
    private lazy var emptyStateImage: UIImageView = Self.createEmptyStateImage()
    private lazy var emptyStateButton: UIButton = Self.createEmptyStateButton()
    
    private lazy var liveEventsCountView: UIView = Self.createLiveEventsCountView()
    private lazy var liveEventsCountLabel: UILabel = Self.createLiveEventsCountLabel()
    
    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()
    private let loadingSpinnerViewController = LoadingSpinnerViewController()
    
    private let footerInnerView = UIView(frame: .zero)
    
    private let refreshControl = UIRefreshControl()
    
    private var chipsTypeView: ChipsTypeView
    
    // MARK: - Public Properties
    
    var turnTimeRangeOn: Bool = false
    var isLiveEventsMarkets: Bool = true
    
    var filterSelectedOption: Int = 0
    
    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?
    
    private var viewModel: LiveEventsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: LiveEventsViewModel) {
        self.viewModel = viewModel
        self.chipsTypeView = ChipsTypeView(viewModel: self.viewModel.chipsViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupWithTheme()
        commonInit()
        connectPublishers()
        
        self.filtersCountLabel.font = AppFont.with(type: .heavy, size: 10)
        self.sportTypeNameLabel.font = AppFont.with(type: .heavy, size: 7)
        
        self.viewModel.didSelectMatchAction = { match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }
        
        self.tableView.isHidden = false
        self.emptyBaseView.isHidden = true
        
        self.viewModel.didLongPressOdd = { [weak self] bettingTicket in
            self?.openQuickbet(bettingTicket)
        }
        
        self.viewModel.resetScrollPosition = { [weak self] in
            self?.tableView.setContentOffset(.zero, animated: false)
        }
        
        self.viewModel.shouldShowSearch = { [weak self] in
            self?.showSearch()
        }
        
        self.viewModel.selectedSportPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSport in
                self?.didChangeSport?(newSport)
                
                if let sportIconImage = UIImage(named: "sport_type_icon_\(newSport.id)") {
                    self?.sportTypeIconImageView.image = sportIconImage
                    self?.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                }
                else {
                    self?.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_default")
                    self?.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                }
                
                self?.sportTypeNameLabel.text = newSport.name
            }
            .store(in: &self.cancellables)
        
        self.viewModel.didSelectCompetitionAction = { competition in
            let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
            let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
        }
        
        // New loading
        self.loadingView.alpha = 0.0
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
        self.floatingShortcutsView.resetAnimations()
        self.setHomeFilters(homeFilters: self.viewModel.homeFilterOptions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.floatingShortcutsView.resetAnimations()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.liveEventsCountView.layer.cornerRadius = self.liveEventsCountView.frame.size.width / 2
        self.filtersButtonView.layer.cornerRadius = self.filtersButtonView.frame.height / 2
        self.sportsSelectorButtonView.layer.cornerRadius = self.sportsSelectorButtonView.frame.height / 2
        
        if let footerView = self.tableView.tableFooterView {
            let size = self.footerInnerView.frame.size
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                self.tableView.tableFooterView = footerView
            }
        }
        
        // Update gradient layer frames
        if let leftMaskLayer = self.leftGradientBaseView.layer.mask as? CAGradientLayer {
            leftMaskLayer.frame = self.leftGradientBaseView.bounds
        }
        
        if let rightMaskLayer = self.rightGradientBaseView.layer.mask as? CAGradientLayer {
            rightMaskLayer.frame = self.rightGradientBaseView.bounds
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(emptyBaseView)
        view.addSubview(loadingBaseView)
        view.addSubview(filtersBarBaseView)
        
        filtersBarBaseView.addSubview(filtersChipsBaseView)
        filtersBarBaseView.addSubview(leftGradientBaseView)
        filtersBarBaseView.addSubview(rightGradientBaseView)
        filtersBarBaseView.addSubview(sportsSelectorButtonView)
        filtersBarBaseView.addSubview(filtersButtonView)
        filtersBarBaseView.addSubview(filtersSeparatorLineView)
        
        sportsSelectorButtonView.addSubview(sportTypeIconImageView)
        sportsSelectorButtonView.addSubview(sportsSelectorExpandImageView)
        sportsSelectorButtonView.addSubview(sportTypeNameLabel)
        sportsSelectorButtonView.addSubview(liveEventsCountView)
        
        liveEventsCountView.addSubview(liveEventsCountLabel)
        
        filtersButtonView.addSubview(filtersCountLabel)
        
        // Setup the empty state view hierarchy
        let emptyStateContainerView = UIView()
        emptyStateContainerView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainerView.backgroundColor = .clear
        
        emptyBaseView.addSubview(emptyStateContainerView)
        
        emptyStateContainerView.addSubview(emptyStateImage)
        emptyStateContainerView.addSubview(firstTextFieldEmptyStateLabel)
        emptyStateContainerView.addSubview(secondTextFieldEmptyStateLabel)
        emptyStateContainerView.addSubview(emptyStateButton)
        
        // Add filter icon to filters button view
        let filtersImageView = UIImageView(image: UIImage(named: "match_filters_icons"))
        filtersImageView.translatesAutoresizingMaskIntoConstraints = false
        filtersImageView.contentMode = .scaleAspectFit
        filtersButtonView.addSubview(filtersImageView)
        
        // Loading spinner
        loadingBaseView.addSubview(loadingView)
        
        // Constraints for main views
        NSLayoutConstraint.activate([
            // Filters bar
            filtersBarBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersBarBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersBarBaseView.topAnchor.constraint(equalTo: view.topAnchor),
            filtersBarBaseView.heightAnchor.constraint(equalToConstant: 70),
            
            // Table view
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty base view
            emptyBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            emptyBaseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading base view
            loadingBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            loadingBaseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading view
            loadingView.centerXAnchor.constraint(equalTo: loadingBaseView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: loadingBaseView.centerYAnchor),
            
            // Filters chips base view
            filtersChipsBaseView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            filtersChipsBaseView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            filtersChipsBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            filtersChipsBaseView.bottomAnchor.constraint(equalTo: filtersSeparatorLineView.topAnchor),
            
            // Left gradient base view
            leftGradientBaseView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            leftGradientBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            leftGradientBaseView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            leftGradientBaseView.widthAnchor.constraint(equalTo: leftGradientBaseView.heightAnchor, multiplier: 20.0/19.0),
            
            // Right gradient base view
            rightGradientBaseView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            rightGradientBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            rightGradientBaseView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            rightGradientBaseView.widthAnchor.constraint(equalToConstant: 55),
            
            // Sports selector button view
            sportsSelectorButtonView.leadingAnchor.constraint(equalTo: leftGradientBaseView.leadingAnchor),
            sportsSelectorButtonView.centerYAnchor.constraint(equalTo: filtersBarBaseView.centerYAnchor),
            sportsSelectorButtonView.heightAnchor.constraint(equalToConstant: 40),
            sportsSelectorButtonView.widthAnchor.constraint(equalToConstant: 55),
            
            // Filters button view
            filtersButtonView.trailingAnchor.constraint(equalTo: rightGradientBaseView.trailingAnchor),
            filtersButtonView.centerYAnchor.constraint(equalTo: rightGradientBaseView.centerYAnchor),
            filtersButtonView.heightAnchor.constraint(equalToConstant: 40),
            filtersButtonView.widthAnchor.constraint(equalToConstant: 40),
            
            // Separator line view
            filtersSeparatorLineView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            filtersSeparatorLineView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            filtersSeparatorLineView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            filtersSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            // Sport content holder view in sports selector button
            sportTypeIconImageView.centerXAnchor.constraint(equalTo: sportsSelectorButtonView.leadingAnchor, constant: 19.5),
            sportTypeIconImageView.topAnchor.constraint(equalTo: sportsSelectorButtonView.topAnchor, constant: 6),
            sportTypeIconImageView.widthAnchor.constraint(equalToConstant: 16),
            sportTypeIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Sport type name label
            sportTypeNameLabel.leadingAnchor.constraint(equalTo: sportsSelectorButtonView.leadingAnchor, constant: 4),
            sportTypeNameLabel.trailingAnchor.constraint(equalTo: sportsSelectorExpandImageView.leadingAnchor, constant: -2),
            sportTypeNameLabel.topAnchor.constraint(equalTo: sportTypeIconImageView.bottomAnchor, constant: 4),
            
            // Sports selector expand image view
            sportsSelectorExpandImageView.trailingAnchor.constraint(equalTo: sportsSelectorButtonView.trailingAnchor, constant: -8),
            sportsSelectorExpandImageView.centerYAnchor.constraint(equalTo: sportsSelectorButtonView.centerYAnchor, constant: 1),
            sportsSelectorExpandImageView.widthAnchor.constraint(equalToConstant: 10),
            sportsSelectorExpandImageView.heightAnchor.constraint(equalToConstant: 23),
            
            // Live events count view
            liveEventsCountView.trailingAnchor.constraint(equalTo: sportTypeIconImageView.trailingAnchor, constant: 5),
            liveEventsCountView.topAnchor.constraint(equalTo: sportTypeIconImageView.topAnchor, constant: -5),
            liveEventsCountView.widthAnchor.constraint(equalToConstant: 12),
            liveEventsCountView.heightAnchor.constraint(equalToConstant: 12),
            
            // Live events count label
            liveEventsCountLabel.centerXAnchor.constraint(equalTo: liveEventsCountView.centerXAnchor),
            liveEventsCountLabel.centerYAnchor.constraint(equalTo: liveEventsCountView.centerYAnchor),
            
            // Filters count label
            filtersCountLabel.trailingAnchor.constraint(equalTo: filtersButtonView.trailingAnchor, constant: -6),
            filtersCountLabel.topAnchor.constraint(equalTo: filtersButtonView.topAnchor, constant: -6),
            filtersCountLabel.widthAnchor.constraint(equalToConstant: 16),
            filtersCountLabel.heightAnchor.constraint(equalToConstant: 16),
            
            // Filters icon
            filtersImageView.centerXAnchor.constraint(equalTo: filtersButtonView.centerXAnchor),
            filtersImageView.centerYAnchor.constraint(equalTo: filtersButtonView.centerYAnchor),
            filtersImageView.widthAnchor.constraint(equalToConstant: 23),
            filtersImageView.heightAnchor.constraint(equalToConstant: 21),
            
            // Empty state container
            emptyStateContainerView.leadingAnchor.constraint(equalTo: emptyBaseView.leadingAnchor, constant: 8),
            emptyStateContainerView.centerXAnchor.constraint(equalTo: emptyBaseView.centerXAnchor),
            emptyStateContainerView.centerYAnchor.constraint(equalTo: emptyBaseView.centerYAnchor, constant: -16),
            
            // Empty state image
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateContainerView.topAnchor),
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateContainerView.centerXAnchor),
            
            // First text field empty state label
            firstTextFieldEmptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 12),
            firstTextFieldEmptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContainerView.leadingAnchor),
            firstTextFieldEmptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainerView.trailingAnchor),
            
            // Second text field empty state label
            secondTextFieldEmptyStateLabel.topAnchor.constraint(equalTo: firstTextFieldEmptyStateLabel.bottomAnchor, constant: 12),
            secondTextFieldEmptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContainerView.leadingAnchor),
            secondTextFieldEmptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainerView.trailingAnchor),
            
            // Empty state button
            emptyStateButton.topAnchor.constraint(equalTo: secondTextFieldEmptyStateLabel.bottomAnchor, constant: 50),
            emptyStateButton.leadingAnchor.constraint(equalTo: emptyStateContainerView.leadingAnchor, constant: 18),
            emptyStateButton.trailingAnchor.constraint(equalTo: emptyStateContainerView.trailingAnchor, constant: -18),
            emptyStateButton.heightAnchor.constraint(equalToConstant: 50),
            emptyStateButton.bottomAnchor.constraint(equalTo: emptyStateContainerView.bottomAnchor),
        ])
        
        // Add the chipsTypeView to the filtersChipsBaseView
        chipsTypeView.translatesAutoresizingMaskIntoConstraints = false
        filtersChipsBaseView.addSubview(chipsTypeView)
        
        NSLayoutConstraint.activate([
            chipsTypeView.leadingAnchor.constraint(equalTo: filtersChipsBaseView.leadingAnchor),
            chipsTypeView.trailingAnchor.constraint(equalTo: filtersChipsBaseView.trailingAnchor),
            chipsTypeView.topAnchor.constraint(equalTo: filtersChipsBaseView.topAnchor),
            chipsTypeView.bottomAnchor.constraint(equalTo: filtersChipsBaseView.bottomAnchor),
        ])
        
        // Add floating shortcuts view
        view.addSubview(floatingShortcutsView)
        NSLayoutConstraint.activate([
            floatingShortcutsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            floatingShortcutsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
        ])
    }
    
    private func commonInit() {
        self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_1")
        
        self.chipsTypeView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)
        
        let color = UIColor.App.backgroundPrimary
        
        self.leftGradientBaseView.backgroundColor = color
        let leftGradientMaskLayer = CAGradientLayer()
        leftGradientMaskLayer.frame = self.leftGradientBaseView.bounds
        leftGradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        leftGradientMaskLayer.locations = [0, 0.55, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.leftGradientBaseView.layer.mask = leftGradientMaskLayer
        
        //
        self.rightGradientBaseView.backgroundColor = color
        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = self.rightGradientBaseView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0, 0.45, 1]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.rightGradientBaseView.layer.mask = rightGradientMaskLayer
        
        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        filtersButtonView.addGestureRecognizer(tapFilterGesture)
        filtersButtonView.isUserInteractionEnabled = true
        
        filtersCountLabel.isHidden = true
        liveEventsCountView.isHidden = true
        
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        tableView.addSubview(self.refreshControl)
        
        self.tableView.separatorStyle = .none
        self.tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        
        self.tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: MatchLineTableViewCell.identifier+"Live")
        
        self.tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
        self.tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        self.tableView.register(EmptyLiveMessageBannerTableViewCell.self, forCellReuseIdentifier: EmptyLiveMessageBannerTableViewCell.identifier)
        self.tableView.register(LoadingMoreTableViewCell.self, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        self.tableView.register(FooterResponsibleGamingViewCell.self, forCellReuseIdentifier: FooterResponsibleGamingViewCell.identifier)
        self.tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        self.tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.clipsToBounds = false
        
        self.tableView.estimatedRowHeight = 155
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        
        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(handleSportsSelectionTap))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)
        
        self.view.bringSubviewToFront(self.loadingBaseView)
        
        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
        
        // New Footer view in snap to bottom
        self.footerInnerView.translatesAutoresizingMaskIntoConstraints = false
        self.footerInnerView.backgroundColor = .clear
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
        tableFooterView.backgroundColor = .clear
        
        tableView.tableFooterView = tableFooterView
        tableFooterView.addSubview(self.footerInnerView)
        
        let footerResponsibleGamingView = FooterResponsibleGamingView()
        footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false
        self.footerInnerView.addSubview(footerResponsibleGamingView)
        
        NSLayoutConstraint.activate([
            self.footerInnerView.rightAnchor.constraint(equalTo: tableFooterView.rightAnchor),
            self.footerInnerView.leftAnchor.constraint(equalTo: tableFooterView.leftAnchor),
            self.footerInnerView.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor),
            self.footerInnerView.bottomAnchor.constraint(greaterThanOrEqualTo: tableView.superview!.bottomAnchor),
            
            footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.footerInnerView.leadingAnchor, constant: 20),
            footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.footerInnerView.trailingAnchor, constant: -20),
            footerResponsibleGamingView.topAnchor.constraint(equalTo: self.footerInnerView.topAnchor, constant: 12),
            footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.footerInnerView.bottomAnchor, constant: -10),
        ])
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func connectPublishers() {
        
        self.viewModel.tableUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reloadData()
            }
            .store(in: &cancellables)
        
        self.viewModel.liveEventsCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] liveEventsCount in
                self?.liveEventsCountLabel.text = "\(liveEventsCount)"
                if liveEventsCount != 0 {
                    self?.liveEventsCountView.isHidden = false
                }
                else {
                    self?.liveEventsCountView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(self.viewModel.screenStatePublisher, self.viewModel.isLoading)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState, isLoading in
                
                if isLoading {
                    self?.loadingSpinnerViewController.startAnimating()
                    self?.loadingBaseView.isHidden = false
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = true
                    return
                }
                
                self?.refreshControl.endRefreshing()
                self?.loadingBaseView.isHidden = true
                self?.loadingSpinnerViewController.stopAnimating()
                
                switch screenState {
                case .contentNoFilter, .contentAndFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                    
                case .emptyNoFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    
                case .emptyAndFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                }
            })
            .store(in: &cancellables)
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = .clear
        
        self.chipsTypeView.backgroundColor = UIColor.App.navPills
        self.filtersChipsBaseView.backgroundColor = UIColor.App.navPills
        
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.sportsSelectorButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        self.filtersButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        self.filtersCountLabel.font = AppFont.with(type: .bold, size: 9)
        self.filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary
        self.filtersCountLabel.textColor = UIColor.App.buttonTextPrimary
        
        self.liveEventsCountLabel.font = AppFont.with(type: .semibold, size: 9)
        
        self.liveEventsCountView.backgroundColor = UIColor.App.highlightSecondary
        self.liveEventsCountLabel.textColor = UIColor.App.buttonTextPrimary
        
        // Flip the color to avoid matching
        if UIColor.App.highlightPrimary.isEqualTo(UIColor.App.highlightSecondary) {
            self.liveEventsCountView.backgroundColor = UIColor.App.buttonTextPrimary
            self.liveEventsCountLabel.textColor = UIColor.App.highlightSecondary
        }
        
        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.filtersButtonView.backgroundColor = UIColor.App.settingPill
        
        self.emptyBaseView.backgroundColor = .clear
        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
        
        self.loadingBaseView.backgroundColor = .clear
        
        self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.buttonTextPrimary
        
        self.sportsSelectorExpandImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportsSelectorExpandImageView.tintColor = UIColor.App.buttonTextPrimary
    }
    
    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(liveEventsViewModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
    }
    
    // Centralized reload data, so we can add more reload logic here in the future
    func reloadData() {
        self.tableView.reloadData()
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
    
    private func showSearch() {
        let searchViewModel = SearchViewModel()
        
        searchViewModel.isLiveSearch = true
        
        let searchViewController = SearchViewController(viewModel: searchViewModel)
        
        let navigationViewController = Router.navigationController(with: searchViewController)
        
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    func scrollToTop() {
        
        let topOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.setContentOffset(topOffset, animated: true)
        
    }
    
    @objc func handleSportsSelectionTap() {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.viewModel.selectedSport, isLiveSport: true)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }
    
    @objc func refreshControllPulled() {
        self.viewModel.fetchLiveMatches()
    }
    
    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }
    
    @objc func didTapChatView() {
        self.didTapChatButtonAction?()
    }
    
    func setEmptyStateBaseView(firstLabelText: String, secondLabelText: String, isUserLoggedIn: Bool) {
        
        if isUserLoggedIn {
            self.emptyStateImage.image = UIImage(named: "my_tickets_logged_off_icon")
            self.firstTextFieldEmptyStateLabel.text = firstLabelText
            self.secondTextFieldEmptyStateLabel.text = secondLabelText
            self.emptyStateButton.isHidden = isUserLoggedIn
        }
        else {
            self.emptyStateImage.image = UIImage(named: "no_internet_icon")
            self.firstTextFieldEmptyStateLabel.text = localized("not_logged_in")
            self.secondTextFieldEmptyStateLabel.text = localized("need_login_tickets")
            self.emptyStateButton.isHidden = isUserLoggedIn
            self.emptyStateButton.setTitle(localized("login"), for: .normal)
        }
    }
    
    func presentLoginViewController() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
}

// MARK: - Factory Methods Extension

private extension LiveEventsViewController {
    
    static func createFiltersBarBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createFiltersChipsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createFiltersSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0)
        return tableView
    }
    
    static func createSportsSelectorButtonView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createSportTypeIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sport_type_soccer_icon")
        return imageView
    }
    
    static func createSportsSelectorExpandImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "expand_top_down_arrows_icon")
        return imageView
    }
    
    static func createSportTypeNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sport"
        label.textAlignment = .center
        label.textColor = UIColor(named: "buttonTextPrimary")
        label.font = AppFont.with(type: .heavy, size: 7)
        label.numberOfLines = 2
        return label
    }
    
    static func createLeftGradientBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createRightGradientBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createFiltersButtonView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createFiltersCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = AppFont.with(type: .heavy, size: 10)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }
    
    static func createEmptyBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createFirstTextFieldEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 2
        return label
    }
    
    static func createSecondTextFieldEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.114, green: 0.122, blue: 0.145, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    static func createEmptyStateImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no_content_icon")
        return imageView
    }
    
    static func createEmptyStateButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go to popular games", for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Black", size: 18)
        return button
    }
    
    static func createLiveEventsCountView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createLiveEventsCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    
    static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let view = FloatingShortcutsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        return view
    }
    
    static func createLoadingView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(white: 0.667, alpha: 1.0)
        activityIndicator.startAnimating()
        return activityIndicator
    }
}

// MARK: - UITableView Delegate/DataSource

extension LiveEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.viewModel.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewModel.tableView(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UICollectionView Delegate/DataSource

extension LiveEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        
        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("all"))
        default:
            ()
        }
        
        if filterSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }
        
        return cell
    }
}

// MARK: - HomeFilterOptionsViewDelegate

extension LiveEventsViewController: HomeFilterOptionsViewDelegate {
    
    func setHomeFilters(homeFilters: HomeFilterOptions?) {
        self.viewModel.homeFilterOptions = homeFilters
        
        var countFilters = homeFilters?.countFilters ?? 0
        if StyleHelper.cardsStyleActive() != TargetVariables.defaultCardStyle {
            countFilters += 1
        }
        
        if countFilters != 0 {
            filtersCountLabel.isHidden = false
            self.view.bringSubviewToFront(filtersCountLabel)
            filtersCountLabel.text = String(countFilters)
            filtersCountLabel.layer.cornerRadius = filtersCountLabel.frame.width/2
            filtersCountLabel.layer.masksToBounds = true
        }
        else {
            filtersCountLabel.isHidden = true
        }
    }
}

// MARK: - SportTypeSelectionViewDelegate

extension LiveEventsViewController: SportTypeSelectionViewDelegate {
    
    func didSelectSport(_ sport: Sport) {
        self.changedSport(sport)
    }
    
    public func selectSport(_ sport: Sport) {
        self.changedSport(sport)
    }
    
    private func changedSport(_ sport: Sport) {
        self.viewModel.selectedSport(sport)
        self.didChangeSport?(sport)
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI


// For iOS 17+
@available(iOS 17.0, *)
#Preview("LiveEventsViewController", traits: .defaultLayout) {
    PreviewUIViewController {
        // Create mock data for preview
        var football = PreviewModelsHelper.createFootballSport()
        football.liveEventsCount = 12
        
        let mockViewModel = LiveEventsViewModel(selectedSport: football)
        return LiveEventsViewController(viewModel: mockViewModel)
    }
}

@available(iOS 17.0, *)
#Preview("LiveEventsViewController (Dark)", traits: .defaultLayout) {
    PreviewUIViewController {
        // Create mock data for preview
        var football = PreviewModelsHelper.createFootballSport()
        football.liveEventsCount = 12
        
        let mockViewModel = LiveEventsViewModel(selectedSport: football)
        return LiveEventsViewController(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
#endif
