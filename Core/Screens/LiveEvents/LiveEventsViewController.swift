//
//  LiveEventsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class LiveEventsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var sportsSelectorButtonView: UIView!
    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var sportsSelectorExpandImageView: UIImageView!
    @IBOutlet private weak var leftGradientBaseView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!

    @IBOutlet private weak var filtersCountLabel: UILabel!

    @IBOutlet private weak var emptyBaseView: UIView!
    @IBOutlet private weak var firstTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var secondTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var emptyStateImage: UIImageView!
    @IBOutlet private weak var emptyStateButton: UIButton!

    @IBOutlet private weak var liveEventsCountView: UIView!
    @IBOutlet private weak var liveEventsCountLabel: UILabel!

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
    }

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    private let refreshControl = UIRefreshControl()

    var turnTimeRangeOn: Bool = false
    var isLiveEventsMarkets: Bool = true

    var filterSelectedOption: Int = 0
    var selectedSport: Sport {
        didSet {
            if let sportIconImage = UIImage(named: "sport_type_icon_\(self.selectedSport.id)") {
                self.sportTypeIconImageView.image = sportIconImage
                self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
            }
            else {
                self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_default")
                self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
            }
            self.viewModel.selectedSport = self.selectedSport
        }
    }

    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    private var viewModel: LiveEventsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(selectedSport: Sport) {
        self.selectedSport = selectedSport
        self.viewModel = LiveEventsViewModel(selectedSport: self.selectedSport)
        super.init(nibName: "LiveEventsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
        self.connectPublishers()

        self.viewModel.fetchLiveMatches()

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

        // New loading
        self.loadingView.alpha = 0.0
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)

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
        super.viewDidLayoutSubviews()

        self.liveEventsCountView.layer.cornerRadius = self.liveEventsCountView.frame.size.width / 2
        self.filtersButtonView.layer.cornerRadius = self.filtersButtonView.frame.height / 2
        self.sportsSelectorButtonView.layer.cornerRadius = self.sportsSelectorButtonView.frame.height / 2

    }

    private func commonInit() {

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_1")

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

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        filtersCollectionView.collectionViewLayout = flowLayout
        filtersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)
        filtersCollectionView.showsVerticalScrollIndicator = false
        filtersCollectionView.showsHorizontalScrollIndicator = false
        filtersCollectionView.alwaysBounceHorizontal = true
        filtersCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        filtersCountLabel.isHidden = true
        liveEventsCountView.isHidden = true

        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        tableView.addSubview(self.refreshControl)

        tableView.separatorStyle = .none
        tableView.register(MatchLineTableViewCell.nib,
                           forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib,
                           forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib,
                           forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(FooterResponsibleGamingViewCell.self,
                           forCellReuseIdentifier: FooterResponsibleGamingViewCell.identifier)
        tableView.register(TournamentTableViewHeader.nib,
                           forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        tableView.register(TitleTableViewHeader.nib,
                           forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)


        tableView.delegate = self
        tableView.dataSource = self

        tableView.clipsToBounds = false

        tableView.estimatedRowHeight = 155
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(handleSportsSelectionTap))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)

        //
        // ==============================================
        self.view.addSubview(self.floatingShortcutsView)
        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])

        self.view.bringSubviewToFront(self.loadingBaseView)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }

        let footerResponsibleGamingView = FooterResponsibleGamingView()
        footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false

        self.emptyBaseView.addSubview(footerResponsibleGamingView)

        NSLayoutConstraint.activate([
            footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.emptyBaseView.leadingAnchor),
            footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.emptyBaseView.trailingAnchor),
            footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.emptyBaseView.bottomAnchor),
        ])

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
    }

    func connectPublishers() {

        NotificationCenter.default.publisher(for: .cardsStyleChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &cancellables)

        self.viewModel.dataDidChangedAction = { [unowned self] in
            self.tableView.reloadData()
        }

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

        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportsSelectorButtonView.backgroundColor = UIColor.App.pillSettings
        self.sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        self.filtersButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        //
        //
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
        //
        //

        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.filtersButtonView.backgroundColor = UIColor.App.pillSettings

        self.filtersCollectionView.backgroundColor = UIColor.App.pillNavigation

        self.emptyBaseView.backgroundColor = .clear
        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.loadingBaseView.backgroundColor = .clear

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.textPrimary)
        self.sportTypeIconImageView.tintColor = UIColor.App.textPrimary

        self.sportsSelectorExpandImageView.setImageColor(color: UIColor.App.textPrimary)
        self.sportsSelectorExpandImageView.tintColor = UIColor.App.textPrimary


    }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(liveEventsViewModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    func changedSport(_ sport: Sport) {
        self.selectedSport = sport
        self.didChangeSport?(sport)
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

    private func showSearch() {
        let searchViewModel = SearchViewModel()

        searchViewModel.isLiveSearch = true

        let searchViewController = SearchViewController(viewModel: searchViewModel)

        let navigationViewController = Router.navigationController(with: searchViewController)

        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc func handleSportsSelectionTap() {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.selectedSport, isLiveSport: true)
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
            self.emptyStateButton.setTitle(localized("login"), for: .normal)
        }

    }

}

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.filterSelectedOption = indexPath.row
        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

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
            filtersCountLabel.layer.cornerRadius =  filtersCountLabel.frame.width/2
            filtersCountLabel.layer.masksToBounds = true
        }
        else {
            filtersCountLabel.isHidden = true
        }
    }

}

extension LiveEventsViewController: SportTypeSelectionViewDelegate {

    func selectedSport(_ sport: Sport) {
        self.changedSport(sport)
    }

}

