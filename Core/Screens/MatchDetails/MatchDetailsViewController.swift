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
    
    @IBOutlet private var headerButtonsBaseView: UIView!
    @IBOutlet private var headerButtonsStackView: UIStackView!
    @IBOutlet private var headerLiveButtonBaseView: UIView!
    @IBOutlet private var liveButtonLabel: UILabel!
    @IBOutlet private var liveButtonImageView: UIImageView!
    
    @IBOutlet private var headerStatsButtonBaseView: UIView!
    @IBOutlet private var statsButtonLabel: UILabel!
    @IBOutlet private var statsButtonImageView: UIImageView!
    
    @IBOutlet private var accountValueView: UIView!
    @IBOutlet private var accountPlusView: UIView!
    @IBOutlet private var accountValueLabel: UILabel!
    @IBOutlet private var accountPlusImageView: UIImageView!
    
    @IBOutlet private var marketTypeSeparator: UILabel!
    
    @IBOutlet private var matchFieldBaseView: UIView!
    @IBOutlet private var matchFieldLoadingView: UIActivityIndicatorView!
    
    @IBOutlet private var matchFieldWebView: WKWebView!
    @IBOutlet private var matchFieldWebViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var statsBaseView: UIView!
    @IBOutlet private var statsCollectionBaseView: UIView!
    @IBOutlet private var statsCollectionView: UICollectionView!
    @IBOutlet private var statsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet private var statsBackSliderView: UIView!
    @IBOutlet private var statsNotFoundLabel: UILabel!
    
    @IBOutlet private var marketTypesCollectionView: UICollectionView!
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var marketGroupsPagedBaseView: UIView!
    private var marketGroupsPagedViewController: UIPageViewController
    
    @IBOutlet private var loadingView: UIActivityIndicatorView!
    
    @IBOutlet private var matchNotAvailableView: UIView!
    @IBOutlet private var matchNotAvailableLabel: UILabel!
    
    @IBOutlet private weak var homeRedCardImage: UIImageView!
    @IBOutlet private weak var awayRedCardImage: UIImageView!
    
    
    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
    }
    
    private lazy var sharedGameCardView: SharedGameCardView = {
        let gameCard = SharedGameCardView()
        gameCard.translatesAutoresizingMaskIntoConstraints = false
        gameCard.isHidden = true
        
        return gameCard
    }()
    
    private var showingStatsBackSliderView: Bool = false
    private var shouldShowStatsView = false
    private var isStatsViewExpanded: Bool = false {
        didSet {
            if isStatsViewExpanded {
                self.statsCollectionViewHeight.constant = 148
            }
            else {
                self.statsCollectionViewHeight.constant = 0
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // =========================================================================
    // Header bar and buttons logic
    // =========================================================================
    
    var isValidStatsSport: Bool {
        guard let match = self.viewModel.match else {
            return false
        }
        
        let isValidStatsSportType = match.sportType == "1" || match.sportType == "3"
        if isValidStatsSportType {
            return true
        }
        else {
            return false
        }
    }
    
    private var shouldShowLiveFieldWebView = false {
        didSet {
            if self.shouldShowLiveFieldWebView {
                self.headerLiveButtonBaseView.isHidden = false
            }
            else {
                self.headerLiveButtonBaseView.isHidden = true
            }
        }
    }
    
    private var matchFielHeight: CGFloat = 0
    private var isMatchFieldExpanded: Bool = false {
        didSet {
            if self.isMatchFieldExpanded {
                self.matchFieldWebViewHeight.constant = matchFielHeight
            }
            else {
                self.matchFieldWebViewHeight.constant = 0
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    enum HeaderBarSelection {
        case none
        case live
        case stats
    }
    
    var headerBarSelection: HeaderBarSelection = .none {
        didSet {
            switch self.headerBarSelection {
            case .none:
                self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
                self.liveButtonLabel.textColor = UIColor.App.textSecondary
                self.liveButtonImageView.setImageColor(color: UIColor.App.textSecondary)
                //
                self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
                self.statsButtonLabel.textColor = UIColor.App.textSecondary
                self.statsButtonImageView.setImageColor(color: UIColor.App.textSecondary)
                //
                
                self.isStatsViewExpanded = false
                self.isMatchFieldExpanded = false
                
            case .live:
                self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
                self.liveButtonLabel.textColor = UIColor.App.textPrimary
                self.liveButtonImageView.setImageColor(color: UIColor.App.textPrimary)
                //
                self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
                self.statsButtonLabel.textColor = UIColor.App.textSecondary
                self.statsButtonImageView.setImageColor(color: UIColor.App.textSecondary)
                //
                
                self.isStatsViewExpanded = false
                self.isMatchFieldExpanded = true
                
            case .stats:
                self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
                self.liveButtonLabel.textColor = UIColor.App.textSecondary
                self.liveButtonImageView.setImageColor(color: UIColor.App.textSecondary)
                //
                self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
                self.statsButtonLabel.textColor = UIColor.App.textPrimary
                self.statsButtonImageView.setImageColor(color: UIColor.App.textPrimary)
                
                self.isStatsViewExpanded = true
                self.isMatchFieldExpanded = false
            }
        }
    }
    
    private var isLiveFieldReady: Bool = false {
        didSet {
            if isLiveFieldReady {
                self.matchFieldLoadingView.stopAnimating()
            }
            else {
                self.matchFieldLoadingView.startAnimating()
            }
        }
    }
    
    // =========================================================================
    
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
        
        self.view.transitionId = "SeeMoreToMatchDetails"
        
        //
        self.addChildViewController(marketGroupsPagedViewController, toView: marketGroupsPagedBaseView)
        
        //
        self.matchFieldWebViewHeight.constant = 0
        
        //
        self.matchNotAvailableView.isHidden = true
        
        self.matchFieldBaseView.isHidden = false
        self.statsBaseView.isHidden = false
        
        //
        self.isLiveFieldReady = false
        self.shouldShowLiveFieldWebView = false
        
        //
        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()
        
        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        
        self.shareButton.setTitle("", for: .normal)
        self.shareButton.setImage(UIImage(named: "more_options_icon"), for: .normal)
        
        self.headerCompetitionLabel.text = ""
        self.headerCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)
        
        self.headerCompetitionImageView.image = nil
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
        
        //
        // account balance
        self.accountValueView.isHidden = true
        self.accountValueView.layer.cornerRadius = CornerRadius.view
        self.accountValueView.layer.masksToBounds = true
        self.accountValueView.isUserInteractionEnabled = true
        
        self.accountPlusView.layer.cornerRadius = CornerRadius.squareView
        self.accountPlusView.layer.masksToBounds = true
        
        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        accountValueView.addGestureRecognizer(accountValueTapGesture)
        
        
        // matchFieldWebView
        //
        self.matchFieldWebView.scrollView.alwaysBounceVertical = false
        self.matchFieldWebView.scrollView.bounces = false
        self.matchFieldWebView.navigationDelegate = self
        
        self.matchFieldLoadingView.hidesWhenStopped = true
        self.matchFieldLoadingView.stopAnimating()
        self.matchFieldLoadingView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        self.matchFieldLoadingView.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)
        
        //
        // stats
        self.statsCollectionView.delegate = self
        self.statsCollectionView.dataSource = self
        self.statsCollectionView.allowsSelection = false
        
        self.statsCollectionView.showsVerticalScrollIndicator = false
        self.statsCollectionView.showsHorizontalScrollIndicator = false
        self.statsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let statsFlowLayout = UICollectionViewFlowLayout()
        statsFlowLayout.scrollDirection = .horizontal
        self.statsCollectionView.collectionViewLayout = statsFlowLayout
        
        self.statsCollectionView.register(MatchStatsCollectionViewCell.nib, forCellWithReuseIdentifier: MatchStatsCollectionViewCell.identifier)
        
        self.statsBackSliderView.alpha = 0.0
        self.statsBackSliderView.layer.cornerRadius = 6
        
        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.statsBackSliderView.addGestureRecognizer(backSliderTapGesture)
        
        self.statsNotFoundLabel.isHidden = true
        
        // match share
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
        
        let didTapLiveGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveButtonHeaderView))
        self.headerLiveButtonBaseView.addGestureRecognizer(didTapLiveGesture)
        
        let didTapStatsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStatsButtonHeaderView))
        self.headerStatsButtonBaseView.addGestureRecognizer(didTapStatsGesture)
        
        self.headerBarSelection = .none
        
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
        
        self.floatingShortcutsView.resetAnimations()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // betslip
        //
        self.view.addSubview(self.floatingShortcutsView)
        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
        
        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        
        self.headerButtonsBaseView.backgroundColor = UIColor.App.separatorLine
        self.headerButtonsStackView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        
        // Market List CollectionView
        self.marketTypesCollectionView.backgroundColor = UIColor.App.backgroundSecondary
        
        // TableView
        self.tableView.backgroundColor = .clear
        
        self.matchFieldBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.matchFieldWebView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.matchNotAvailableView.backgroundColor = UIColor.App.backgroundPrimary
        self.matchNotAvailableLabel.textColor = UIColor.App.textPrimary
        self.matchFieldLoadingView.tintColor = .gray
        
        self.statsBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.statsCollectionBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.statsCollectionView.backgroundColor = UIColor.App.backgroundPrimary
        self.statsBackSliderView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.statsNotFoundLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: - Bindings
    private func bind(toViewModel viewModel: MatchDetailsViewModel) {
        
        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSession in
                if userSession != nil { // Is Logged In
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
                    let accountValue = bonusWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
                    
                }
                else {
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)
        
        Env.userSessionStore.userBonusBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
                    let accountValue = currentWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)
        
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
                    self?.statsCollectionView.reloadData()
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
        
        self.viewModel.matchStatsUpdatedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadStatsCollectionView()
            })
            .store(in: &cancellables)
        
        self.viewModel.homeRedCardsScorePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] homeScoreValue in
                
                if homeScoreValue != "0" {
                    self?.homeRedCardImage.isHidden = false
                }
               else {
                    self?.homeRedCardImage.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        self.viewModel.awayRedCardsScorePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] awayScoreValue in
                
                if awayScoreValue != "0" {
                    self?.awayRedCardImage.isHidden = false
                }
                else {
                    self?.awayRedCardImage.isHidden = true
                }
                  
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
                print("MatchDetailsMarkets - marketGroupDetailsViewController: \(groupKey)")
                self.marketGroupsViewControllers.append(marketGroupDetailsViewController)
            }
        }
        
        if let firstViewController = self.marketGroupsViewControllers.first {
            self.marketGroupsPagedViewController.setViewControllers([firstViewController],
                                                                    direction: .forward,
                                                                    animated: false,
                                                                    completion: nil)
        }
        
        print("MatchDetailsMarkets - \(self.marketGroupsViewControllers.count)")
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
    
    func reloadStatsCollectionView() {
        if self.viewModel.numberOfStatsSections() == 0 {
            self.statsNotFoundLabel.isHidden = false
            self.statsCollectionView.isHidden = true
        }
        else {
            self.statsNotFoundLabel.isHidden = true
            self.statsCollectionView.isHidden = false
        }
        self.statsCollectionView.reloadData()
    }
    
    func reloadSelectedIndex() {
        self.selectMarketType(atIndex: self.currentPageViewControllerIndex)
    }
    
    func selectMarketType(atIndex index: Int) {
        self.viewModel.selectMarketType(atIndex: index)
        self.marketTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func setupMatchField() {
        
        guard let match = self.viewModel.match else {
            return
        }
        
        if self.viewModel.matchModePublisher.value == .live && self.isValidStatsSport {
            self.shouldShowLiveFieldWebView = true
            self.isLiveFieldReady = false
            
            let request = URLRequest(url: URL(string: "https://sportsbook-cms.gomagaming.com/widget/\(match.id)/\(match.sportType)")!)
            self.matchFieldWebView.load(request)
        }
        else if self.viewModel.matchModePublisher.value == .preLive {
            self.shouldShowLiveFieldWebView = false
        }
        
    }
    
    func setupHeaderDetails() {
        guard
            let match = self.viewModel.match
        else {
            return
        }
        
        let viewModel = MatchWidgetCellViewModel(match: match)
        
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
    
    @objc func didTapLiveButtonHeaderView() {
        
        if !isLiveFieldReady {
            return
        }
        
        if !shouldShowLiveFieldWebView {
            return
        }
        
        switch self.headerBarSelection {
        case .none, .stats:
            self.headerBarSelection = .live
        case .live:
            self.headerBarSelection = .none
        }
    }
    
    @objc func didTapStatsButtonHeaderView() {
        switch self.headerBarSelection {
        case .none, .live:
            self.headerBarSelection = .stats
        case .stats:
            self.headerBarSelection = .none
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
    
    @objc func didTapChatView() {
        self.openChatModal()
    }
    
    func openChatModal() {
        if UserSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func didTapBackSliderButton() {
        self.statsCollectionView.setContentOffset(CGPoint(x: -self.statsCollectionView.contentInset.left, y: 1), animated: true)
    }
    
    @IBAction private func didTapBackAction() {
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func didTapMoreOptionsButton() {
        
        if UserSessionStore.isUserLogged() {
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if Env.favoritesManager.isEventFavorite(eventId: self.viewModel.matchId) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.removeFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Add to favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.addFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            
            let shareAction: UIAlertAction = UIAlertAction(title: "Share event", style: .default) { [weak self] _ -> Void in
                self?.didTapShareButton()
            }
            actionSheetController.addAction(shareAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
            actionSheetController.addAction(cancelAction)
            
            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    private func didTapShareButton() {
        
        guard
            var match = self.viewModel.match
        else {
            return
        }
        
        if let viewController = self.marketGroupsViewControllers.first as? MarketGroupDetailsViewController, let market = viewController.firstMarket() {
            match.markets = [market]
        }
        
        self.sharedGameCardView.setupSharedCardInfo(withMatch: match)

        self.sharedGameCardView.isHidden = false
        
        let renderer = UIGraphicsImageRenderer(size: self.sharedGameCardView.bounds.size)
        let snapshot = renderer.image { _ in
            self.sharedGameCardView.drawHierarchy(in: self.sharedGameCardView.bounds, afterScreenUpdates: true)
        }
        
        let metadata = LPLinkMetadata()
        let urlMobile = Env.urlMobileShares
        
        if let matchUrl = URL(string: "\(urlMobile)/gamedetail/\(match.id)") {
            
            let imageProvider = NSItemProvider(object: snapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = matchUrl
            metadata.title = localized("check_this_game")
        }
        
        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)
        
        let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, snapshot], applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        shareActivityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.sharedGameCardView.isHidden = true
        }
        self.present(shareActivityViewController, animated: true, completion: nil)
        
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
        
        self.isLiveFieldReady = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.matchFieldWebView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
            if complete != nil {
                self.recalculateWebview()
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

extension MatchDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfStatsSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfStatsRows(forSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(MatchStatsCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        
        if let jsonData = self.viewModel.jsonData(forIndexPath: indexPath) {
            cell.setupStatsLine(withjson: jsonData)
        }
        
        if let match = self.viewModel.match {
            cell.setupWithTeams(homeTeamName: match.homeParticipant.name, awayTeamName: match.awayParticipant.name)
        }
        
        if let marketStatsTitle = self.viewModel.marketStatsTitle(forIndexPath: indexPath) {
            cell.setupWithMarketTitle(title: marketStatsTitle)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.size.width
        var width = screenWidth*0.83
        
        if width > 390 {
            width = 390
        }
        return CGSize(width: width, height: collectionView.frame.size.height - 4)
    }
    
}

extension MatchDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.statsCollectionView {
            let screenWidth = UIScreen.main.bounds.size.width
            let width = screenWidth*0.6
            
            if scrollView.contentOffset.x > width {
                if !self.showingStatsBackSliderView {
                    self.showingStatsBackSliderView = true
                    UIView.animate(withDuration: 0.2) {
                        self.statsBackSliderView.alpha = 1.0
                    }
                }
            }
            else {
                if self.showingStatsBackSliderView {
                    self.showingStatsBackSliderView = false
                    UIView.animate(withDuration: 0.2) {
                        self.statsBackSliderView.alpha = 0.0
                    }
                }
            }
        }
    }
}
