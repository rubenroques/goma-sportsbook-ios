//
//  PreLiveEventsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class PreLiveEventsViewController: UIViewController {

    // MARK: - Views
    private lazy var competitionHistoryBaseView: UIView = Self.createCompetitionHistoryBaseView()
    private lazy var competitionHistoryCollectionView: UICollectionView = Self.createCompetitionHistoryCollectionView()
    private lazy var competitionHistorySeparatorLine: UIView = Self.createCompetitionHistorySeparatorLine()
    private lazy var competitionsContainerView: UIView = Self.createCompetitionsContainerView()
    private lazy var competitionsFiltersBaseView: UIView = Self.createCompetitionsFiltersBaseView()
    private lazy var competitionsFiltersDarkBackgroundView: UIView = Self.createCompetitionsFiltersDarkBackgroundView()
    private lazy var emptyBaseView: UIView = Self.createEmptyBaseView()
    private lazy var filtersBarBaseView: UIView = Self.createFiltersBarBaseView()
    private lazy var filtersButtonView: UIView = Self.createFiltersButtonView()
    private lazy var filtersCollectionView: UICollectionView = Self.createFiltersCollectionView()
    private lazy var filtersCountLabel: UILabel = Self.createFiltersCountLabel()
    private lazy var filtersSeparatorLineView: UIView = Self.createFiltersSeparatorLineView()
    private lazy var firstTextFieldEmptyStateLabel: UILabel = Self.createFirstTextFieldEmptyStateLabel()
    private lazy var leftGradientBaseView: UIView = Self.createLeftGradientBaseView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var rightGradientBaseView: UIView = Self.createRightGradientBaseView()
    private lazy var secondTextFieldEmptyStateLabel: UILabel = Self.createSecondTextFieldEmptyStateLabel()
    private lazy var sportTypeIconImageView: UIImageView = Self.createSportTypeIconImageView()
    private lazy var sportTypeNameLabel: UILabel = Self.createSportTypeNameLabel()
    private lazy var sportsSelectorButtonView: UIView = Self.createSportsSelectorButtonView()
    private lazy var sportsSelectorExpandImageView: UIImageView = Self.createSportsSelectorExpandImageView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyStateButton: UIButton = Self.createEmptyStateButton()
    private lazy var emptyStateImage: UIImageView = Self.createEmptyStateImage()
    private lazy var filtersButtonIconImageView: UIImageView = Self.createFiltersButtonIconImageView()
    private lazy var sportsSelectorContentView: UIView = Self.createSportsSelectorContentView()
    private lazy var emptyStateContentView: UIView = Self.createEmptyStateContentView()

    // Constraints
    private lazy var tableTopViewConstraint: NSLayoutConstraint = {
        return tableView.topAnchor.constraint(equalTo: competitionsContainerView.topAnchor)
    }()

    private lazy var tableFilterTopViewConstraint: NSLayoutConstraint = {
        return tableView.topAnchor.constraint(equalTo: competitionHistoryBaseView.bottomAnchor)
    }()

    private lazy var openedCompetitionsFiltersConstraint: NSLayoutConstraint = {
        return view.bottomAnchor.constraint(equalTo: self.competitionsFiltersBaseView.bottomAnchor)
    }()

    private let refreshControl = UIRefreshControl()

    var turnTimeRangeOn: Bool = false
    var isLiveEventsMarkets: Bool = false

    var floatingShortcutsBottomConstraint = NSLayoutConstraint()
    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
    }

    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    private let footerInnerView = UIView(frame: .zero)

    private var competitionsFiltersView = CompetitionsFiltersView()

    var selectedTopCompetitionIndex: Int = 0
    var reachedTopCompetitionSection: Int = 0
    var topCompetitionsHighlightEnabled: Bool = false

    var cancellables = Set<AnyCancellable>()

    var viewModel: PreLiveEventsViewModel

    var showCompetitionIndexBarView: Bool = false {
        didSet {
            self.competitionHistoryBaseView.isHidden = !showCompetitionIndexBarView
            self.tableTopViewConstraint.isActive = !showCompetitionIndexBarView
            self.tableFilterTopViewConstraint.isActive = showCompetitionIndexBarView
        }
    }

    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    private var lastContentOffset: CGFloat = 0
    private var shouldDetectScrollMovement = false

    private var isLoadingFromPullToRefresh = false

    init(viewModel: PreLiveEventsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        
        self.tableTopViewConstraint.isActive = true
        self.tableFilterTopViewConstraint.isActive = false
        
        self.competitionsFiltersView.shouldLoadCompetitions = { [weak self] regionId in
            self?.viewModel.loadCompetitionByRegion(regionId: regionId)
        }

        self.commonInit()
        self.setupWithTheme()

        self.connectPublishers()

        // Setup fonts
        self.filtersCountLabel.font = AppFont.with(type: .heavy, size: 10)
        self.sportTypeNameLabel.font = AppFont.with(type: .heavy, size: 7)

        //
        self.viewModel.didSelectMatchAction = { match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        self.viewModel.didSelectCompetitionAction = { competition in
            let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
            let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
        }

        self.viewModel.shouldShowSearch = { [weak self] in
            let searchViewModel = SearchViewModel()

            let searchViewController = SearchViewController(viewModel: searchViewModel)

            let navigationViewController = Router.navigationController(with: searchViewController)

            self?.present(navigationViewController, animated: true, completion: nil)

        }

        self.competitionsContainerView.isHidden = true

        self.emptyBaseView.isHidden = true
        self.competitionHistoryBaseView.isHidden = true

        self.competitionsContainerView.bringSubviewToFront(self.competitionHistoryBaseView)

        self.showCompetitionIndexBarView = false

        self.viewModel.didLongPressOddAction = { [weak self] bettingTicket in
            self?.openQuickbet(bettingTicket)
        }

        self.viewModel.resetScrollPositionAction = { [weak self] in
            self?.tableView.setContentOffset(.zero, animated: false)
        }

        self.topCompetitionsHighlightEnabled = false

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.floatingShortcutsView.resetAnimations()
        self.setHomeFilters(homeFilters: self.viewModel.homeFilterOptions)

        self.reloadData()
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
        self.layoutBetslipButtonPosition()

        super.viewDidLayoutSubviews()

        self.filtersButtonView.layer.cornerRadius = self.filtersButtonView.frame.height / 2
        self.sportsSelectorButtonView.layer.cornerRadius = self.sportsSelectorButtonView.frame.height / 2

        self.filtersCountLabel.layer.cornerRadius = self.filtersCountLabel.frame.width/2

        if let footerView = self.tableView.tableFooterView {
            let size = self.footerInnerView.frame.size
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                self.tableView.tableFooterView = footerView
            }
        }
    }

    private func commonInit() {

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.buttonTextPrimary

        let color = UIColor.App.backgroundPrimary

        leftGradientBaseView.backgroundColor = color
        let leftGradientMaskLayer = CAGradientLayer()
        leftGradientMaskLayer.frame = leftGradientBaseView.bounds
        leftGradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        leftGradientMaskLayer.locations = [0, 0.55, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        leftGradientBaseView.layer.mask = leftGradientMaskLayer

        //
        rightGradientBaseView.backgroundColor = color
        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = rightGradientBaseView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0, 0.45, 1]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        rightGradientBaseView.layer.mask = rightGradientMaskLayer

        filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        filtersCollectionView.backgroundColor = UIColor.App.pillNavigation

        sportsSelectorButtonView.backgroundColor = UIColor.App.highlightPrimary
        sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        filtersButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        filtersButtonView.addGestureRecognizer(tapFilterGesture)
        filtersButtonView.isUserInteractionEnabled = true

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        filtersCollectionView.collectionViewLayout = flowLayout
        filtersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)
        filtersCollectionView.showsVerticalScrollIndicator = false
        filtersCollectionView.showsHorizontalScrollIndicator = false
        filtersCollectionView.alwaysBounceHorizontal = true

        filtersCollectionView.register(ListTypeCollectionViewCell.self, forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        filtersCollectionView.register(CompetitionListIconCollectionViewCell.self,
                                       forCellWithReuseIdentifier: CompetitionListIconCollectionViewCell.identifier)

        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        // Competition History collection view
        let competitionFlowLayout = UICollectionViewFlowLayout()
        competitionFlowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        competitionFlowLayout.estimatedItemSize = CGSize(width: 100, height: 22)
        competitionFlowLayout.scrollDirection = .horizontal

        self.competitionHistoryCollectionView.collectionViewLayout = competitionFlowLayout
        self.competitionHistoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12.5, bottom: 0, right: 12.5)

        self.competitionHistoryCollectionView.showsVerticalScrollIndicator = false
        self.competitionHistoryCollectionView.showsHorizontalScrollIndicator = false
        self.competitionHistoryCollectionView.alwaysBounceHorizontal = true

        self.competitionHistoryCollectionView.register(CompetitionHistoryCollectionViewCell.self,
                                       forCellWithReuseIdentifier: CompetitionHistoryCollectionViewCell.identifier)
        self.competitionHistoryCollectionView.register(TopCompetitionCollectionViewCell.self,
                                       forCellWithReuseIdentifier: TopCompetitionCollectionViewCell.identifier)

        self.competitionHistoryCollectionView.delegate = self
        self.competitionHistoryCollectionView.dataSource = self

        filtersCountLabel.isHidden = true
        filtersCountLabel.font = AppFont.with(type: .bold, size: 10.0)
        filtersCountLabel.layer.masksToBounds = true
        filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary

        tableView.separatorStyle = .none

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier) // fallback

        tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)

        tableView.register(MatchLineTableViewCell.self, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.self, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)

        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(FooterResponsibleGamingViewCell.self, forCellReuseIdentifier: FooterResponsibleGamingViewCell.identifier)

        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.clipsToBounds = false

        tableView.estimatedRowHeight = 155
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)

        //
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
        // New Footer
        //

        //
        //
        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(self.didTapSportSelectionView))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)

        //
        //
        self.competitionsFiltersView.applyFiltersAction = { [unowned self] selectedCompetitionsIds in
            self.applyCompetitionsFiltersWithIds(selectedCompetitionsIds)
        }
        self.competitionsFiltersView.tapHeaderViewAction = { [unowned self] in
            self.openCompetitionsFilters()
        }
        self.competitionsFiltersView.didTapCompetitionNavigationAction = { [unowned self] competitionId in
            self.openCompetitionsDetails(competitionsIds: [competitionId], sport: self.viewModel.selectedSport)
        }

        self.competitionsFiltersDarkBackgroundView.alpha = 1
        self.competitionsFiltersDarkBackgroundView.backgroundColor = .black
        self.competitionsFiltersBaseView.backgroundColor = UIColor.clear
        self.competitionsFiltersBaseView.addSubview(self.competitionsFiltersView)

        NSLayoutConstraint.activate([
            self.competitionsFiltersBaseView.leadingAnchor.constraint(equalTo: self.competitionsFiltersView.leadingAnchor),
            self.competitionsFiltersBaseView.trailingAnchor.constraint(equalTo: self.competitionsFiltersView.trailingAnchor),
            self.competitionsFiltersBaseView.topAnchor.constraint(equalTo: self.competitionsFiltersView.topAnchor),
            self.competitionsFiltersBaseView.bottomAnchor.constraint(equalTo: self.competitionsFiltersView.bottomAnchor),
        ])

        // == BetslipButtonView
        self.view.addSubview(self.floatingShortcutsView)

        self.floatingShortcutsBottomConstraint = self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12)

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsBottomConstraint,
        ])

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }

        //
        // New loading
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        //
        self.view.bringSubviewToFront(self.competitionsFiltersDarkBackgroundView)
        self.view.bringSubviewToFront(self.competitionsFiltersBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)

        self.shouldDetectScrollMovement = false
        self.competitionsFiltersBaseView.isHidden = true
        self.competitionsFiltersDarkBackgroundView.isHidden = true

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func connectPublishers() {

        NotificationCenter.default.publisher(for: .cardsStyleChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &self.cancellables)

        self.viewModel.selectedSportPublisher
            .receive(on: DispatchQueue.main)
            .sink { newSelectedSport in
                if let sportIconImage = UIImage(named: "sport_type_icon_\(newSelectedSport.id)") {
                    self.sportTypeIconImageView.image = sportIconImage
                    self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                }
                else {
                    self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_default")
                    self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                }

                self.sportTypeNameLabel.text = newSelectedSport.name

                self.competitionsFiltersView.resetSelection()
            }
            .store(in: &self.cancellables)

        self.viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in

                guard let self = self else { return }

                self.reloadData()
                self.reloadCompetitionHistoryCollectionData()
            })
            .store(in: &self.cancellables)

        self.viewModel.shouldShowCompetitionsIndexBarPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.showCompetitionIndexBarView = show
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.viewModel.screenStatePublisher, self.viewModel.isLoading)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState, isLoading in
                guard let self = self else { return }

                if isLoading {
                    if !self.isLoadingFromPullToRefresh {
                        self.loadingBaseView.isHidden = false
                        self.loadingSpinnerViewController.startAnimating()
                    }

                    self.emptyBaseView.isHidden = true
                    self.competitionsContainerView.isHidden = false
                    return
                }
                else {
                    self.loadingSpinnerViewController.stopAnimating()
                    self.loadingBaseView.isHidden = true

                    self.refreshControl.endRefreshing()
                    self.isLoadingFromPullToRefresh = false
                }

                switch screenState {
                case .noEmptyNoFilter:
                    self.emptyBaseView.isHidden = true
                    self.competitionsContainerView.isHidden = false

                case .emptyNoFilter:
                    self.emptyBaseView.isHidden = false
                    self.competitionsContainerView.isHidden = true
                    self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                case .noEmptyAndFilter:
                    self.emptyBaseView.isHidden = true
                    self.competitionsContainerView.isHidden = false

                case .emptyAndFilter:
                    self.emptyBaseView.isHidden = false
                    self.competitionsContainerView.isHidden = true
                    self.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.matchListTypePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMatchListType in

                switch newMatchListType {
                case .popular:
                    self?.turnTimeRangeOn = false
                    AnalyticsClient.sendEvent(event: .popularEventsList)
                case .upcoming:
                    self?.turnTimeRangeOn = true
                    AnalyticsClient.sendEvent(event: .todayScreen)

                case .competitions:
                    self?.turnTimeRangeOn = false
                    AnalyticsClient.sendEvent(event: .competitionsScreen)

                case .topCompetitions:
                    self?.turnTimeRangeOn = false
                    AnalyticsClient.sendEvent(event: .topCompetitionsScreen)
                }

                self?.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                            secondLabelText: localized("try_something_else"),
                                            isUserLoggedIn: true)

                self?.filtersCollectionView.reloadData()
                self?.filtersCollectionView.layoutIfNeeded()

                if let newCenterIndex = self?.viewModel.activeMatchListTypes.firstIndex(of: newMatchListType) {
                    let newCenterIndexPath = IndexPath(item: newCenterIndex, section: 0)
                    self?.filtersCollectionView.scrollToItem(at: newCenterIndexPath, at: .centeredHorizontally, animated: true)
                }

            }
            .store(in: &self.cancellables)

        self.viewModel.matchListTypePublisher
            .map {  $0 == .competitions }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCompetitionTab in

                guard let self = self else { return }

                self.shouldDetectScrollMovement = isCompetitionTab
                self.competitionsFiltersBaseView.isHidden = !isCompetitionTab
                self.competitionsFiltersDarkBackgroundView.isHidden = !isCompetitionTab

                self.layoutBetslipButtonPosition()

                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(.zero, animated: true)
            }
            .store(in: &self.cancellables)

        self.viewModel.competitionGroupsPublisher
            .map { competitionGroups in
                return competitionGroups.enumerated().map { competitionGroup in
                    return CompetitionFilterSectionViewModel(index: competitionGroup.offset, competitionGroup: competitionGroup.element)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competitions in
                self?.competitionsFiltersView.competitions = competitions
            }
            .store(in: &self.cancellables)

        self.viewModel.isLoadingCompetitionGroups
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingGroups in
                self?.competitionsFiltersView.isLoading = isLoadingGroups
            })
            .store(in: &self.cancellables)

        self.competitionsFiltersView.selectedIds
            .compactMap({ $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShowOpen in
                if shouldShowOpen {
                    self?.openCompetitionsFilters()
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.hasTopCompetitionsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasTopCompetitions in

                if hasTopCompetitions {
                    if self?.viewModel.matchListType == .competitions {
                        self?.openTab(forType: .competitions)
                    }
                }
                else {
                    if self?.viewModel.matchListType == .competitions {
                        self?.openTab(forType: .competitions)
                    }
                    else if self?.viewModel.matchListType == .topCompetitions {
                        self?.openTab(forType: .upcoming)
                    }
                }

                self?.filtersCollectionView.reloadData()
            })
            .store(in: &self.cancellables)

    }

    private func setupWithTheme() {
        self.view.backgroundColor = .clear // UIColor.App.backgroundPrimary

        self.competitionsFiltersDarkBackgroundView.backgroundColor = UIColor.App.backgroundPrimary

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.filtersButtonView.backgroundColor = UIColor.App.pillSettings
        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.competitionsContainerView.backgroundColor = .clear

        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.emptyBaseView.backgroundColor = .clear
        self.loadingBaseView.backgroundColor = .clear

        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.sportsSelectorExpandImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportsSelectorExpandImageView.tintColor = UIColor.App.buttonTextPrimary

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.buttonTextPrimary

        self.competitionHistoryBaseView.backgroundColor = UIColor.App.pillNavigation

        self.competitionHistoryCollectionView.backgroundColor = .clear
    }

    private func openTab(forType type: PreLiveEventsViewModel.MatchListType) {
        self.viewModel.setMatchListType(type)
    }

    func applyCompetitionsFiltersWithIds(_ ids: [String], animated: Bool = true) {
        if ids.count > 5 {
            let alert = UIAlertController(title: "Filter limit exceeded",
                                          message: "You can only select 5 competitions at once. Please review your selections",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.viewModel.fetchCompetitionsMatchesWithIds(ids)
            self.showBottomBarCompetitionsFilters(animated: animated)
        }

    }

    func presentLoginViewController() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    func reloadData() {
        // print("BlinkDebug prelive tableView.reloadData")
        self.tableView.reloadData()
    }

    func reloadCompetitionHistoryCollectionData() {
        self.competitionHistoryCollectionView.layoutIfNeeded()
        self.competitionHistoryCollectionView.reloadData()
    }

    func openCompetitionsFilters() {

        guard
            self.viewModel.matchListTypePublisher.value == .competitions,
            competitionsFiltersView.state != .opened
        else {
            return
        }

        self.reloadData() // We need to make sure we have an updated tableview before trigger the animation

        UIView.animate(withDuration: 0.32, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.9
            self.openedCompetitionsFiltersConstraint.constant = 0
            self.tableView.contentInset.bottom = 16
            self.competitionsFiltersView.state = .opened
            self.floatingShortcutsBottomConstraint.constant = -self.tableView.contentInset.bottom
            self.view.layoutIfNeeded()
        }, completion: nil)

    }

    func showBottomBarCompetitionsFilters(animated: Bool = true) {

        if competitionsFiltersView.state == .bar {
            return
        }

        self.reloadData() // We need to make sure we have an updated tableview before trigger the animation

        UIView.animate(withDuration: animated ? 0.32 : 0.0, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(self.competitionsFiltersView.frame.size.height - 52)
            self.tableView.contentInset.bottom = 54+16
            self.competitionsFiltersView.state = .bar
            self.floatingShortcutsBottomConstraint.constant = -60
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func showBottomLineCompetitionsFilters(animated: Bool = true) {

        if competitionsFiltersView.state == .line {
            return
        }

        self.reloadData() // We need to make sure we have an updated tableview before trigger the animation

        UIView.animate(withDuration: animated ? 0.32 : 0.0, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(self.competitionsFiltersView.frame.size.height - 18)
            self.tableView.contentInset.bottom = 24
            // competitionsFiltersView.lineHeaderViewSize()
            self.competitionsFiltersView.state = .line

            self.floatingShortcutsBottomConstraint.constant = -self.tableView.contentInset.bottom

            self.view.layoutIfNeeded()
        }, completion: nil)
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

    //
    // Refresh from the RefreshControll
    @objc func refreshControllPulled() {
        self.isLoadingFromPullToRefresh = true
        self.viewModel.fetchData(forceRefresh: true)
    }

    @objc func didTapSportSelectionView() {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.viewModel.selectedSport)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(sportsModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
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
            self.emptyStateButton.setTitle("Login", for: .normal)
        }

    }

    func layoutBetslipButtonPosition() {
        var constant: CGFloat = -12
        if self.competitionsFiltersBaseView.isHidden {
            constant = -12
        }
        else if self.competitionsFiltersView.state == .opened {
            constant = -12
        }
        else if self.competitionsFiltersView.state == .bar {
            constant = -60
        }
        else if self.competitionsFiltersView.state == .line {
            constant = -24
        }
        self.floatingShortcutsBottomConstraint.constant = constant
    }

    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    private func openCompetitionsDetails(competitionsIds: [String], sport: Sport) {
        if let competitionId = competitionsIds.first {
            let competitionDetailsViewModel = SimpleCompetitionDetailsViewModel(competitionId: competitionId, sport: sport)
            let competitionDetailsViewController = SimpleCompetitionDetailsViewController(viewModel: competitionDetailsViewModel)
            self.navigationController?.pushViewController(competitionDetailsViewController, animated: true)
        }
    }

    func setHighlightedTopCompetition(section: Int) {

        if self.topCompetitionsHighlightEnabled {
            // Reset highlights on all cells
            for cell in self.competitionHistoryCollectionView.visibleCells {
                if let customCell = cell as? TopCompetitionCollectionViewCell {
                    customCell.hasHighlight = false
                }
            }
            if let cell = self.competitionHistoryCollectionView.cellForItem(at: IndexPath(row: section, section: 0)) as? TopCompetitionCollectionViewCell {

                cell.hasHighlight = true
            }
            self.reachedTopCompetitionSection = section
        }
    }

    func scrollToTop() {

        let topOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.setContentOffset(topOffset, animated: true)

    }
}

extension PreLiveEventsViewController {

    public func selectSport(_ sport: Sport) {
        self.changedSport(sport)
    }

    private func changedSport(_ sport: Sport) {
        self.viewModel.selectSport(newSport: sport)

        self.didChangeSport?(sport)

        self.openCompetitionsFilters()
    }

}

extension PreLiveEventsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !shouldDetectScrollMovement {
            return
        }

        switch scrollView.panGestureRecognizer.state {
        case .began, .changed:
            ()
        default:
            return
        }

        if self.lastContentOffset > scrollView.contentOffset.y {
            // moving up
            self.showBottomBarCompetitionsFilters()
        }
        else if self.lastContentOffset < scrollView.contentOffset.y {
            // move down
            self.showBottomLineCompetitionsFilters()
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y

    }

}

extension PreLiveEventsViewController: UITableViewDataSource, UITableViewDelegate {

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

extension PreLiveEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        switch collectionView {
        case self.competitionHistoryCollectionView:
            return 1
        case self.filtersCollectionView:
            return 1
        default:
            return 0
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch collectionView {
        case self.competitionHistoryCollectionView:
            if self.viewModel.matchListTypePublisher.value == .topCompetitions {
                return self.viewModel.getTopCompetitions().count
            }
            else {
                return self.viewModel.getCompetitions().count
            }
        case self.filtersCollectionView:
            return self.viewModel.activeMatchListTypes.count
        default:
            return 0
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Competition history collection view
        if collectionView == self.competitionHistoryCollectionView {

            if self.viewModel.matchListTypePublisher.value == .topCompetitions {

                guard
                    let cell = collectionView.dequeueCellType(TopCompetitionCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                let competition = self.viewModel.getTopCompetitions()[indexPath.row]

                cell.setupInfo(competition: competition)

                if self.topCompetitionsHighlightEnabled {
                    if self.selectedTopCompetitionIndex == indexPath.row {
                        cell.hasHighlight = true
                    }
                    else {
                        cell.hasHighlight = false
                    }
                }

                return cell

            }
            else {
                guard
                    let cell = collectionView.dequeueCellType(CompetitionHistoryCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                let competition = self.viewModel.getCompetitions()[indexPath.row]

                cell.setupInfo(competition: competition)

                cell.didTapCloseAction = { [weak self] cellCompetition in

                    if let filteredCompetitions = self?.viewModel.getCompetitions().filter({
                        $0.id != cellCompetition.id
                    }) {

                        let ids = filteredCompetitions.map({
                            $0.id
                        })

                        self?.competitionsFiltersView.updateSelectedIds(filteredIds: ids, removedCompetition: cellCompetition)

                        self?.viewModel.fetchCompetitionsMatchesWithIds(ids)

                        if ids.isEmpty {
                            self?.openCompetitionsFilters()
                        }
                    }
                }

                return cell

            }
        }
        else if collectionView == self.filtersCollectionView, let listTypeForIndexPathRow = self.viewModel.activeMatchListTypes[safe: indexPath.row] {

            switch listTypeForIndexPathRow {
            case .popular:
                guard
                    let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }
                cell.setupWithTitle(localized("popular"))
                cell.setSelectedType(self.viewModel.matchListType == listTypeForIndexPathRow)
                return cell

            case .upcoming:
                guard
                    let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }
                cell.setupWithTitle(localized("upcoming"))
                cell.setSelectedType(self.viewModel.matchListType == listTypeForIndexPathRow)
                return cell

            case .topCompetitions:
                guard
                    let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }
                cell.setupWithTitle(localized("top_competitions"))
                cell.setSelectedType(self.viewModel.matchListType == listTypeForIndexPathRow)
                return cell

            case .competitions:
                guard
                    let cell = collectionView.dequeueCellType(CompetitionListIconCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                cell.setupInfo(title: localized("competitions"), iconName: "filter_funnel_icon")
                cell.setSelectedType(self.viewModel.matchListType == listTypeForIndexPathRow)
                return cell
            }
        }

        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Competition history collection view
        if collectionView == self.competitionHistoryCollectionView {
            if self.viewModel.matchListTypePublisher.value == .topCompetitions {
                self.selectedTopCompetitionIndex = indexPath.row
                let indexPath = IndexPath(row: 0, section: indexPath.row)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            else {
                let indexPath = IndexPath(row: 0, section: indexPath.row)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }

            self.competitionHistoryCollectionView.reloadData()
            self.competitionHistoryCollectionView.layoutIfNeeded()
            self.competitionHistoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        else if collectionView == self.filtersCollectionView {
            if let typeForindex = self.viewModel.activeMatchListTypes[safe: indexPath.row] {
                self.openTab(forType: typeForindex)
            }
        }

    }

}

extension PreLiveEventsViewController: SportTypeSelectionViewDelegate {

    func didSelectSport(_ sport: Sport) {
        self.changedSport(sport)
    }

}

extension PreLiveEventsViewController: HomeFilterOptionsViewDelegate {

    func setHomeFilters(homeFilters: HomeFilterOptions?) {

        if let homeFiltersValue = homeFilters, homeFiltersValue.countFilters > 0 {
            self.viewModel.applyFilters(filtersOptions: homeFiltersValue)
        }
        else {
            // No active filters, clear viewmodel
            self.viewModel.applyFilters(filtersOptions: nil)
        }

        let homeFiltersActive = homeFilters?.countFilters ?? 0
        self.filtersCountLabel.text = String(homeFiltersActive)
        self.filtersCountLabel.isHidden = (homeFiltersActive == 0)
    }

}

// MARK: - User Interface setup
extension PreLiveEventsViewController {

    private static func createCompetitionHistoryBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        return view
    }

    private static func createCompetitionHistoryCollectionView() -> UICollectionView {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.tag = 1
        return collectionView
    }

    private static func createCompetitionHistorySeparatorLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.separatorLine
        return view
    }

    private static func createCompetitionsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }

    private static func createCompetitionsFiltersBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCompetitionsFiltersDarkBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }

    private static func createEmptyBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }

    private static func createFiltersBarBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFiltersCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }

    private static func createLeftGradientBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRightGradientBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFiltersButtonView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFiltersButtonIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "match_filters_icons"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createFiltersCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(red: 0.016, green: 0.49, blue: 1, alpha: 1)
        label.font = UIFont(name: "Roboto-Black", size: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }

    private static func createSportsSelectorButtonView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsSelectorContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createSportTypeIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "sport_type_soccer_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSportTypeNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Black", size: 7)
        label.text = "Sport"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    private static func createSportsSelectorExpandImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "expand_top_down_arrows_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyStateButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go to popular games", for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Black", size: 18)
        return button
    }

    private static func createEmptyStateImage() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "no_content_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createFirstTextFieldEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    private static func createSecondTextFieldEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .clear
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }

    private static func createFiltersSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.separatorLine
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        // Add main container views
        view.addSubview(competitionsContainerView)
        view.addSubview(filtersBarBaseView)
        view.addSubview(competitionsFiltersDarkBackgroundView)
        view.addSubview(competitionsFiltersBaseView)
        view.addSubview(emptyBaseView)
        view.addSubview(loadingBaseView)

        // Setup filters bar
        filtersBarBaseView.addSubview(filtersCollectionView)
        filtersBarBaseView.addSubview(rightGradientBaseView)
        filtersBarBaseView.addSubview(leftGradientBaseView)
        filtersBarBaseView.addSubview(filtersButtonView)
        filtersBarBaseView.addSubview(sportsSelectorButtonView)
        filtersBarBaseView.addSubview(filtersSeparatorLineView)

        // Setup filters button
        filtersButtonView.addSubview(filtersButtonIconImageView)
        filtersButtonView.addSubview(filtersCountLabel)

        // Setup sports selector
        sportsSelectorButtonView.addSubview(sportsSelectorContentView)
        sportsSelectorContentView.addSubview(sportTypeIconImageView)
        sportsSelectorContentView.addSubview(sportTypeNameLabel)
        sportsSelectorButtonView.addSubview(sportsSelectorExpandImageView)

        // Setup competitions container
        competitionsContainerView.addSubview(competitionHistoryBaseView)
        competitionHistoryBaseView.addSubview(competitionHistoryCollectionView)
        competitionHistoryBaseView.addSubview(competitionHistorySeparatorLine)
        competitionsContainerView.addSubview(tableView)

        // Setup empty state
        emptyBaseView.addSubview(emptyStateContentView)
        emptyStateContentView.addSubview(emptyStateImage)
        emptyStateContentView.addSubview(emptyStateButton)
        emptyStateContentView.addSubview(firstTextFieldEmptyStateLabel)
        emptyStateContentView.addSubview(secondTextFieldEmptyStateLabel)

        // Setup competitions filters
        competitionsFiltersView.translatesAutoresizingMaskIntoConstraints = false
        competitionsFiltersBaseView.addSubview(competitionsFiltersView)

        // Setup floating shortcuts
        view.addSubview(floatingShortcutsView)

        // Initialize the bottom constraint
        floatingShortcutsBottomConstraint = floatingShortcutsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)

        initConstraints()

        // Initial state setup
        self.competitionsFiltersDarkBackgroundView.alpha = 1
        self.competitionsFiltersDarkBackgroundView.backgroundColor = .black
        self.competitionsFiltersBaseView.backgroundColor = .clear

        self.shouldDetectScrollMovement = false
        self.competitionsFiltersBaseView.isHidden = true
        self.competitionsFiltersDarkBackgroundView.isHidden = true

        // Bring views to front in correct order
        self.view.bringSubviewToFront(self.competitionsFiltersDarkBackgroundView)
        self.view.bringSubviewToFront(self.competitionsFiltersBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Filters Bar
            filtersBarBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersBarBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersBarBaseView.topAnchor.constraint(equalTo: view.topAnchor),
            filtersBarBaseView.heightAnchor.constraint(equalToConstant: 70),

            // Filters Collection
            filtersCollectionView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            filtersCollectionView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            filtersCollectionView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            filtersCollectionView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor, constant: -1),

            // Right Gradient
            rightGradientBaseView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            rightGradientBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            rightGradientBaseView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            rightGradientBaseView.widthAnchor.constraint(equalToConstant: 55),

            // Left Gradient
            leftGradientBaseView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            leftGradientBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.topAnchor),
            leftGradientBaseView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            leftGradientBaseView.widthAnchor.constraint(equalTo: leftGradientBaseView.heightAnchor, multiplier: 20.0/19.0),

            // Filters Button
            filtersButtonView.trailingAnchor.constraint(equalTo: rightGradientBaseView.trailingAnchor),
            filtersButtonView.centerYAnchor.constraint(equalTo: rightGradientBaseView.centerYAnchor),
            filtersButtonView.widthAnchor.constraint(equalToConstant: 40),
            filtersButtonView.heightAnchor.constraint(equalToConstant: 40),

            // Filters Icon
            filtersButtonIconImageView.centerXAnchor.constraint(equalTo: filtersButtonView.centerXAnchor),
            filtersButtonIconImageView.centerYAnchor.constraint(equalTo: filtersButtonView.centerYAnchor),
            filtersButtonIconImageView.widthAnchor.constraint(equalToConstant: 23),
            filtersButtonIconImageView.heightAnchor.constraint(equalToConstant: 21),

            // Filters Count Label
            filtersCountLabel.trailingAnchor.constraint(equalTo: filtersButtonView.trailingAnchor, constant: -6),
            filtersCountLabel.topAnchor.constraint(equalTo: filtersButtonView.topAnchor, constant: -6),
            filtersCountLabel.widthAnchor.constraint(equalToConstant: 16),
            filtersCountLabel.heightAnchor.constraint(equalToConstant: 16),

            // Sports Selector Button
            sportsSelectorButtonView.leadingAnchor.constraint(equalTo: leftGradientBaseView.leadingAnchor),
            sportsSelectorButtonView.centerYAnchor.constraint(equalTo: filtersBarBaseView.centerYAnchor),
            sportsSelectorButtonView.widthAnchor.constraint(equalToConstant: 55),
            sportsSelectorButtonView.heightAnchor.constraint(equalToConstant: 40),

            // Sport Type Icon
            sportTypeIconImageView.centerXAnchor.constraint(equalTo: sportsSelectorContentView.centerXAnchor),
            sportTypeIconImageView.topAnchor.constraint(equalTo: sportsSelectorContentView.topAnchor, constant: 2),
            sportTypeIconImageView.widthAnchor.constraint(equalToConstant: 16),
            sportTypeIconImageView.heightAnchor.constraint(equalToConstant: 16),

            // Sport Type Label
            sportTypeNameLabel.topAnchor.constraint(equalTo: sportTypeIconImageView.bottomAnchor, constant: 4),
            sportTypeNameLabel.leadingAnchor.constraint(equalTo: sportsSelectorContentView.leadingAnchor),
            sportTypeNameLabel.trailingAnchor.constraint(equalTo: sportsSelectorContentView.trailingAnchor),
            sportTypeNameLabel.bottomAnchor.constraint(equalTo: sportsSelectorContentView.bottomAnchor, constant: -2),

            // Sports Selector Content View
            sportsSelectorContentView.leadingAnchor.constraint(equalTo: sportsSelectorButtonView.leadingAnchor, constant: 4),
            sportsSelectorContentView.centerYAnchor.constraint(equalTo: sportsSelectorButtonView.centerYAnchor),
            sportsSelectorContentView.trailingAnchor.constraint(equalTo: sportsSelectorExpandImageView.leadingAnchor, constant: -2),
            sportsSelectorContentView.topAnchor.constraint(equalTo: sportsSelectorButtonView.topAnchor, constant: 4),
            sportsSelectorContentView.bottomAnchor.constraint(equalTo: sportsSelectorButtonView.bottomAnchor, constant: -4),

            // Sports Selector Expand Image
            sportsSelectorExpandImageView.trailingAnchor.constraint(equalTo: sportsSelectorButtonView.trailingAnchor, constant: -8),
            sportsSelectorExpandImageView.centerYAnchor.constraint(equalTo: sportsSelectorButtonView.centerYAnchor, constant: 1),
            sportsSelectorExpandImageView.widthAnchor.constraint(equalToConstant: 10),
            sportsSelectorExpandImageView.heightAnchor.constraint(equalToConstant: 23),

            // Separator Line
            filtersSeparatorLineView.leadingAnchor.constraint(equalTo: filtersBarBaseView.leadingAnchor),
            filtersSeparatorLineView.trailingAnchor.constraint(equalTo: filtersBarBaseView.trailingAnchor),
            filtersSeparatorLineView.bottomAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            filtersSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            // Main Container
            competitionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            competitionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            competitionsContainerView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            competitionsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Competition History
            competitionHistoryBaseView.leadingAnchor.constraint(equalTo: competitionsContainerView.leadingAnchor),
            competitionHistoryBaseView.trailingAnchor.constraint(equalTo: competitionsContainerView.trailingAnchor),
            competitionHistoryBaseView.topAnchor.constraint(equalTo: competitionsContainerView.topAnchor),
            competitionHistoryBaseView.heightAnchor.constraint(equalToConstant: 42),

            // Competition History Collection
            competitionHistoryCollectionView.leadingAnchor.constraint(equalTo: competitionHistoryBaseView.leadingAnchor),
            competitionHistoryCollectionView.trailingAnchor.constraint(equalTo: competitionHistoryBaseView.trailingAnchor),
            competitionHistoryCollectionView.topAnchor.constraint(equalTo: competitionHistoryBaseView.topAnchor),
            competitionHistoryCollectionView.bottomAnchor.constraint(equalTo: competitionHistoryBaseView.bottomAnchor),

            // Competition History Separator
            competitionHistorySeparatorLine.leadingAnchor.constraint(equalTo: competitionHistoryBaseView.leadingAnchor),
            competitionHistorySeparatorLine.trailingAnchor.constraint(equalTo: competitionHistoryBaseView.trailingAnchor),
            competitionHistorySeparatorLine.bottomAnchor.constraint(equalTo: competitionHistoryBaseView.bottomAnchor),
            competitionHistorySeparatorLine.heightAnchor.constraint(equalToConstant: 1),

            // Table View
            tableView.leadingAnchor.constraint(equalTo: competitionsContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: competitionsContainerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: competitionsContainerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: competitionsContainerView.bottomAnchor),

            // Empty Base View
            emptyBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            emptyBaseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading Base View
            loadingBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingBaseView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            loadingBaseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Competitions Filters
            competitionsFiltersBaseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            competitionsFiltersBaseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            competitionsFiltersBaseView.heightAnchor.constraint(equalTo: emptyBaseView.heightAnchor, multiplier: 0.95),
            openedCompetitionsFiltersConstraint,

            // Competitions Filters View
            competitionsFiltersView.leadingAnchor.constraint(equalTo: competitionsFiltersBaseView.leadingAnchor),
            competitionsFiltersView.trailingAnchor.constraint(equalTo: competitionsFiltersBaseView.trailingAnchor),
            competitionsFiltersView.topAnchor.constraint(equalTo: competitionsFiltersBaseView.topAnchor),
            competitionsFiltersView.bottomAnchor.constraint(equalTo: competitionsFiltersBaseView.bottomAnchor),

            // Floating Shortcuts
            floatingShortcutsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            floatingShortcutsBottomConstraint,

            // Dark Background
            competitionsFiltersDarkBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            competitionsFiltersDarkBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            competitionsFiltersDarkBackgroundView.topAnchor.constraint(equalTo: filtersBarBaseView.bottomAnchor),
            competitionsFiltersDarkBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Empty State Content View
            emptyStateContentView.leadingAnchor.constraint(equalTo: emptyBaseView.leadingAnchor, constant: 8),
            emptyStateContentView.centerXAnchor.constraint(equalTo: emptyBaseView.centerXAnchor),
            emptyStateContentView.centerYAnchor.constraint(equalTo: emptyBaseView.centerYAnchor, constant: -16),

            // Empty State Image
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateContentView.centerXAnchor),
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateContentView.topAnchor),

            // Empty State Labels
            firstTextFieldEmptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 12),
            firstTextFieldEmptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContentView.leadingAnchor, constant: 22),
            firstTextFieldEmptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContentView.trailingAnchor, constant: -22),

            secondTextFieldEmptyStateLabel.topAnchor.constraint(equalTo: firstTextFieldEmptyStateLabel.bottomAnchor, constant: 12),
            secondTextFieldEmptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContentView.leadingAnchor, constant: 22),
            secondTextFieldEmptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContentView.trailingAnchor, constant: -22),

            // Empty State Button
            emptyStateButton.topAnchor.constraint(equalTo: secondTextFieldEmptyStateLabel.bottomAnchor, constant: 50),
            emptyStateButton.leadingAnchor.constraint(equalTo: emptyStateContentView.leadingAnchor),
            emptyStateButton.trailingAnchor.constraint(equalTo: emptyStateContentView.trailingAnchor),
            emptyStateButton.heightAnchor.constraint(equalToConstant: 50),
            emptyStateButton.bottomAnchor.constraint(equalTo: emptyStateContentView.bottomAnchor)
        ])
    }
}
