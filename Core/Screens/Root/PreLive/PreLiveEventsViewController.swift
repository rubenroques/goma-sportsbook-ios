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

    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var leftGradientBaseView: UIView!
    @IBOutlet private weak var sportsSelectorButtonView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!
    
    @IBOutlet private weak var filtersCountView: UIView!

    @IBOutlet private weak var emptyBaseView: UIView!
    @IBOutlet private weak var filtersCountLabel: UILabel!
    @IBOutlet private weak var firstTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var secondTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var emptyStateImage: UIImageView!
    @IBOutlet private weak var emptyStateButton: UIButton!

    private let refreshControl = UIRefreshControl()

    var turnTimeRangeOn: Bool = false

    var betslipButtonViewBottomConstraint: NSLayoutConstraint?
    private lazy var betslipButtonView: UIView = {
        var betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        var iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }()
    private lazy var betslipCountLabel: UILabel = {
        var betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        NSLayoutConstraint.activate([
            betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            betslipCountLabel.widthAnchor.constraint(equalTo: betslipCountLabel.heightAnchor),
        ])
        return betslipCountLabel
    }()

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    @IBOutlet private weak var openedCompetitionsFiltersConstraint: NSLayoutConstraint!
    @IBOutlet private weak var competitionsFiltersBaseView: UIView!
    @IBOutlet private weak var competitionsFiltersDarkBackgroundView: UIView!
    private var competitionsFiltersView: CompetitionsFiltersView?

    var cancellables = Set<AnyCancellable>()

    var viewModel: PreLiveEventsViewModel

    var filterSelectedOption: Int = 0
    var selectedSport: Sport {
        didSet {
            if let sportIconImage = UIImage(named: "sport_type_mono_icon_\( selectedSport.id)") {
                self.sportTypeIconImageView.image = sportIconImage
            }
            else {
                self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_default")
            }

            self.viewModel.selectedSport = selectedSport
            self.competitionsFiltersView?.resetSelection()
        }
    }

    var didChangeSport: ((Sport) -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    private var lastContentOffset: CGFloat = 0
    private var shouldDetectScrollMovement = false

    var setSelectedCollectionViewItem: Int = 0 {
        didSet {
            let indexPath = IndexPath(item: setSelectedCollectionViewItem, section: 0)

            self.filterSelectedOption = setSelectedCollectionViewItem

            AnalyticsClient.sendEvent(event: .competitionsScreen)
            self.viewModel.setMatchListType(.competitions)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("empty_list"),
                                       secondLabelText: localized("second_empty_list"),
                                       isUserLoggedIn: true)
            self.filtersCollectionView.reloadData()
            self.filtersCollectionView.layoutIfNeeded()
            self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        }
    }

    init(selectedSportType: Sport = .football) {
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

        self.commonInit()
        self.setupWithTheme()

        self.connectPublishers()
        self.viewModel.fetchData()

        self.viewModel.didSelectActivationAlertAction = { alertType in
            if alertType == ActivationAlertType.email {
                let emailVerificationViewController = EmailVerificationViewController()
                self.present(emailVerificationViewController, animated: true, completion: nil)
            }
            else if alertType == ActivationAlertType.profile {
                let fullRegisterViewController = FullRegisterPersonalInfoViewController(isBackButtonDisabled: true)
                self.navigationController?.pushViewController(fullRegisterViewController, animated: true)
            }
        }

        self.viewModel.didSelectMatchAction = { match, image in
            if let matchInfo = Env.everyMatrixStorage.matchesInfoForMatch[match.id] {
                let matchDetailsViewController = MatchDetailsViewController(matchMode: .live, match: match)
                matchDetailsViewController.viewModel.gameSnapshot = image
                self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
            }
            else {
                let matchDetailsViewController = MatchDetailsViewController(matchMode: .preLive, match: match)
                matchDetailsViewController.viewModel.gameSnapshot = image
                self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
            }
        }

        self.tableView.isHidden = false
        self.emptyBaseView.isHidden = true
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
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

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2

        filtersCountLabel.layer.cornerRadius =  filtersCountLabel.frame.width/2
       
    }

    private func commonInit() {

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_1")
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
        filtersCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        sportsSelectorButtonView.backgroundColor = UIColor.App.highlightPrimary
        sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        filtersButtonView.backgroundColor = UIColor.App.buttonBackgroundSecondary
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
        filtersCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        filtersCountLabel.isHidden = true
        filtersCountLabel.font = AppFont.with(type: .bold, size: 10.0)
        filtersCountLabel.layer.masksToBounds = true
        filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary
        
        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        
        tableView.separatorStyle = .none
        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self

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
        self.competitionsFiltersView = CompetitionsFiltersView()

        self.competitionsFiltersView?.applyFiltersAction = { [unowned self] selectedCompetitionsIds in
            self.applyCompetitionsFiltersWithIds(selectedCompetitionsIds)
        }
        self.competitionsFiltersView?.tapHeaderViewAction = { [unowned self] in
            self.openCompetitionsFilters()
        }

        self.competitionsFiltersDarkBackgroundView.alpha = 0.2
        self.competitionsFiltersBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.competitionsFiltersBaseView.addSubview(self.competitionsFiltersView!)

        NSLayoutConstraint.activate([
            self.competitionsFiltersBaseView.leadingAnchor.constraint(equalTo: self.competitionsFiltersView!.leadingAnchor),
            self.competitionsFiltersBaseView.trailingAnchor.constraint(equalTo: self.competitionsFiltersView!.trailingAnchor),
            self.competitionsFiltersBaseView.topAnchor.constraint(equalTo: self.competitionsFiltersView!.topAnchor),
            self.competitionsFiltersBaseView.bottomAnchor.constraint(equalTo: self.competitionsFiltersView!.bottomAnchor),
        ])

        //
        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)
        self.betslipCountLabel.isHidden = true

        self.betslipButtonViewBottomConstraint = self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12)

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonViewBottomConstraint!
        ])

        self.view.bringSubviewToFront(self.competitionsFiltersDarkBackgroundView)
        self.view.bringSubviewToFront(self.competitionsFiltersBaseView)
        self.view.bringSubviewToFront(self.loadingBaseView)
        self.view.bringSubviewToFront(self.filtersCountLabel)

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    func connectPublishers() {

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingBaseView.isHidden = !isLoading
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        self.viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.viewModel.screenStatePublisher, self.viewModel.isLoading)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState, isLoading in

                if isLoading {
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                    return
                }

                switch screenState {
                case .noEmptyNoFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .emptyNoFilter:
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    if self?.viewModel.matchListTypePublisher.value == .myGames ||
                        self?.viewModel.matchListTypePublisher.value ==  .today ||
                        self?.viewModel.matchListTypePublisher.value == .competitions {
                        self?.setEmptyStateBaseView(firstLabelText: localized("empty_list"),
                                                    secondLabelText: localized("second_empty_list"),
                                                    isUserLoggedIn: true)
                    }
                case .noEmptyAndFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .emptyAndFilter:
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    if self?.viewModel.matchListTypePublisher.value == .myGames ||
                        self?.viewModel.matchListTypePublisher.value ==  .today ||
                        self?.viewModel.matchListTypePublisher.value == .competitions {
                        self?.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"),
                                                    secondLabelText: localized("second_empty_list_with_filters"),
                                                    isUserLoggedIn: true)
                    }
                }
            })
            .store(in: &cancellables)
        
        self.viewModel.matchListTypePublisher
            .map {  $0 == .competitions }
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
            .map {
                $0.enumerated().map {
                    CompetitionFilterSectionViewModel(index: $0.offset, competitionGroup: $0.element)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competitions in
                self?.competitionsFiltersView?.competitions = competitions
            }
            .store(in: &cancellables)

        self.viewModel.isLoadingCompetitionGroups
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingGroups in
                self?.competitionsFiltersView?.isLoading = isLoadingGroups
            })
            .store(in: &cancellables)

        self.competitionsFiltersView?.selectedIds
            .compactMap({ $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShowOpen in
                if shouldShowOpen {
                    self?.openCompetitionsFilters()
                }
            })
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in

                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
                }
            })
            .store(in: &cancellables)

        Env.userSessionStore.isUserProfileIncomplete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.tableView.reloadData()
            })
            .store(in: &cancellables)

    }

    @objc func refreshControllPulled() {
        self.viewModel.fetchData()
    }

    func reloadTableViewData() {
        self.tableView.reloadData()
    }

    @objc func handleSportsSelectionTap(_ sender: UITapGestureRecognizer? = nil) {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.selectedSport)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.filtersButtonView.backgroundColor = UIColor.App.backgroundPrimary
        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary
        
        self.emptyBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary


    }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(sportsModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
    
    }

    func applyCompetitionsFiltersWithIds(_ ids: [String]) {
        self.viewModel.fetchCompetitionsMatchesWithIds(ids)
        self.showBottomBarCompetitionsFilters()
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    func changedSport(_ sport: Sport) {
        self.selectedSport = sport
        self.didChangeSport?(sport)
    }

    func openCompetitionsFilters() {
        guard
            let competitionsFiltersView = competitionsFiltersView,
            competitionsFiltersView.state != .opened
        else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.4
            self.openedCompetitionsFiltersConstraint.constant = 0
            self.tableView.contentInset.bottom = 16
            // competitionsFiltersView.openedBarHeaderViewSize()
            competitionsFiltersView.state = .opened

            self.betslipButtonViewBottomConstraint?.constant = -self.tableView.contentInset.bottom

            self.view.layoutIfNeeded()
        }, completion: nil)

    }

    func showBottomBarCompetitionsFilters() {
        guard let competitionsFiltersView = competitionsFiltersView else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(competitionsFiltersView.frame.size.height - 52)
            self.tableView.contentInset.bottom = 54+16
            // competitionsFiltersView.closedBarHeaderViewSize()
            competitionsFiltersView.state = .bar

            self.betslipButtonViewBottomConstraint?.constant = -60

            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func showBottomLineCompetitionsFilters() {
        guard let competitionsFiltersView = competitionsFiltersView else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(competitionsFiltersView.frame.size.height - 18)
            self.tableView.contentInset.bottom = 24
            // competitionsFiltersView.lineHeaderViewSize()
            competitionsFiltersView.state = .line

            self.betslipButtonViewBottomConstraint?.constant = -self.tableView.contentInset.bottom

            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }
    
    func setEmptyStateBaseView(firstLabelText : String, secondLabelText : String, isUserLoggedIn : Bool) {
    
        if isUserLoggedIn {
            self.emptyStateImage.image = UIImage(named: "no_content_icon")
            self.firstTextFieldEmptyStateLabel.text = firstLabelText
            self.secondTextFieldEmptyStateLabel.text = secondLabelText
            self.emptyStateButton.isHidden = isUserLoggedIn
        }
        else {
            self.emptyStateImage.image = UIImage(named: "no_internet_icon")
            self.firstTextFieldEmptyStateLabel.text = localized("empty_no_login")
            self.secondTextFieldEmptyStateLabel.text = localized("second_empty_no_login")
            self.emptyStateButton.isHidden = isUserLoggedIn
            self.emptyStateButton.setTitle("Login", for: .normal)
        }
        
    }

    func layoutBetslipButtonPosition() {
        var constant: CGFloat = -12
        if self.competitionsFiltersBaseView.isHidden {
            constant = -12
        }
        else if self.competitionsFiltersView?.state == .opened {
            constant = -12
        }
        else if self.competitionsFiltersView?.state == .bar {
            constant = -60
        }
        else if self.competitionsFiltersView?.state == .line {
            constant = -24
        }
        self.betslipButtonViewBottomConstraint?.constant = constant
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
        return 5
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
        case 3:
            cell.setupWithTitle(localized("my_games"))
        case 4:
            cell.setupWithTitle(localized("my_competitions"))
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
            self.viewModel.setMatchListType(.myGames)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("empty_list"),
                                       secondLabelText: localized("second_empty_list"),
                                       isUserLoggedIn: true)
        case 1:
            AnalyticsClient.sendEvent(event: .todayScreen)
            self.viewModel.setMatchListType(.today)
            turnTimeRangeOn = true
            self.setEmptyStateBaseView(firstLabelText: localized("empty_list"),
                                       secondLabelText: localized("second_empty_list"),
                                       isUserLoggedIn: true)
        case 2:
            AnalyticsClient.sendEvent(event: .competitionsScreen)
            self.viewModel.setMatchListType(.competitions)
            turnTimeRangeOn = false
            self.setEmptyStateBaseView(firstLabelText: localized("empty_list"),
                                       secondLabelText: localized("second_empty_list"),
                                       isUserLoggedIn: true)
        case 3:
            self.viewModel.setMatchListType(.favoriteGames)
            self.setEmptyStateBaseView(firstLabelText: localized("empty_my_games"),
                                       secondLabelText: localized("second_empty_my_games"),
                                       isUserLoggedIn: UserSessionStore.isUserLogged())
        case 4:
            self.viewModel.setMatchListType(.favoriteCompetitions)
            self.setEmptyStateBaseView(firstLabelText: localized("empty_my_competitions"),
                                       secondLabelText: localized("second_empty_my_competitions"),
                                       isUserLoggedIn: UserSessionStore.isUserLogged())
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

protocol HomeFilterOptionsViewDelegate: AnyObject {
    var turnTimeRangeOn: Bool { get set }
    func setHomeFilters(homeFilters: HomeFilterOptions)
    
}

extension PreLiveEventsViewController: HomeFilterOptionsViewDelegate {

    func setHomeFilters(homeFilters: HomeFilterOptions) {
        self.viewModel.homeFilterOptions = homeFilters
        
        if homeFilters.countFilters != 0 {
            filtersCountLabel.isHidden = false
            filtersCountLabel.text = String(homeFilters.countFilters)
           
        }
        else {
            filtersCountLabel.isHidden = true

        }
    }
    
}
