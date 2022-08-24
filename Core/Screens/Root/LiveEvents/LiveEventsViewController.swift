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

    var turnTimeRangeOn: Bool = false

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
    }
    
    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()

    var cancellables = Set<AnyCancellable>()

    var viewModel: LiveEventsViewModel
    
    var filterSelectedOption: Int = 0
    var selectedSport: Sport {
        didSet {
            self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_\(selectedSport.id)")
            self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
            self.viewModel.selectedSport = selectedSport
        }
    }

    var didChangeSport: ((Sport) -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    init(selectedSport: Sport = Sport.football) {
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

        self.view.bringSubviewToFront(self.loadingBaseView)

        self.commonInit()
        self.setupWithTheme()
        self.connectPublishers()
        self.viewModel.fetchData()

        self.viewModel.didSelectMatchAction = { match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        self.viewModel.updateNumberOfLiveEventsAction = {
            if self.viewModel.selectedSportNumberofLiveEvents != 0 {

                self.liveEventsCountView.isHidden = false
                self.liveEventsCountLabel.text = "\(self.viewModel.selectedSportNumberofLiveEvents)"
            }
            else {
                self.liveEventsCountView.isHidden = true
            }
        }
        
        self.tableView.isHidden = false
        self.emptyBaseView.isHidden = true
        
//        self.viewModel.didTapFavoriteMatchAction = { match in
//            if !UserSessionStore.isUserLogged() {
//                self.presentLoginViewController()
//            }
//            else {
//                self.viewModel.markAsFavorite(match: match)
//                self.tableView.reloadData()
//            }
//        }

        self.viewModel.didLongPressOdd = { [weak self] bettingTicket in
            self?.openQuickbet(bettingTicket)
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
        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        tableView.delegate = self
        tableView.dataSource = self

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

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingBaseView.isHidden = !isLoading

                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        self.viewModel.dataDidChangedAction = { [unowned self] in
            self.tableView.reloadData()
        }
        
        self.viewModel.screenStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState in
                switch screenState {
                case .noEmptyNoFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .emptyNoFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list"), secondLabelText: localized("second_empty_list"), isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                case .noEmptyAndFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .emptyAndFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"), secondLabelText: localized("second_empty_list_with_filters"), isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                }
            })
            .store(in: &cancellables)

//        Env.gomaSocialClient.unreadMessagesCountPublisher
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] unreadCounter in
//                print("UNREAD COUNT: \(unreadCounter)")
//                if unreadCounter > 0 {
//                    self?.chatCountLabel.text = "\(unreadCounter)"
//                    self?.chatCountLabel.isHidden = false
//                }
//                else {
//                    self?.chatCountLabel.isHidden = true
//                }
//            })
//            .store(in: &cancellables)

    }

    private func setupWithTheme() {

        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportsSelectorButtonView.backgroundColor = UIColor.App.buttonBackgroundPrimary
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

        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.filtersButtonView.backgroundColor = UIColor.App.backgroundTertiary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        
        self.filtersCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.emptyBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.sportTypeIconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.sportsSelectorExpandImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
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

        let quickbetViewModel = QuickBetViewModel(bettingTicket: bettingTicket)

        let quickbetViewController = QuickBetViewController(viewModel: quickbetViewModel)

        self.present(quickbetViewController, animated: true)
    }

    @objc func handleSportsSelectionTap() {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.selectedSport,
                                                            isLiveSport: true,
                                                            sportsRepository: self.viewModel.sportsRepository)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }

    @objc func refreshControllPulled() {
        self.viewModel.fetchData()
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
            self.firstTextFieldEmptyStateLabel.text = localized("empty_no_login")
            self.secondTextFieldEmptyStateLabel.text = localized("second_empty_no_login")
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

        switch indexPath.row {
        case 0:
            self.viewModel.setMatchListType(.allMatches)
        default:
            ()
        }

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
