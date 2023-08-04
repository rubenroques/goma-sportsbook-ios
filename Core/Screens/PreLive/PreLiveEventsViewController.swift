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

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var sportsSelectorButtonView: UIView!
    @IBOutlet private weak var sportsSelectorExpandImageView: UIImageView!
    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var leftGradientBaseView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!

    @IBOutlet private weak var emptyBaseView: UIView!
    @IBOutlet private weak var filtersCountLabel: UILabel!
    @IBOutlet private weak var firstTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var secondTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var emptyStateImage: UIImageView!
    @IBOutlet private weak var emptyStateButton: UIButton!

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

    @IBOutlet private weak var loadingBaseView: UIView!
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    @IBOutlet private weak var openedCompetitionsFiltersConstraint: NSLayoutConstraint!
    @IBOutlet private weak var competitionsFiltersBaseView: UIView!
    @IBOutlet private weak var competitionsFiltersDarkBackgroundView: UIView!

    @IBOutlet private weak var competitionsContainerView: UIView!

    @IBOutlet private weak var competitionHistoryBaseView: UIView!

    @IBOutlet private weak var competitionHistoryCollectionView: UICollectionView!

    // Constraints

    @IBOutlet private weak var tableTopViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableFilterTopViewConstraint: NSLayoutConstraint!

    private var competitionsFiltersView: CompetitionsFiltersView = CompetitionsFiltersView()

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

        super.init(nibName: "PreLiveEventsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.competitionsFiltersView.shouldLoadCompetitions = { [weak self] regionId in
            self?.viewModel.loadCompetitionByRegion(regionId: regionId)
        }

        self.commonInit()
        self.setupWithTheme()

        self.connectPublishers()

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
    }

    private func commonInit() {

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.textPrimary

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

        sportsSelectorButtonView.backgroundColor = UIColor.App.pillSettings
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

        filtersCollectionView.register(ListTypeCollectionViewCell.nib, forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

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

        tableView.register(OutrightCompetitionLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLineTableViewCell.identifier)
        tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)

        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib,
                           forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(FooterResponsibleGamingViewCell.self,
                           forCellReuseIdentifier: FooterResponsibleGamingViewCell.identifier)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.identifier)

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
        // ==
        let footerResponsibleGamingView = FooterResponsibleGamingView()
        footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false

        self.emptyBaseView.addSubview(footerResponsibleGamingView)

        NSLayoutConstraint.activate([
            footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.emptyBaseView.leadingAnchor),
            footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.emptyBaseView.trailingAnchor),
            footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.emptyBaseView.bottomAnchor),
        ])

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
                    self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
                }
                else {
                    self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_default")
                    self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
                }
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

        self.sportsSelectorExpandImageView.setImageColor(color: UIColor.App.textPrimary)
        self.sportsSelectorExpandImageView.tintColor = UIColor.App.textPrimary

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.textPrimary

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

            self.present(quickbetViewController, animated: true)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
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
            self.emptyStateImage.image = UIImage(named: "no_content_icon")
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

        if self.viewModel.matchListTypePublisher.value == .topCompetitions {

            // Reached section
            if self.viewModel.matchListTypePublisher.value == .topCompetitions {

                for section in 0..<tableView.numberOfSections - 1 {

                    let headerRect = tableView.rectForHeader(inSection: section)
                    let contentOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top

                    let currentContentOffsetY = scrollView.contentOffset.y

                    let maximumOffsetY = scrollView.contentSize.height - scrollView.frame.height

                    if headerRect.origin.y <= contentOffsetY && contentOffsetY < headerRect.maxY {

                        print("Reached section:", section)

                        if self.reachedTopCompetitionSection != section {

                            self.setHighlightedTopCompetition(section: section)

                        }
                    }
                    else if currentContentOffsetY >= maximumOffsetY && currentContentOffsetY != 0 {

                        print("Reached the end of the table view scroll - \(currentContentOffsetY)")

                        let lastSection = self.tableView.numberOfSections - 2

                        if self.reachedTopCompetitionSection != lastSection {

                            self.setHighlightedTopCompetition(section: lastSection)

                        }

                    }

                }

            }
        }

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
