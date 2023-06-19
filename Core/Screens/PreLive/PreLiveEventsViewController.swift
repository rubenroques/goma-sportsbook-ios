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
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    @IBOutlet private weak var openedCompetitionsFiltersConstraint: NSLayoutConstraint!
    @IBOutlet private weak var competitionsFiltersBaseView: UIView!
    @IBOutlet private weak var competitionsFiltersDarkBackgroundView: UIView!

    private var competitionsFiltersView: CompetitionsFiltersView = CompetitionsFiltersView()

    var cancellables = Set<AnyCancellable>()

    var viewModel: PreLiveEventsViewModel

    var filterSelectedOption: Int = 0
    var selectedSport: Sport {
        didSet {
            if oldValue.id == selectedSport.id {
                return
            }

            if let sportIconImage = UIImage(named: "sport_type_icon_\( selectedSport.id)") {
                self.sportTypeIconImageView.image = sportIconImage
                self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
            }
            else {
                self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_default")
                self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
            }

            self.competitionsFiltersView.resetSelection()
            self.viewModel.selectedSport = selectedSport
        }
    }

    var openScreenOnCompetition: String?

    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    private var lastContentOffset: CGFloat = 0
    private var shouldDetectScrollMovement = false

    var selectedShortcutItem: Int = 0 {
        didSet {
            let indexPath = IndexPath(item: selectedShortcutItem, section: 0)

            self.filterSelectedOption = selectedShortcutItem

            AnalyticsClient.sendEvent(event: .competitionsScreen)
            self.viewModel.setMatchListType(.competitions)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)

            self.filtersCollectionView.reloadData()
            self.filtersCollectionView.layoutIfNeeded()
            self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    init(selectedSportType: Sport) {
        self.selectedSport = selectedSportType
        self.viewModel = PreLiveEventsViewModel(selectedSport: self.selectedSport)
        super.init(nibName: "PreLiveEventsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.competitionsFiltersView.shouldLoadCompetitions = { [weak self] regionId in
            print("REGION ID CLICKED: \(regionId)")
            self?.viewModel.loadCompetitionByRegion(regionId: regionId)
        }

        self.commonInit()
        self.setupWithTheme()

        self.connectPublishers()
        self.viewModel.fetchData()

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

        self.tableView.isHidden = false
        self.emptyBaseView.isHidden = true

        self.viewModel.didLongPressOddAction = { [weak self] bettingTicket in
            self?.openQuickbet(bettingTicket)
        }

        self.viewModel.resetScrollPositionAction = { [weak self] in
            self?.tableView.setContentOffset(.zero, animated: false)
        }
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

        if let sportIconImage = UIImage(named: "sport_type_mono_icon_\( selectedSport.id)") {
            self.sportTypeIconImageView.image = sportIconImage
        }
        else {
            self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_default")
        }

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
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

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
        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(self.handleSportsSelectionTap(_:)))
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

        // ==

        let footerResponsibleGamingView = FooterResponsibleGamingView()
        footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false

        self.emptyBaseView.addSubview(footerResponsibleGamingView)

        NSLayoutConstraint.activate([
            footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.emptyBaseView.leadingAnchor),
            footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.emptyBaseView.trailingAnchor),
            footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.emptyBaseView.bottomAnchor),
        ])

        // New loading
        self.loadingView.alpha = 0.0
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        //
        self.view.bringSubviewToFront(self.competitionsFiltersDarkBackgroundView)
        self.view.bringSubviewToFront(self.competitionsFiltersBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)
        self.view.bringSubviewToFront(self.filtersCountLabel)

        self.shouldDetectScrollMovement = false
        self.competitionsFiltersBaseView.isHidden = true
        self.competitionsFiltersDarkBackgroundView.isHidden = true

        if let openScreenOnCompetition = openScreenOnCompetition {
            self.competitionsFiltersView.selectIds([openScreenOnCompetition])
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func connectPublishers() {

        NotificationCenter.default.publisher(for: .cardsStyleChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &cancellables)

//        self.viewModel.isLoading
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isLoading in
//                self?.loadingBaseView.isHidden = !isLoading
//                if !isLoading {
//                    self?.refreshControl.endRefreshing()
//                }
//            }
//            .store(in: &cancellables)

//        self.viewModel.isLoadingEvents
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] isLoadingEvents in
//
//            })
//            .store(in: &cancellables)

        self.viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadData()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.viewModel.screenStatePublisher, self.viewModel.isLoadingEvents)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState, isLoadingEvents in

                if isLoadingEvents {
                    self?.loadingBaseView.isHidden = false
                    self?.loadingSpinnerViewController.startAnimating()

                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                    return
                }
                else {
                    self?.loadingSpinnerViewController.stopAnimating()

                    self?.loadingBaseView.isHidden = true

                    self?.refreshControl.endRefreshing()
                }

                switch screenState {
                case .noEmptyNoFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false

                case .emptyNoFilter:
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    self?.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                case .noEmptyAndFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false

                case .emptyAndFilter:
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"),
                                                secondLabelText: localized("try_something_else"),
                                                isUserLoggedIn: true)
                }
            })
            .store(in: &cancellables)

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
            .store(in: &cancellables)

        self.viewModel.competitionGroupsPublisher
            .map { competitionGroups in
                competitionGroups
                    .enumerated()
                    .map {
                        CompetitionFilterSectionViewModel(index: $0.offset, competitionGroup: $0.element)
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competitions in
                self?.competitionsFiltersView.competitions = competitions
            }
            .store(in: &cancellables)

        self.viewModel.isLoadingCompetitionGroups
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingGroups in
                self?.competitionsFiltersView.isLoading = isLoadingGroups
            })
            .store(in: &cancellables)

        self.competitionsFiltersView.selectedIds
            .compactMap({ $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShowOpen in
                if shouldShowOpen {
                    self?.openCompetitionsFilters()
                }
            })
            .store(in: &cancellables)

    }

    @objc func refreshControllPulled() {
        self.viewModel.fetchData()
    }

    @objc func handleSportsSelectionTap(_ sender: UITapGestureRecognizer? = nil) {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.selectedSport)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }

    private func setupWithTheme() {
        self.view.backgroundColor = .clear // UIColor.App.backgroundPrimary

        self.competitionsFiltersDarkBackgroundView.backgroundColor = UIColor.App.backgroundPrimary

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.filtersButtonView.backgroundColor = UIColor.App.pillSettings
        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine

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
    }

    private func openTab(atIndex index: Int) {
        self.filterSelectedOption = index

        switch index {
        case 0:
            AnalyticsClient.sendEvent(event: .myGamesScreen)
            self.viewModel.setMatchListType(.popular)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
        case 1:
            AnalyticsClient.sendEvent(event: .todayScreen)
            self.viewModel.setMatchListType(.upcoming)
            turnTimeRangeOn = true
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
        case 2:
            AnalyticsClient.sendEvent(event: .competitionsScreen)
            self.viewModel.setMatchListType(.competitions)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
        default:
            ()
        }

        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.layoutIfNeeded()

        let indexPath = IndexPath(item: index, section: 0)
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func openPopularTab() {
        self.openTab(atIndex: 0)
    }

    func openUpcomingTab() {
        self.openTab(atIndex: 1)
    }

    func openCompetitionTab(withId id: String) {
        self.applyCompetitionsFiltersWithIds([id], animated: false)
        self.openTab(atIndex: 2)
    }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(sportsModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
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

    func changedSport(_ sport: Sport) {
        self.selectedSport = sport
        self.didChangeSport?(sport)

        self.openCompetitionsFilters()
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

extension PreLiveEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("popular"))
        case 1:
            cell.setupWithTitle(localized("upcoming"))
        case 2:
            cell.setupWithTitle(localized("competitions"))
//        case 3:
//            cell.setupWithTitle(localized("my_games"))
//        case 4:
//            cell.setupWithTitle(localized("my_competitions"))
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.filterSelectedOption = indexPath.row

        switch indexPath.row {
        case 0:
            AnalyticsClient.sendEvent(event: .myGamesScreen)
            self.viewModel.setMatchListType(.popular)
            self.turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
        case 1:
            AnalyticsClient.sendEvent(event: .todayScreen)
            self.viewModel.setMatchListType(.upcoming)
            self.turnTimeRangeOn = true
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
        case 2:
            AnalyticsClient.sendEvent(event: .competitionsScreen)
            self.viewModel.setMatchListType(.competitions)
            self.turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("no_results_for_selection"),
                                       secondLabelText: localized("try_something_else"),
                                       isUserLoggedIn: true)
//        case 3:
//            self.viewModel.setMatchListType(.favoriteGames)
//            self.setEmptyStateBaseView(firstLabelText: localized("empty_my_games"),
//                                       secondLabelText: localized("go_to_list_to_mark"),
//                                       isUserLoggedIn: Env.userSessionStore.isUserLogged())
//        case 4:
//            self.viewModel.setMatchListType(.favoriteCompetitions)
//            self.setEmptyStateBaseView(firstLabelText: localized("empty_my_competitions"),
//                                       secondLabelText: localized("second_empty_my_competitions"),
//                                       isUserLoggedIn: Env.userSessionStore.isUserLogged())
        default:
            ()
        }
        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.layoutIfNeeded()
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }

}

extension PreLiveEventsViewController: SportTypeSelectionViewDelegate {
    func selectedSport(_ sport: Sport) {
        self.changedSport(sport)
    }
}

extension PreLiveEventsViewController: HomeFilterOptionsViewDelegate {

    func setHomeFilters(homeFilters: HomeFilterOptions?) {
        self.viewModel.homeFilterOptions = homeFilters

        var countFilters = homeFilters?.countFilters ?? 0
        if StyleHelper.cardsStyleActive() != TargetVariables.defaultCardStyle {
            countFilters += 1
        }

        if countFilters != 0 {
            filtersCountLabel.isHidden = false
            filtersCountLabel.text = String(countFilters)
        }
        else {
            filtersCountLabel.isHidden = true

        }
    }

}
