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
import ServicesProvider

class MatchDetailsViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var headerDetailView: UIView!
    @IBOutlet private var headerDetailTopView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var shareButton: UIButton!

    @IBOutlet private var headerCompetitionDetailView: UIView!
    @IBOutlet private var headerCompetitionLabel: UILabel!
    @IBOutlet private var headerCompetitionSportImageView: UIImageView!
    @IBOutlet private var headerCompetitionImageView: UIImageView!

    @IBOutlet private var headerDetailStackView: UIStackView!
    @IBOutlet private var headerDetailHomeView: UIView!
    @IBOutlet private var headerDetailHomeLabel: UILabel!
    @IBOutlet private var headerDetailAwayView: UIView!
    @IBOutlet private var headerDetailAwayLabel: UILabel!

    @IBOutlet private var homeServingIndicatorView: UIView!
    @IBOutlet private var awayServingIndicatorView: UIView!

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
    @IBOutlet private var fieldExpandImageView: UIImageView!

    @IBOutlet private var headerStatsButtonBaseView: UIView!
    @IBOutlet private var statsButtonLabel: UILabel!
    @IBOutlet private var statsButtonImageView: UIImageView!

    @IBOutlet private var accountValueView: UIView!
    @IBOutlet private var accountPlusView: UIView!
    @IBOutlet private var accountValueLabel: UILabel!
    @IBOutlet private var accountPlusImageView: UIImageView!

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

    @IBOutlet private var marketTypesBaseView: UIView!

    private var chipsTypeView: ChipsTypeView

    private lazy var backgroundGradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @IBOutlet private var marketGroupsPagedBaseView: UIView!
    private var marketGroupsPagedViewController: UIPageViewController

    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    @IBOutlet private var matchNotAvailableView: UIView!
    @IBOutlet private var matchNotAvailableLabel: UILabel!

    @IBOutlet private var marketsNotAvailableView: UIView!
    @IBOutlet private var marketsNotAvailableLabel: UILabel!

    @IBOutlet private var homeRedCardImage: UIImageView!
    @IBOutlet private var awayRedCardImage: UIImageView!
    @IBOutlet private var homeRedCardLabel: UILabel!
    @IBOutlet private var awayRedCardsLabel: UILabel!

    @IBOutlet private var marketsStackView: UIStackView!

    // New top details view
    @IBOutlet private weak var topSeparatorAlphaLineView: FadingView!
    @IBOutlet private weak var matchDetailsContentView: UIView!
    @IBOutlet private weak var homeTeamLabel: UILabel!
    @IBOutlet private weak var awayTeamLabel: UILabel!
    @IBOutlet private weak var liveTimeLabel: UILabel!
    @IBOutlet private weak var preLiveDetailsView: UIView!
    @IBOutlet private weak var preLiveDateLabel: UILabel!
    @IBOutlet private weak var preLiveTimeLabel: UILabel!
    @IBOutlet private weak var liveDetailsView: UIView!
    @IBOutlet private weak var scoreView: ScoreView!

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

    // Tooltip views
    lazy var mixMatchInfoDialogView: InfoDialogView = {
        let view = InfoDialogView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("mix_match_tooltip_description"))
        return view
    }()

    var didShowMixMatchTooltip: Bool = false
    // =========================================================================
    // Header bar and buttons logic
    // =========================================================================
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
                self.fieldExpandImageView.image = UIImage(named: "arrow_up_icon")
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
            }
            else {
                self.fieldExpandImageView.image = UIImage(named: "arrow_down_icon")
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
                self.matchFieldWebViewHeight.constant = 0
            }

            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    private var matchMode: MatchDetailsViewModel.MatchMode = .preLive {
        didSet {
            if self.matchMode == .preLive {
                self.headerDetailLiveView.isHidden = true
                self.headerDetailPreliveView.isHidden = false

                self.liveButtonLabel.text = localized("statistics")
            }
            else {
                self.headerDetailPreliveView.isHidden = true
                self.headerDetailLiveView.isHidden = false

                self.liveButtonLabel.text = localized("live_stats")
            }
        }
    }

    // ScrollView content offset
    private var lastContentOffset: CGFloat = 0
    private var autoScrollEnabled: Bool = true

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
                self.liveButtonLabel.textColor = UIColor.App.textPrimary
                self.liveButtonImageView.setImageColor(color: UIColor.App.textPrimary)
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
                //
                self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
                self.statsButtonLabel.textColor = UIColor.App.textSecondary
                self.statsButtonImageView.setImageColor(color: UIColor.App.textSecondary)
                //

                self.isStatsViewExpanded = false
                self.isMatchFieldExpanded = false

                self.headerStatsButtonBaseView.isHidden = true

            case .live:
                self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
                self.liveButtonLabel.textColor = UIColor.App.textPrimary
                self.liveButtonImageView.setImageColor(color: UIColor.App.textPrimary)
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
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
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textSecondary)
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
            if self.isLiveFieldReady {
                self.matchFieldLoadingView.stopAnimating()

                if !oldValue {
                    self.expandLiveFieldIfNeeded()
                }
            }
            else {
                self.matchFieldLoadingView.startAnimating()
            }
        }
    }

    //
    // ======
    private var matchFieldMaximumHeight: CGFloat {
        if self.isMatchFieldExpanded {
            return self.matchFielHeight
        }
        else {
            return 0.0
        }
    }
    private var matchFieldMinimumHeight: CGFloat {
        return 0.0
    }

    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: InnerScrollDragDirection = .up
    //
    //

    // =========================================================================

    private var marketGroupsViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: MatchDetailsViewModel

    private var cancellables = Set<AnyCancellable>()

    var showMixMatchDefault: Bool = false

    // MARK: - Lifetime and Cycle
    init(viewModel: MatchDetailsViewModel) {
        self.viewModel = viewModel

        self.chipsTypeView = ChipsTypeView(viewModel: self.viewModel.chipsTypeViewModel)

        self.marketGroupsPagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                                    navigationOrientation: .horizontal,
                                                                    options: nil)

        super.init(nibName: "MatchDetailsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNotifications()

        // Setup fonts
        self.matchNotAvailableLabel.font = AppFont.with(type: .bold, size: 18)
        self.accountValueLabel.font = AppFont.with(type: .heavy, size: 12)
        self.homeTeamLabel.font = AppFont.with(type: .heavy, size: 16)
        self.awayTeamLabel.font = AppFont.with(type: .heavy, size: 16)
        self.preLiveDateLabel.font = AppFont.with(type: .bold, size: 14)
        self.preLiveTimeLabel.font = AppFont.with(type: .heavy, size: 16)
        self.liveTimeLabel.font = AppFont.with(type: .heavy, size: 10)
        self.liveButtonLabel.font = AppFont.with(type: .bold, size: 13)
        self.statsButtonLabel.font = AppFont.with(type: .bold, size: 13)
        self.statsNotFoundLabel.font = AppFont.with(type: .medium, size: 17)
        self.marketsNotAvailableLabel.font = AppFont.with(type: .bold, size: 18)

        self.view.transitionId = "SeeMoreToMatchDetails"

        self.homeTeamLabel.text = ""
        self.awayTeamLabel.text = ""

        //
        self.addChildViewController(marketGroupsPagedViewController, toView: marketGroupsPagedBaseView)

        //
        self.view.insertSubview(self.backgroundGradientView, at: 0)

        NSLayoutConstraint.activate([
            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.headerDetailView.bottomAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        //

        //
        self.matchFieldWebViewHeight.constant = 0

        //
        self.matchNotAvailableView.isHidden = true

        self.marketsNotAvailableView.isHidden = true
        self.marketsNotAvailableLabel.text = localized("markets_not_available")

        self.matchFieldBaseView.isHidden = false
        self.statsBaseView.isHidden = false

        //
        self.isLiveFieldReady = false
        self.shouldShowLiveFieldWebView = false

        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        //
        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)

        self.shareButton.setTitle("", for: .normal)
        self.shareButton.setImage(UIImage(named: "more_options_icon"), for: .normal)

        self.headerCompetitionLabel.text = ""
        self.headerCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)

        self.headerCompetitionImageView.image = nil
        self.headerCompetitionImageView.layer.cornerRadius = self.headerCompetitionImageView.frame.width/2
        self.headerCompetitionImageView.contentMode = .scaleAspectFill
        self.headerCompetitionImageView.layer.borderWidth = 0.5

        self.headerDetailHomeLabel.text = localized("home_label_default")
        self.headerDetailHomeLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailHomeLabel.numberOfLines = 0

        self.headerDetailAwayLabel.text = localized("away_label_default")
        self.headerDetailAwayLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailAwayLabel.numberOfLines = 0

        self.headerDetailPreliveTopLabel.text = localized("match_label_default")
        self.headerDetailPreliveTopLabel.font = AppFont.with(type: .semibold, size: 12)

        self.headerDetailPreliveBottomLabel.text = "00:00"
        self.headerDetailPreliveBottomLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveTopLabel.text = "'0 - 0'"
        self.headerDetailLiveTopLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveBottomLabel.text = localized("match_start_label_default")
        self.headerDetailLiveBottomLabel.font = AppFont.with(type: .semibold, size: 12)
        self.headerDetailLiveBottomLabel.numberOfLines = 0

        self.liveButtonLabel.text = ""

        self.homeRedCardImage.isHidden = true
        self.awayRedCardImage.isHidden = true
        self.homeRedCardLabel.isHidden = true
        self.awayRedCardsLabel.isHidden = true

        // Default to Pre Live
        self.headerDetailLiveView.isHidden = true
        self.headerDetailPreliveView.isHidden = false

        // Market Types base view
        self.addChildViewController(self.marketGroupsPagedViewController, toView: self.marketGroupsPagedBaseView)

        self.marketTypesBaseView.addSubview(self.chipsTypeView)
        NSLayoutConstraint.activate([
            self.chipsTypeView.leadingAnchor.constraint(equalTo: self.marketTypesBaseView.leadingAnchor),
            self.chipsTypeView.trailingAnchor.constraint(equalTo: self.marketTypesBaseView.trailingAnchor),
            self.chipsTypeView.topAnchor.constraint(equalTo: self.marketTypesBaseView.topAnchor),
            self.chipsTypeView.bottomAnchor.constraint(equalTo: self.marketTypesBaseView.bottomAnchor),
        ])

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

        let competitionDetailTapGesture = UITapGestureRecognizer(target: self, action: #selector(openCompetitionsDetails))
        headerCompetitionDetailView.addGestureRecognizer(competitionDetailTapGesture)

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

        let didTapLiveGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveButtonHeaderView))
        self.headerLiveButtonBaseView.addGestureRecognizer(didTapLiveGesture)

        let didTapStatsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStatsButtonHeaderView))
        self.headerStatsButtonBaseView.addGestureRecognizer(didTapStatsGesture)

        self.headerBarSelection = .none

        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        //
        // Add loading view controller
        self.loadingSpinnerViewController.willMove(toParent: self)
        self.addChild(self.loadingSpinnerViewController)

        self.loadingSpinnerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingSpinnerViewController.view)

        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: self.loadingSpinnerViewController.view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingSpinnerViewController.view.trailingAnchor),
            self.headerDetailView.bottomAnchor.constraint(equalTo: self.loadingSpinnerViewController.view.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingSpinnerViewController.view.bottomAnchor)
        ])

        self.loadingSpinnerViewController.didMove(toParent: self)

        // Start loading
        self.loadingSpinnerViewController.startAnimating()
        self.loadingSpinnerViewController.view.isHidden = false
        //
        //

        // Shared Game
        self.view.sendSubviewToBack(self.sharedGameCardView)

        //
        self.view.bringSubviewToFront(self.matchNotAvailableView)

        // Tooltip
        self.view.addSubview(self.mixMatchInfoDialogView)

        NSLayoutConstraint.activate([

            self.mixMatchInfoDialogView.bottomAnchor.constraint(equalTo: self.chipsTypeView.topAnchor, constant: 5),
            self.mixMatchInfoDialogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.mixMatchInfoDialogView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20),
            self.mixMatchInfoDialogView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])

        self.mixMatchInfoDialogView.alpha = 0

        if self.showMixMatchDefault {
            self.currentPageViewControllerIndex = 1
        }
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

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.refreshViewModel()
            }
            .store(in: &self.cancellables)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.awayServingIndicatorView.layer.cornerRadius = self.awayServingIndicatorView.frame.size.width / 2
        self.homeServingIndicatorView.layer.cornerRadius = self.homeServingIndicatorView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.gameHeader
        self.headerDetailView.backgroundColor = UIColor.App.gameHeader
        self.headerDetailTopView.backgroundColor = .clear
        self.backButton.tintColor = UIColor.App.textPrimary

        self.headerCompetitionDetailView.backgroundColor = .clear
        self.headerCompetitionLabel.textColor = UIColor.App.textSecondary
        self.headerCompetitionSportImageView.setTintColor(color: UIColor.App.textPrimary)

        self.headerCompetitionImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor

        self.headerDetailStackView.backgroundColor = .clear
        self.headerDetailHomeView.backgroundColor = .clear
        self.headerDetailHomeLabel.textColor = UIColor.App.textPrimary
        self.headerDetailAwayView.backgroundColor = .clear
        self.headerDetailAwayLabel.textColor = UIColor.App.textPrimary

        self.awayServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary
        self.homeServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary

        self.headerDetailMiddleView.backgroundColor = .clear
        self.headerDetailMiddleStackView.backgroundColor = .clear
        self.headerDetailPreliveView.backgroundColor = .clear
        self.headerDetailPreliveTopLabel.textColor = UIColor.App.textSecondary
        self.headerDetailPreliveBottomLabel.textColor = UIColor.App.textPrimary
        self.headerDetailLiveView.backgroundColor = .clear
        self.headerDetailLiveTopLabel.textColor = UIColor.App.textPrimary
        self.headerDetailLiveBottomLabel.textColor = UIColor.App.textSecondary

        self.headerButtonsBaseView.backgroundColor = UIColor.App.separatorLine
        self.headerButtonsStackView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerLiveButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.headerStatsButtonBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.accountValueView.backgroundColor = UIColor.App.backgroundBorder
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        //
        if TargetVariables.shouldUseGradientBackgrounds {
            self.backgroundGradientView.colors = [(UIColor.App.backgroundGradient1, NSNumber(0.0)),
                                                  (UIColor.App.backgroundGradient2, NSNumber(1.0))]
        }
        else {
            self.backgroundGradientView.colors = []
            self.backgroundGradientView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.marketGroupsPagedBaseView.backgroundColor = .clear

        // Market List CollectionView
        self.chipsTypeView.backgroundColor = UIColor.App.pillNavigation
        self.marketTypesBaseView.backgroundColor = UIColor.App.pillNavigation

        //
        self.matchFieldBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.matchFieldWebView.backgroundColor = UIColor.App.backgroundTertiary

        self.matchNotAvailableView.backgroundColor = .clear
        self.matchNotAvailableLabel.textColor = UIColor.App.textPrimary

        self.marketsNotAvailableView.backgroundColor = .clear
        self.marketsNotAvailableLabel.textColor = UIColor.App.textPrimary

        self.matchFieldLoadingView.tintColor = .gray

        self.statsBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.statsCollectionBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.statsCollectionView.backgroundColor = UIColor.App.backgroundPrimary
        self.statsBackSliderView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.statsNotFoundLabel.textColor = UIColor.App.textPrimary

        self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
        self.fieldExpandImageView.tintColor = UIColor.App.textPrimary

        // New top details view
        self.topSeparatorAlphaLineView.colors = [.clear, .black, .black, .clear]
        self.topSeparatorAlphaLineView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.topSeparatorAlphaLineView.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.topSeparatorAlphaLineView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary

        self.matchDetailsContentView.backgroundColor = .clear

        self.homeTeamLabel.textColor = UIColor.App.textPrimary

        self.awayTeamLabel.textColor = UIColor.App.textPrimary

        self.liveTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary

        self.preLiveDetailsView.backgroundColor = .clear

        self.preLiveDateLabel.textColor = UIColor.App.textSecondary

        self.preLiveTimeLabel.textColor = UIColor.App.textPrimary

        self.liveDetailsView.backgroundColor = .clear

        self.scoreView.backgroundColor = .clear
        self.scoreView.setupWithTheme()

    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: MatchDetailsViewModel) {

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil { // Is Logged In
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.marketGroupsState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroupState in
                switch marketGroupState {
                case .idle, .loading:
                    break
                case let .loaded(marketGroups):
                    self?.showMarkets()
                    self?.reloadMarketGroupDetails(marketGroups)
                    self?.reloadRecommendedBetbuilders()
                case .failed:
                    self?.showMarketsNotAvailableView()
                    self?.reloadMarketGroupDetails([])
                }
            }
            .store(in: &self.cancellables)
//
        self.viewModel.selectedMarketTypeIndexPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                if let newIndex = newIndex {
                    self?.scrollToMarketDetailViewController(atIndex: newIndex)
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.matchPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loadableMatch in
                switch loadableMatch {
                case .idle, .loading:
                    break
                case .loaded(let match):
                    switch match.status {
                    case .notStarted, .ended, .unknown:
                        self?.matchMode = .preLive
                    case .inProgress:
                        self?.matchMode = .live
                        self?.reloadMarketsWithLiveMatch(match: match)
                    }

                    self?.setupHeaderDetails(withMatch: match)

                    let theme = self?.traitCollection.userInterfaceStyle
                    viewModel.getFieldWidget(isDarkTheme: theme == .dark ? true : false)

                    self?.statsCollectionView.reloadData()

//                    self?.loadingSpinnerViewController.view.isHidden = true
//                    self?.loadingSpinnerViewController.stopAnimating()
                case .failed:
//                    self?.loadingSpinnerViewController.view.isHidden = true
//                    self?.loadingSpinnerViewController.stopAnimating()

                    self?.showMatchNotAvailableView()
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.matchStatsUpdatedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadStatsCollectionView()
            })
            .store(in: &self.cancellables)
        
        self.viewModel.recommendedBetBuilders
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] recommendedBetBuilder in
                
                if recommendedBetBuilder.isNotEmpty {
                    self?.configureRecommendedBetBuilder(recommendedBetBuilder: recommendedBetBuilder)
                }
            })
            .store(in: &cancellables)

        self.viewModel.homeRedCardsScorePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] homeScoreValue in
                if homeScoreValue != "0" {
                    self?.homeRedCardImage.isHidden = false
                    self?.homeRedCardLabel.text = homeScoreValue
                    self?.homeRedCardLabel.isHidden = false
                }
                else {
                    self?.homeRedCardImage.isHidden = true
                    self?.homeRedCardLabel.isHidden = true
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.awayRedCardsScorePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] awayScoreValue in
                if awayScoreValue != "0" {
                    self?.awayRedCardImage.isHidden = false
                    self?.awayRedCardsLabel.text = awayScoreValue
                    self?.awayRedCardsLabel.isHidden = false
                }
                else {
                    self?.awayRedCardImage.isHidden = true
                    self?.awayRedCardsLabel.isHidden = true
                }

            })
            .store(in: &self.cancellables)

        self.viewModel.matchDetailedScores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] detailedScoresList in
                guard let self = self else { return }
                if let matchScores = detailedScoresList.first {
                    if self.scoreView.sportCode != matchScores.key {
                        self.scoreView.sportCode = matchScores.key
                    }
                    self.scoreView.updateScores(matchScores.value)
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.activePlayerServePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activePlayerServe in
                guard let self = self else { return }

                switch activePlayerServe {
                case .home:
                    self.homeServingIndicatorView.isHidden = false
                    self.awayServingIndicatorView.isHidden = true
                case .away:
                    self.homeServingIndicatorView.isHidden = true
                    self.awayServingIndicatorView.isHidden = false
                case .none:
                    self.homeServingIndicatorView.isHidden = true
                    self.awayServingIndicatorView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        self.viewModel.shouldRenderFieldWidget
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldRender in
                if shouldRender {
                    self?.headerButtonsBaseView.isHidden = false
                    self?.setupMatchField()
                }
                else {
                    self?.headerButtonsBaseView.isHidden = true
                }
            })
            .store(in: &self.cancellables)

        self.viewModel.scrollToTopAction = { [weak self] indexRow in

            if let marketGroupViewController = self?.marketGroupsViewControllers[safe: indexRow] as? MarketGroupDetailsViewController {

                marketGroupViewController.scrollToTop()
            }
        }

        self.viewModel.shouldShowTabTooltip = { [weak self] in

            if let didShowMixMatchTooltip = self?.didShowMixMatchTooltip,
               !didShowMixMatchTooltip {

                UIView.animate(withDuration: 0.5, animations: {
                    self?.mixMatchInfoDialogView.alpha = 1
                    self?.didShowMixMatchTooltip = true
                }) { (completed) in
                    if completed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            UIView.animate(withDuration: 0.5) {
                                self?.mixMatchInfoDialogView.alpha = 0
                            }
                        }
                    }
                }

            }

        }
        
        self.viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                if isLoading {
                    self?.loadingSpinnerViewController.view.isHidden = false
                    self?.loadingSpinnerViewController.startAnimating()
                }
                else {
                    self?.loadingSpinnerViewController.view.isHidden = true
                    self?.loadingSpinnerViewController.stopAnimating()
                }
            })
            .store(in: &cancellables)

    }

    private func refreshViewModel() {
        self.viewModel.forceRefreshData()
    }

    func reloadMarketsWithLiveMatch(match: Match) {
        for viewController in marketGroupsViewControllers {
            if let marketGroupViewController = viewController as? MarketGroupDetailsViewController {
                marketGroupViewController.setUpdatedMatch(match: match)
            }
        }
    }

    func reloadMarketGroupDetails(_ marketGroups: [MarketGroup]) {
        
        guard let match = self.viewModel.match else {
            return
        }

        self.marketGroupsViewControllers = []

        for marketGroup in marketGroups {
            if let groupKey = marketGroup.groupKey {

                let viewModel = MarketGroupDetailsViewModel(match: match, marketGroupId: groupKey)

                if let groupMarkets = marketGroup.markets {
                    viewModel.availableMarkets = groupMarkets
                }

                let marketGroupDetailsViewController = MarketGroupDetailsViewController(viewModel: viewModel)
                marketGroupDetailsViewController.innerTableViewScrollDelegate = self

                self.marketGroupsViewControllers.append(marketGroupDetailsViewController)
            }
        }

        if self.showMixMatchDefault {
            if let firstViewController = self.marketGroupsViewControllers[safe: 1] {
                self.marketGroupsPagedViewController.setViewControllers([firstViewController],
                                                                        direction: .forward,
                                                                        animated: false,
                                                                        completion: nil)
            }
        }
        else {
            if let firstViewController = self.marketGroupsViewControllers.first {
                self.marketGroupsPagedViewController.setViewControllers([firstViewController],
                                                                        direction: .forward,
                                                                        animated: false,
                                                                        completion: nil)
            }
        }

    }

    func reloadMarketGroupDetailsContent() {
        for marketGroupsViewController in marketGroupsViewControllers {
            (marketGroupsViewController as? MarketGroupDetailsViewController)?.reloadContent()
        }
    }
    
    func reloadRecommendedBetbuilders() {
        
        let recommendedBetbuilder = self.viewModel.recommendedBetBuilders.value
        
        self.configureRecommendedBetBuilder(recommendedBetBuilder: recommendedBetbuilder)
        
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
    }
    
    func configureRecommendedBetBuilder(recommendedBetBuilder: [RecommendedBetBuilder]) {
        
        for marketGroupsViewController in self.marketGroupsViewControllers {
            if let marketGroupDetailsViewController = marketGroupsViewController as? MarketGroupDetailsViewController,
               marketGroupDetailsViewController.getMarketGroupId() == "Popular" {
                marketGroupDetailsViewController.setupRecommendedBetBuilder(recommendedBetBuilder: recommendedBetBuilder)
            }
        }
    }

    func setupMatchField() {

        guard
            self.viewModel.match != nil,
            !self.isLiveFieldReady // if we already loadd the live field we should not reload it
        else {
            return
        }

        if let fieldWidget = self.viewModel.fieldWidgetRenderDataType {

            self.matchFieldLoadingView.startAnimating()

            self.shouldShowLiveFieldWebView = true

            switch fieldWidget {
            case .url(let url):
                let urlRequest = URLRequest(url: url)
                self.matchFieldWebView.load(urlRequest)
            case .htmlString(let url, let htmlString):
                self.matchFieldWebView.loadHTMLString(htmlString, baseURL: url)
            }
        }
        else {
            self.shouldShowLiveFieldWebView = false
        }

    }

    func setupHeaderDetails(withMatch match: Match) {
        self.headerDetailHomeLabel.text = match.homeParticipant.name
        self.homeTeamLabel.text = match.homeParticipant.name

        self.headerDetailAwayLabel.text = match.awayParticipant.name
        self.awayTeamLabel.text = match.awayParticipant.name

        self.headerCompetitionLabel.text = match.competitionName

        let assetName = Assets.flagName(withCountryCode: match.venue?.isoCode ?? match.venue?.id ?? "")
        self.headerCompetitionImageView.image =  UIImage(named: assetName)

        if let sportIconImage = UIImage(named: "sport_type_icon_\(match.sport.id)") {
            self.headerCompetitionSportImageView.image =  sportIconImage
        }
        else if let defaultImage = UIImage(named: "sport_type_icon_default") {
            self.headerCompetitionSportImageView.image = defaultImage
        }
        else {
            self.headerCompetitionSportImageView.image = nil
        }

        self.headerCompetitionSportImageView.setTintColor(color: UIColor.App.textPrimary)

        // With new details view
        if self.matchMode == .preLive {
            if let date = match.date {
                let startDateString = MatchWidgetCellViewModel.startDateString(fromDate: date)
                self.headerDetailPreliveTopLabel.text = startDateString
                self.preLiveDateLabel.text = startDateString

                let hourDateString = MatchWidgetCellViewModel.hourDateFormatter.string(from: date)
                self.headerDetailPreliveBottomLabel.text = hourDateString
                self.preLiveTimeLabel.text = hourDateString
            }

            self.liveTimeLabel.isHidden = true

            self.preLiveDetailsView.isHidden = false
            self.liveDetailsView.isHidden = true
        }
        else {
            self.headerDetailLiveTopLabel.text = self.viewModel.matchScore
            self.headerDetailLiveBottomLabel.text = self.viewModel.matchTimeDetails

            self.liveTimeLabel.text = self.viewModel.matchTimeDetails
            self.liveTimeLabel.isHidden = false

            self.preLiveDetailsView.isHidden = true
            self.liveDetailsView.isHidden = false
        }

    }

    func expandLiveFieldIfNeeded() {
        if self.viewModel.isLiveMatch {
            self.headerBarSelection = .live
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

    func showMarkets() {
        self.marketGroupsPagedBaseView.isHidden = false
        self.chipsTypeView.isHidden = false
        self.marketsNotAvailableView.isHidden = true
        self.matchNotAvailableView.isHidden = true
    }

    func showMatchNotAvailableView() {
        self.shareButton.isHidden = true
        self.marketGroupsPagedBaseView.isHidden = true
        self.chipsTypeView.isHidden = true
        self.marketsNotAvailableView.isHidden = true
        self.matchNotAvailableView.isHidden = false
    }

    func showMarketsNotAvailableView() {
        self.marketGroupsPagedBaseView.isHidden = true
        self.chipsTypeView.isHidden = true
        self.marketsNotAvailableView.isHidden = false
        self.matchNotAvailableView.isHidden = true
    }

    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadMarketGroupDetailsContent()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    @objc private func openCompetitionsDetails() {

//        if let match = self.viewModel.match {
//            let competitionDetailsViewModel = CompetitionDetailsViewModel(competitionsIds: [match.competitionId], sport: match.sport)
//            let competitionDetailsViewController = CompetitionDetailsViewController(viewModel: competitionDetailsViewModel)
//            self.navigationController?.pushViewController(competitionDetailsViewController, animated: true)
//        }

    }

    @objc func didTapChatView() {
        self.openChatModal()
    }

    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
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

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
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
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if Env.userSessionStore.isUserLogged() {

            if Env.favoritesManager.isEventFavorite(eventId: self.viewModel.matchId) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.removeFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ -> Void in
                    Env.favoritesManager.addFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
        }

        let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ -> Void in
            self?.didTapShareButton()
        }
        actionSheetController.addAction(shareAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ -> Void in }
        actionSheetController.addAction(cancelAction)

        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheetController, animated: true, completion: nil)
//        }
//        else {
//            let loginViewController = Router.navigationController(with: LoginViewController())
//            self.present(loginViewController, animated: true, completion: nil)
//        }
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

        let matchSlugUrl = self.generateUrlSlug(match: match)

        if let matchUrl = URL(string: matchSlugUrl) {

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

    private func generateUrlSlug(match: Match) -> String {

        var sportName = match.sportName?.lowercased() ?? ""

        if let realSportName = Env.sportsStore.getActiveSports().filter({
            $0.alphaId == match.sport.alphaId
        }).compactMap({
            return $0.name
        }).first {
            sportName = realSportName.lowercased()
        }

        let competitionName = match.competitionName.slugify()

        let homeTeamName = match.homeParticipant.name.slugify()

        let awayTeamName = match.awayParticipant.name.slugify()

        let matchName = "\(homeTeamName)-vs-\(awayTeamName)"

        let matchStatus = self.matchMode == .preLive ? "competitions" : "live"

        let fullString = "\(TargetVariables.clientBaseUrl)/\(Locale.current.languageCode ?? "fr")/\(matchStatus)/\(sportName)/\(competitionName)/\(match.competitionId)/\(matchName)/\(match.id)"

        return fullString
    }

//    func slugify(_ inputString: String) -> String {
//        let normalizedString = inputString.folding(options: .diacriticInsensitive, locale: .current)
//        let withoutSpecialCharacters = normalizedString.replacingOccurrences(of: "[^a-zA-Z0-9\\s-]", with: "", options: .regularExpression, range: nil)
//        let lowercasedString = withoutSpecialCharacters.lowercased()
//        let trimmedString = lowercasedString.trimmingCharacters(in: .whitespacesAndNewlines)
//        let replacingSpacesWithDash = trimmedString.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression, range: nil)
//        let removingConsecutiveDashes = replacingSpacesWithDash.replacingOccurrences(of: "--+", with: "-", options: .regularExpression, range: nil)
//
//        return removingConsecutiveDashes
//    }

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
        executeDelayed(1) {
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
        if heigth < 100 {
            self.recalculateWebview()
        }
        else {
            self.matchFielHeight = heigth
            self.isLiveFieldReady = true
        }
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

extension MatchDetailsViewController: InnerTableViewScrollDelegate {

    var currentHeaderHeight: CGFloat {
        return matchFieldWebViewHeight.constant
    }

//    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
//        matchFieldWebViewHeight.constant -= scrollDistance
//        if matchFieldWebViewHeight.constant > matchFieldMaximumHeight {
//            matchFieldWebViewHeight.constant = matchFieldMaximumHeight
//        }
//
//        if matchFieldWebViewHeight.constant < matchFieldMinimumHeight {
//            matchFieldWebViewHeight.constant = matchFieldMinimumHeight
//        }
//    }

    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        let newHeight = matchFieldWebViewHeight.constant - scrollDistance

        if newHeight > matchFieldMaximumHeight {
            if matchFieldWebViewHeight.constant != matchFieldMaximumHeight {
                matchFieldWebViewHeight.constant = matchFieldMaximumHeight
            }
        }
        else if newHeight < matchFieldMinimumHeight {
            if matchFieldWebViewHeight.constant != matchFieldMinimumHeight {
                matchFieldWebViewHeight.constant = matchFieldMinimumHeight
            }
        }
        else {
            matchFieldWebViewHeight.constant = newHeight
        }
    }

    func innerTableViewScrollEnded(withScrollDirection scrollDirection: InnerScrollDragDirection) {

        let topViewHeight = self.matchFieldWebViewHeight.constant

        if topViewHeight <= self.matchFieldMinimumHeight + 20 {
            self.scrollToFinalView()
        }
        else if topViewHeight <= self.matchFieldMaximumHeight - 20 {
            switch scrollDirection {
            case .down:
                self.scrollToInitialView()
            case .up:
                self.scrollToFinalView()
            }
        }
        else {
            self.scrollToInitialView()
        }
    }

    func scrollToInitialView() {

        let topViewCurrentHeight = self.matchFieldWebView.frame.height
        let distanceToBeMoved = abs(topViewCurrentHeight - self.matchFieldMaximumHeight)

        var time = distanceToBeMoved / 500
        if time < 0.25 {
            time = 0.25
        }

        self.matchFieldWebViewHeight.constant = self.matchFieldMaximumHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }

    func scrollToFinalView() {
        let topViewCurrentHeight = self.matchFieldWebView.frame.height
        let distanceToBeMoved = abs(topViewCurrentHeight - self.matchFieldMinimumHeight)

        var time = distanceToBeMoved / 500
        if time < 0.25 {
            time = 0.25
        }
        self.matchFieldWebViewHeight.constant = self.matchFieldMinimumHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }

}

//
enum InnerScrollDragDirection {
    case up
    case down
}

protocol InnerTableViewScrollDelegate: AnyObject {
    var currentHeaderHeight: CGFloat { get }
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: InnerScrollDragDirection)
}
