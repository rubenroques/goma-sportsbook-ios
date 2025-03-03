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
    @IBOutlet private weak var filtersChipsBaseView: UIView!
    private var chipsTypeView: ChipsTypeView
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var sportsSelectorButtonView: UIView!
    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var sportsSelectorExpandImageView: UIImageView!

    @IBOutlet private weak var sportTypeNameLabel: UILabel!
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

    private let footerInnerView = UIView(frame: .zero)

    private let refreshControl = UIRefreshControl()

    //
    var turnTimeRangeOn: Bool = false
    var isLiveEventsMarkets: Bool = true

    var filterSelectedOption: Int = 0

    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    private var viewModel: LiveEventsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: LiveEventsViewModel) {
        self.viewModel = viewModel

        self.chipsTypeView = ChipsTypeView(viewModel: self.viewModel.chipsViewModel)

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
    }

    private func commonInit() {

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_1")

        self.chipsTypeView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)

        self.filtersChipsBaseView.addSubview(self.chipsTypeView)
        NSLayoutConstraint.activate([
            self.filtersChipsBaseView.leadingAnchor.constraint(equalTo: self.chipsTypeView.leadingAnchor),
            self.filtersChipsBaseView.trailingAnchor.constraint(equalTo: self.chipsTypeView.trailingAnchor),
            self.filtersChipsBaseView.topAnchor.constraint(equalTo: self.chipsTypeView.topAnchor),
            self.filtersChipsBaseView.bottomAnchor.constraint(equalTo: self.chipsTypeView.bottomAnchor),
        ])

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
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)

        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier+"Live")

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

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
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

        self.chipsTypeView.backgroundColor = UIColor.App.pillNavigation
        self.filtersChipsBaseView.backgroundColor = UIColor.App.pillNavigation

        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportsSelectorButtonView.backgroundColor = UIColor.App.highlightPrimary
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

}

extension LiveEventsViewController {

    public func selectSport(_ sport: Sport) {
        self.changedSport(sport)
    }

    private func changedSport(_ sport: Sport) {
        self.viewModel.selectedSport(sport)

        self.didChangeSport?(sport)
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

    func didSelectSport(_ sport: Sport) {
        self.changedSport(sport)
    }

}
