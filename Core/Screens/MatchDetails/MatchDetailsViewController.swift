//
//  MatchDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2021.
//

import UIKit
import Combine
import LinkPresentation
import WebKit

class MatchDetailsViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var headerDetailView: UIView!
    @IBOutlet private var headerDetailTopView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var shareButton: UIButton!

    @IBOutlet private var headerCompetitionDetailView: UIView!
    @IBOutlet private var headerCompetitionLabel: UILabel!
    @IBOutlet private var headerCompetitionImageView: UIImageView!

    @IBOutlet private var headerDetailStackView: UIStackView!
    @IBOutlet private var headerDetailHomeView: UIView!
    @IBOutlet private var headerDetailHomeLabel: UILabel!
    @IBOutlet private var headerDetailAwayView: UIView!
    @IBOutlet private var headerDetailAwayLabel: UILabel!

    @IBOutlet private var headerDetailMiddleView: UIView!
    @IBOutlet private var headerDetailMiddleStackView: UIStackView!

    @IBOutlet private var headerDetailPreliveView: UIView!
    @IBOutlet private var headerDetailPreliveTopLabel: UILabel!
    @IBOutlet private var headerDetailPreliveBottomLabel: UILabel!

    @IBOutlet private var headerDetailLiveView: UIView!
    @IBOutlet private var headerDetailLiveTopLabel: UILabel!
    @IBOutlet private var headerDetailLiveBottomLabel: UILabel!

    @IBOutlet private var marketTypeSeparator: UILabel!

    @IBOutlet private var matchFieldBaseView: UIView!
    @IBOutlet private var matchFieldToggleView: UIView!
    @IBOutlet private var matchFieldTitleLabel: UILabel!
    @IBOutlet private var matchFieldTitleArrowImageView: UIImageView!
    @IBOutlet private var matchFieldWebView: WKWebView!
    @IBOutlet private var matchFieldWebViewHeight: NSLayoutConstraint!

    @IBOutlet private var marketTypesCollectionView: UICollectionView!
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var marketGroupsPagedBaseView: UIView!
    private var marketGroupsPagedViewController: UIPageViewController

    @IBOutlet private var loadingView: UIActivityIndicatorView!

    @IBOutlet private var matchNotAvailableView: UIView!
    @IBOutlet private var matchNotAvailableLabel: UILabel!

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
        betslipCountLabel.textColor = .white
        betslipCountLabel.backgroundColor = UIColor.App.alertError
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

    private lazy var sharedGameCardView: SharedGameCardView = {
        let gameCard = SharedGameCardView()
        gameCard.translatesAutoresizingMaskIntoConstraints = false
        gameCard.isHidden = true

        return gameCard
    }()

    private var shouldShowWebView = false
    private var matchFielHeight: CGFloat = 0
    private var isMatchFieldExpanded: Bool = false {
        didSet {
            if isMatchFieldExpanded {
                self.matchFieldTitleArrowImageView.image = UIImage(named: "arrow_collapse_icon")
                self.matchFieldWebViewHeight.constant = matchFielHeight
            }
            else {
                self.matchFieldTitleArrowImageView.image = UIImage(named: "arrow_expand_icon")
                self.matchFieldWebViewHeight.constant = 0
            }

            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    private var marketGroupsViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: MatchDetailsViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: MatchDetailsViewModel) {

        self.viewModel = viewModel

        self.marketGroupsPagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal,
                                                          options: nil)

        super.init(nibName: "MatchDetailsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(marketGroupsPagedViewController)
        self.marketGroupsPagedBaseView.addSubview(marketGroupsPagedViewController.view)
        self.marketGroupsPagedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        marketGroupsPagedBaseView.addSubview(self.marketGroupsPagedViewController.view)

        NSLayoutConstraint.activate([
            marketGroupsPagedBaseView.leadingAnchor.constraint(equalTo: self.marketGroupsPagedViewController.view.leadingAnchor),
            marketGroupsPagedBaseView.trailingAnchor.constraint(equalTo: self.marketGroupsPagedViewController.view.trailingAnchor),
            marketGroupsPagedBaseView.topAnchor.constraint(equalTo: self.marketGroupsPagedViewController.view.topAnchor),
            marketGroupsPagedBaseView.bottomAnchor.constraint(equalTo: self.marketGroupsPagedViewController.view.bottomAnchor),
        ])

        self.marketGroupsPagedViewController.didMove(toParent: self)

        //
        self.matchFieldWebViewHeight.constant = 0

        //
        self.matchNotAvailableView.isHidden = true

        //
        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)

        self.shareButton.setTitle("", for: .normal)
        self.shareButton.setImage(UIImage(named: "send_bet_icon"), for: .normal)

        self.headerCompetitionLabel.text = ""
        self.headerCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)

        self.headerCompetitionImageView.image = UIImage(named: "")
        self.headerCompetitionImageView.layer.cornerRadius = self.headerCompetitionImageView.frame.width/2
        self.headerCompetitionImageView.contentMode = .scaleAspectFill

        self.headerDetailHomeLabel.text = localized("home_label_default")
        self.headerDetailHomeLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailHomeLabel.numberOfLines = 0

        self.headerDetailAwayLabel.text = localized("away_label_default")
        self.headerDetailAwayLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailAwayLabel.numberOfLines = 0

        self.headerDetailPreliveTopLabel.text = localized("match_label_default")
        self.headerDetailPreliveTopLabel.font = AppFont.with(type: .semibold, size: 12)

        self.headerDetailPreliveBottomLabel.text = localized("time_label_default")
        self.headerDetailPreliveBottomLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveTopLabel.text = localized("score_label_default")
        self.headerDetailLiveTopLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveBottomLabel.text = localized("match_start_label_default")
        self.headerDetailLiveBottomLabel.font = AppFont.with(type: .semibold, size: 12)
        self.headerDetailLiveBottomLabel.numberOfLines = 0

        // Default to Pre Live
        self.headerDetailLiveView.isHidden = true
        self.headerDetailPreliveView.isHidden = false

        // Market Types CollectionView
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.marketTypesCollectionView.collectionViewLayout = flowLayout
        self.marketTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.marketTypesCollectionView.showsVerticalScrollIndicator = false
        self.marketTypesCollectionView.showsHorizontalScrollIndicator = false
        self.marketTypesCollectionView.alwaysBounceHorizontal = true
        self.marketTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                                forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.marketTypesCollectionView.delegate = self.viewModel
        self.marketTypesCollectionView.dataSource = self.viewModel

        self.marketGroupsPagedViewController.delegate = self
        self.marketGroupsPagedViewController.dataSource = self

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)
        self.betslipCountLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.matchFieldWebView.scrollView.alwaysBounceVertical = false
        self.matchFieldWebView.scrollView.bounces = false
        self.matchFieldWebView.navigationDelegate = self

        self.matchFieldTitleArrowImageView.image = UIImage(named: "arrow_expand_icon")

        self.matchFieldBaseView.isHidden = true

        //
        //
        self.view.addSubview(self.sharedGameCardView)

        NSLayoutConstraint.activate([
            sharedGameCardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            sharedGameCardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            sharedGameCardView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            sharedGameCardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        self.marketTypesCollectionView.reloadData()
        self.tableView.reloadData()

        // Shared Game
        self.view.sendSubviewToBack(self.sharedGameCardView)

        //
        self.view.bringSubviewToFront(self.matchNotAvailableView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.isRootModal {
            self.backButton.setImage(UIImage(named: "arrow_close_icon"), for: .normal)
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.marketTypeSeparator.backgroundColor = UIColor.App.separatorLine
        
        self.topView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerDetailView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerDetailTopView.backgroundColor = .clear
        self.backButton.tintColor = UIColor.App.textPrimary

        self.headerCompetitionDetailView.backgroundColor = .clear
        self.headerCompetitionLabel.textColor = UIColor.App.textPrimary
        self.headerDetailStackView.backgroundColor = .clear
        self.headerDetailHomeView.backgroundColor = .clear
        self.headerDetailHomeLabel.textColor = UIColor.App.textPrimary
        self.headerDetailAwayView.backgroundColor = .clear
        self.headerDetailAwayLabel.textColor = UIColor.App.textPrimary
        self.headerDetailMiddleView.backgroundColor = .clear
        self.headerDetailMiddleStackView.backgroundColor = .clear
        self.headerDetailPreliveView.backgroundColor = .clear
        self.headerDetailPreliveTopLabel.textColor = UIColor.App.textPrimary.withAlphaComponent(0.5)
        self.headerDetailPreliveBottomLabel.textColor = UIColor.App.textPrimary
        self.headerDetailLiveView.backgroundColor = .clear
        self.headerDetailLiveTopLabel.textColor = UIColor.App.textPrimary
        self.headerDetailLiveBottomLabel.textColor = UIColor.App.textPrimary.withAlphaComponent(0.5)

        // Market List CollectionView
        self.marketTypesCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        // TableView
        self.tableView.backgroundColor = .clear

        self.betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary
        
        self.matchFieldBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.matchFieldToggleView.backgroundColor = UIColor.App.backgroundTertiary
        self.matchFieldWebView.backgroundColor = UIColor.App.backgroundTertiary

        self.matchFieldTitleLabel.textColor = UIColor.App.textPrimary

        self.matchNotAvailableView.backgroundColor = UIColor.App.backgroundPrimary
        self.matchNotAvailableLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: MatchDetailsViewModel) {

        self.viewModel.isLoadingMarketGroups
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
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

        self.viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.reloadMarketGroupDetails(marketGroups)
                self?.reloadCollectionView()
            }
            .store(in: &cancellables)

        self.viewModel.selectedMarketTypeIndexPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                if let newIndex = newIndex {
                    self?.scrollToMarketDetailViewController(atIndex: newIndex)
                }
            }
            .store(in: &cancellables)

        self.viewModel.matchPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loadableMatch in
                switch loadableMatch {
                case .idle, .loading:
                    ()
                case .loaded:
                    self?.setupHeaderDetails()
                    self?.setupMatchField()
                case .failed:
                    self?.showMatchNotAvailableView()
                }
            })
            .store(in: &cancellables)

        self.viewModel.matchModePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] matchMode in

                if matchMode == .preLive {
                    self?.headerDetailLiveView.isHidden = true
                    self?.headerDetailPreliveView.isHidden = false
                }
                else {
                    self?.headerDetailPreliveView.isHidden = true
                    self?.headerDetailLiveView.isHidden = false
                }

                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()

                self?.updateHeaderDetails()
            })
            .store(in: &cancellables)
    }

    func reloadMarketGroupDetails(_ marketGroups: [MarketGroup]) {

        guard let match = self.viewModel.match else {
            return
        }

        self.marketGroupsViewControllers = []

        for marketGroup in marketGroups {
            if let groupKey = marketGroup.groupKey {
                let viewModel = MarketGroupDetailsViewModel(match: match, marketGroupId: groupKey)
                let marketGroupDetailsViewController = MarketGroupDetailsViewController(viewModel: viewModel)

                self.marketGroupsViewControllers.append(marketGroupDetailsViewController)
            }
        }

        if let firstViewController = self.marketGroupsViewControllers.first {
            self.marketGroupsPagedViewController.setViewControllers([firstViewController],
                                                                    direction: .forward,
                                                                    animated: false,
                                                                    completion: nil)
        }

    }

    func reloadMarketGroupDetailsContent() {
        for marketGroupsViewController in marketGroupsViewControllers {
            (marketGroupsViewController as? MarketGroupDetailsViewController)?.reloadContent()
        }
    }

    func reloadCollectionView() {
        self.marketTypesCollectionView.reloadData()
    }

    func scrollToMarketDetailViewController(atIndex index: Int) {

        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.marketGroupsViewControllers[safe: index] {
                self.marketGroupsPagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .forward,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }
        else {
            if let selectedViewController = self.marketGroupsViewControllers[safe: index] {
                self.marketGroupsPagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .reverse,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
    }

    func selectMarketType(atIndex index: Int) {
        self.viewModel.selectMarketType(atIndex: index)
        self.marketTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }

    func setupMatchField() {

        // Hide match field if the sport doesn't support it
        self.matchFieldBaseView.isHidden = true

        guard let match = self.viewModel.match else {
            return
        }

        let validSportType = match.sportType == "1" || match.sportType == "3"
        if self.viewModel.matchModePublisher.value == .live && validSportType {
            self.shouldShowWebView = true
        }

        if shouldShowWebView {
            let request = URLRequest(url: URL(string: "https://sportsbook-cms.gomagaming.com/widget/\(match.id)/\(match.sportType)")!)
            self.matchFieldWebView.load(request)
        }

    }

    func setupHeaderDetails() {
        guard
            let match = self.viewModel.match
        else {
            return
        }

        let viewModel = MatchWidgetCellViewModel(match: match)

        // self.headerCompetitionImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))

        if viewModel.countryISOCode != "" {
            self.headerCompetitionImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        }
        else {
            self.headerCompetitionImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryId))
        }

        self.headerCompetitionLabel.text = viewModel.competitionName
        self.headerDetailHomeLabel.text = viewModel.homeTeamName
        self.headerDetailAwayLabel.text = viewModel.awayTeamName

        if self.viewModel.matchModePublisher.value == .preLive {
            self.headerDetailPreliveTopLabel.text = viewModel.startDateString
            self.headerDetailPreliveBottomLabel.text = viewModel.startTimeString
        }
        else {
            self.updateHeaderDetails()
        }

        self.sharedGameCardView.setupSharedCardInfo(viewModel: self.viewModel)

    }

    func updateHeaderDetails() {

        guard let match = self.viewModel.match else {
            return
        }

        let matchId = self.viewModel.matchId

        var homeGoals = ""
        var awayGoals = ""
        var minutes = ""
        var matchPart = ""

        if let matchInfoArray = self.viewModel.store.matchesInfoForMatch[matchId] {
            for matchInfoId in matchInfoArray {
                if let matchInfo = self.viewModel.store.matchesInfo[matchInfoId] {
                    if (matchInfo.typeId ?? "") == "1" && (matchInfo.eventPartId ?? "") == match.rootPartId {
                        // Goals
                        if let homeGoalsFloat = matchInfo.paramFloat1 {
                            if match.homeParticipant.id == matchInfo.paramParticipantId1 {
                                homeGoals = "\(homeGoalsFloat)"
                            }
                            else if match.awayParticipant.id == matchInfo.paramParticipantId1 {
                                awayGoals = "\(homeGoalsFloat)"
                            }
                        }
                        if let awayGoalsFloat = matchInfo.paramFloat2 {
                            if match.homeParticipant.id == matchInfo.paramParticipantId2 {
                                homeGoals = "\(awayGoalsFloat)"
                            }
                            else if match.awayParticipant.id == matchInfo.paramParticipantId2 {
                                awayGoals = "\(awayGoalsFloat)"
                            }
                        }
                    }
                    else if (matchInfo.typeId ?? "") == "95", let minutesFloat = matchInfo.paramFloat1 {
                        // Match Minutes
                        minutes = "\(minutesFloat)"
                    }
                    else if (matchInfo.typeId ?? "") == "92", let eventPartName = matchInfo.paramEventPartName1 {
                        // Status Part
                        matchPart = eventPartName
                    }
                }
            }
        }

        if homeGoals.isNotEmpty && awayGoals.isNotEmpty {
            self.headerDetailLiveTopLabel.text = "\(homeGoals) - \(awayGoals)"
        }

        if minutes.isNotEmpty && matchPart.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(minutes)' - \(matchPart)"
        }
        else if minutes.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(minutes)'"
        }
        else if matchPart.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(matchPart)"
        }
    }

    func showMatchNotAvailableView() {
        self.shareButton.isHidden = true

        self.matchNotAvailableView.isHidden = false
    }

    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.marketTypesCollectionView.reloadData()
            self?.tableView.reloadData()
            self?.reloadMarketGroupDetailsContent()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    @IBAction private func didTapFieldToogleView() {
        self.isMatchFieldExpanded.toggle()
    }

    @IBAction private func didTapBackAction() {
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction private func didTapShareButton() {

        guard let matchId = self.viewModel.match?.id else {
            return
        }

        self.sharedGameCardView.isHidden = false

        let renderer = UIGraphicsImageRenderer(size: self.sharedGameCardView.bounds.size)
        let snapshot = renderer.image { _ in
            self.sharedGameCardView.drawHierarchy(in: self.sharedGameCardView.bounds, afterScreenUpdates: true)
        }

        let metadata = LPLinkMetadata()
        let urlMobile = Env.urlMobileShares

        if let matchUrl = URL(string: "\(urlMobile)/gamedetail/\(matchId)") {

            let imageProvider = NSItemProvider(object: snapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = matchUrl
            metadata.title = localized("check_this_game")
        }

        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

        let share = UIActivityViewController(activityItems: [metadataItemSource, snapshot], applicationActivities: nil)

        share.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.sharedGameCardView.isHidden = true
        }

        present(share, animated: true, completion: nil)
    }


}

extension MatchDetailsViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = marketGroupsViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return marketGroupsViewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = marketGroupsViewControllers.firstIndex(of: viewController) {
            if index < marketGroupsViewControllers.count - 1 {
                return marketGroupsViewControllers[index + 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if !completed {
            return
        }

        if let currentViewController = pageViewController.viewControllers?.first,
           let index = marketGroupsViewControllers.firstIndex(of: currentViewController) {
            self.selectMarketType(atIndex: index)
        }
        else {
            self.selectMarketType(atIndex: 0)
        }
    }

}

extension MatchDetailsViewController: WKNavigationDelegate {

    private func recalculateWebview() {
        executeDelayed(0.5) {
            self.matchFieldWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { height, error in
                if let heightFloat = height as? CGFloat {
                    self.redrawWebView(withHeight: heightFloat)
                }
                if let error = error {
                    Logger.log("Match details WKWebView didFinish error \(error)")
                }
            })
        }
    }

    private func redrawWebView(withHeight heigth: CGFloat) {
        self.matchFielHeight = heigth
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.matchFieldWebView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
            if complete != nil {
                self.recalculateWebview()

                if self.shouldShowWebView {
                    self.matchFieldBaseView.isHidden = false
                }
            }
            else if let error = error {
                Logger.log("Match details WKWebView didFinish error \(error)")
            }
        })
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

    }

}

extension MatchDetailsViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
