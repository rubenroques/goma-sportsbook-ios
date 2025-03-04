//
//  MatchDetailsViewController+Programmatic
//  Sportsbook
//

import UIKit
import Combine
import LinkPresentation
import WebKit
import ServicesProvider

class MatchDetailsViewController: UIViewController {

    // MARK: - Private Properties

    // Top and header views
    private lazy var topView: UIView = Self.createTopView()
    private lazy var headerDetailView: UIView = Self.createHeaderDetailView()
    private lazy var headerDetailTopView: UIView = Self.createHeaderDetailTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var shareButton: UIButton = Self.createShareButton()

    // Competition details
    private lazy var headerCompetitionDetailView: UIView = Self.createHeaderCompetitionDetailView()
    private lazy var headerCompetitionLabel: UILabel = Self.createHeaderCompetitionLabel()
    private lazy var headerCompetitionSportImageView: UIImageView = Self.createHeaderCompetitionSportImageView()
    private lazy var headerCompetitionCountryImageView: UIImageView = Self.createHeaderCompetitionCountryImageView()

    // Header details
    private lazy var headerDetailStackView: UIStackView = Self.createHeaderDetailStackView()
    private lazy var headerDetailHomeView: UIView = Self.createHeaderDetailHomeView()
    private lazy var headerDetailHomeLabel: UILabel = Self.createHeaderDetailHomeLabel()
    private lazy var headerDetailAwayView: UIView = Self.createHeaderDetailAwayView()
    private lazy var headerDetailAwayLabel: UILabel = Self.createHeaderDetailAwayLabel()

    // Serving indicators
    private lazy var homeServingIndicatorView: UIView = Self.createHomeServingIndicatorView()
    private lazy var awayServingIndicatorView: UIView = Self.createAwayServingIndicatorView()

    // Header middle section
    private lazy var headerDetailMiddleView: UIView = Self.createHeaderDetailMiddleView()
    private lazy var headerDetailMiddleStackView: UIStackView = Self.createHeaderDetailMiddleStackView()

    // Pre-live details
    private lazy var headerDetailPreliveView: UIView = Self.createHeaderDetailPreliveView()
    private lazy var headerDetailPreliveTopLabel: UILabel = Self.createHeaderDetailPreliveTopLabel()
    private lazy var headerDetailPreliveBottomLabel: UILabel = Self.createHeaderDetailPreliveBottomLabel()

    // Live details
    private lazy var headerDetailLiveView: UIView = Self.createHeaderDetailLiveView()
    private lazy var headerDetailLiveTopLabel: UILabel = Self.createHeaderDetailLiveTopLabel()
    private lazy var headerDetailLiveBottomLabel: UILabel = Self.createHeaderDetailLiveBottomLabel()

    // Header buttons
    private lazy var headerButtonsBaseView: UIView = Self.createHeaderButtonsBaseView()
    private lazy var headerButtonsStackView: UIStackView = Self.createHeaderButtonsStackView()
    private lazy var headerLiveButtonBaseView: UIView = Self.createHeaderLiveButtonBaseView()
    private lazy var liveButtonLabel: UILabel = Self.createLiveButtonLabel()
    private lazy var liveButtonImageView: UIImageView = Self.createLiveButtonImageView()
    private lazy var fieldExpandImageView: UIImageView = Self.createFieldExpandImageView()

    // Stats button section
    private lazy var headerStatsButtonBaseView: UIView = Self.createHeaderStatsButtonBaseView()
    private lazy var statsButtonLabel: UILabel = Self.createStatsButtonLabel()
    private lazy var statsButtonImageView: UIImageView = Self.createStatsButtonImageView()

    // Account section
    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()

    // Match field section
    private lazy var matchFieldBaseView: UIView = Self.createMatchFieldBaseView()
    private lazy var matchFieldLoadingView: UIActivityIndicatorView = Self.createMatchFieldLoadingView()
    private lazy var matchFieldWebView: WKWebView = Self.createMatchFieldWebView()
    private lazy var matchFieldWebViewHeightConstraint: NSLayoutConstraint = Self.createMatchFieldWebViewHeightConstraintConstraint()

    // Stats section
    private lazy var statsBaseView: UIView = Self.createStatsBaseView()
    private lazy var statsCollectionBaseView: UIView = Self.createStatsCollectionBaseView()
    private lazy var statsCollectionView: UICollectionView = Self.createStatsCollectionView()
    private lazy var statsCollectionViewHeightConstraint: NSLayoutConstraint = Self.createStatsCollectionViewHeightConstraintConstraint()
    private lazy var statsBackSliderView: UIView = Self.createStatsBackSliderView()
    private lazy var statsNotFoundLabel: UILabel = Self.createStatsNotFoundLabel()

    // Market types section
    private lazy var marketTypesBaseView: UIView = Self.createMarketTypesBaseView()

    private var chipsTypeView: ChipsTypeView

    private lazy var backgroundGradientView: GradientView = Self.createBackgroundGradientView()

    // Market groups paged section
    private lazy var marketGroupsPagedBaseView: UIView = Self.createMarketGroupsPagedBaseView()
    private var marketGroupsPagedViewController: UIPageViewController

    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    // Match not available section
    private lazy var matchNotAvailableView: UIView = Self.createMatchNotAvailableView()
    private lazy var matchNotAvailableLabel: UILabel = Self.createMatchNotAvailableLabel()

    // Markets not available section
    private lazy var marketsNotAvailableView: UIView = Self.createMarketsNotAvailableView()
    private lazy var marketsNotAvailableLabel: UILabel = Self.createMarketsNotAvailableLabel()

    // Red card indicators
    private lazy var homeRedCardImage: UIImageView = Self.createHomeRedCardImage()
    private lazy var awayRedCardImage: UIImageView = Self.createAwayRedCardImage()
    private lazy var homeRedCardLabel: UILabel = Self.createHomeRedCardLabel()
    private lazy var awayRedCardsLabel: UILabel = Self.createAwayRedCardsLabel()

    // Markets stack
    private lazy var marketsStackView: UIStackView = Self.createMarketsStackView()

    // New top details view
    private lazy var topSeparatorAlphaLineView: FadingView = Self.createTopSeparatorAlphaLineView()
    private lazy var matchDetailsContentView: UIView = Self.createMatchDetailsContentView()
    private lazy var homeTeamLabel: UILabel = Self.createHomeTeamLabel()
    private lazy var awayTeamLabel: UILabel = Self.createAwayTeamLabel()
    private lazy var liveTimeLabel: UILabel = Self.createLiveTimeLabel()
    private lazy var preLiveDetailsView: UIView = Self.createPreLiveDetailsView()
    private lazy var preLiveDateLabel: UILabel = Self.createPreLiveDateLabel()
    private lazy var preLiveTimeLabel: UILabel = Self.createPreLiveTimeLabel()
    private lazy var liveDetailsView: UIView = Self.createLiveDetailsView()
    private lazy var scoreView: ScoreView = Self.createScoreView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()

    private lazy var sharedGameCardView: SharedGameCardView = Self.createSharedGameCardView()

    // Special reference to left and right gradient base views (possibly not needed in programmatic implementation)
    private var leftGradientBaseView: UIView?
    private var rightGradientBaseView: UIView?

    // Tooltip views
    lazy var mixMatchInfoDialogView: InfoDialogView = Self.createMixMatchInfoDialogView()

    // MARK: - Private Properties (State)

    private var showingStatsBackSliderView: Bool = false
    private var shouldShowStatsView = false
    private var isStatsViewExpanded: Bool = false {
        didSet {
            if isStatsViewExpanded {
                self.statsCollectionViewHeightConstraint.constant = 148
            }
            else {
                self.statsCollectionViewHeightConstraint.constant = 0
            }

            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

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
                self.matchFieldWebViewHeightConstraint.constant = matchFielHeight
                self.fieldExpandImageView.image = UIImage(named: "arrow_up_icon")
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
            }
            else {
                self.fieldExpandImageView.image = UIImage(named: "arrow_down_icon")
                self.fieldExpandImageView.setImageColor(color: UIColor.App.textPrimary)
                self.matchFieldWebViewHeightConstraint.constant = 0
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

    // Match field height calculations
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

    // Market groups and page control
    private var marketGroupsViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: MatchDetailsViewModel

    private var cancellables = Set<AnyCancellable>()

    var showMixMatchDefault: Bool = false

    // MARK: - Initialization and Lifecycle
    init(viewModel: MatchDetailsViewModel) {
        self.viewModel = viewModel

        self.chipsTypeView = ChipsTypeView(viewModel: self.viewModel.chipsTypeViewModel)

        self.marketGroupsPagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                                    navigationOrientation: .horizontal,
                                                                    options: nil)

        super.init(nibName: nil, bundle: nil)
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

        // Add child view controllers
        self.addChildViewController(marketGroupsPagedViewController, toView: marketGroupsPagedBaseView)
        self.view.insertSubview(self.backgroundGradientView, at: 0)

        setupSubviews()
        setupNotifications()
        setupFonts()
        setupEventHandlers()

        self.view.transitionId = "SeeMoreToMatchDetails"

        self.homeTeamLabel.text = ""
        self.awayTeamLabel.text = ""

        // Set initial UI states
        self.matchNotAvailableView.isHidden = true
        self.marketsNotAvailableView.isHidden = true
        self.marketsNotAvailableLabel.text = localized("markets_not_available")
        self.matchFieldBaseView.isHidden = false
        self.statsBaseView.isHidden = false

        // Initialize field and stats state
        self.isLiveFieldReady = false
        self.shouldShowLiveFieldWebView = false

        // Configure serving indicators
        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        // Configure back button
        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)

        // Configure share button
        self.shareButton.setTitle("", for: .normal)
        self.shareButton.setImage(UIImage(named: "more_options_icon"), for: .normal)

        // Configure competition label
        self.headerCompetitionLabel.text = ""
        self.headerCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)

        // Configure competition image
        self.headerCompetitionCountryImageView.image = nil
        self.headerCompetitionCountryImageView.layer.cornerRadius = self.headerCompetitionCountryImageView.frame.width/2
        self.headerCompetitionCountryImageView.contentMode = .scaleAspectFill
        self.headerCompetitionCountryImageView.layer.borderWidth = 0.5

        // Configure team labels
        self.headerDetailHomeLabel.text = localized("home_label_default")
        self.headerDetailHomeLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailHomeLabel.numberOfLines = 0

        self.headerDetailAwayLabel.text = localized("away_label_default")
        self.headerDetailAwayLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailAwayLabel.numberOfLines = 0

        // Configure prelive labels
        self.headerDetailPreliveTopLabel.text = localized("match_label_default")
        self.headerDetailPreliveTopLabel.font = AppFont.with(type: .semibold, size: 12)

        self.headerDetailPreliveBottomLabel.text = "00:00"
        self.headerDetailPreliveBottomLabel.font = AppFont.with(type: .bold, size: 16)

        // Configure live labels
        self.headerDetailLiveTopLabel.text = "'0 - 0'"
        self.headerDetailLiveTopLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveBottomLabel.text = localized("match_start_label_default")
        self.headerDetailLiveBottomLabel.font = AppFont.with(type: .semibold, size: 12)
        self.headerDetailLiveBottomLabel.numberOfLines = 0

        self.liveButtonLabel.text = ""

        // Configure red card indicators
        self.homeRedCardImage.isHidden = true
        self.awayRedCardImage.isHidden = true
        self.homeRedCardLabel.isHidden = true
        self.awayRedCardsLabel.isHidden = true

        // Default to Pre Live
        self.headerDetailLiveView.isHidden = true
        self.headerDetailPreliveView.isHidden = false

        // Configure page view controller
        self.marketGroupsPagedViewController.delegate = self
        self.marketGroupsPagedViewController.dataSource = self

        // Configure account balance view
        self.accountValueView.isHidden = true
        self.accountValueView.layer.cornerRadius = CornerRadius.view
        self.accountValueView.layer.masksToBounds = true
        self.accountValueView.isUserInteractionEnabled = true

        self.accountPlusView.layer.cornerRadius = CornerRadius.squareView
        self.accountPlusView.layer.masksToBounds = true

        // Setup gestures
        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        accountValueView.addGestureRecognizer(accountValueTapGesture)

        let competitionDetailTapGesture = UITapGestureRecognizer(target: self, action: #selector(openCompetitionsDetails))
        headerCompetitionDetailView.addGestureRecognizer(competitionDetailTapGesture)

        // Configure webview
        self.matchFieldWebView.scrollView.alwaysBounceVertical = false
        self.matchFieldWebView.scrollView.bounces = false
        self.matchFieldWebView.navigationDelegate = self

        // Configure loading view
        self.matchFieldLoadingView.hidesWhenStopped = true
        self.matchFieldLoadingView.stopAnimating()
        self.matchFieldLoadingView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        self.matchFieldLoadingView.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)

        // Configure stats collection view
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

        // Configure stats back slider
        self.statsBackSliderView.alpha = 0.0
        self.statsBackSliderView.layer.cornerRadius = 6

        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.statsBackSliderView.addGestureRecognizer(backSliderTapGesture)

        self.statsNotFoundLabel.isHidden = true

        // Configure header button gestures
        let didTapLiveGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveButtonHeaderView))
        self.headerLiveButtonBaseView.addGestureRecognizer(didTapLiveGesture)

        let didTapStatsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStatsButtonHeaderView))
        self.headerStatsButtonBaseView.addGestureRecognizer(didTapStatsGesture)

        // Initial header bar selection
        self.headerBarSelection = .none

        // Apply theme
        self.setupWithTheme()

        // Bind to view model
        self.bind(toViewModel: self.viewModel)

        // Add loading spinner
        self.configureLoadingSpinner()

        // Configure shared game card
        self.view.sendSubviewToBack(self.sharedGameCardView)

        // Make sure the match not available view is on top
        self.view.bringSubviewToFront(self.matchNotAvailableView)

        // Configure tooltip
        self.configureTooltip()

        if self.showMixMatchDefault {
            self.currentPageViewControllerIndex = 1
        }

    }

    private func setupFonts() {
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
    }

    private func configureLoadingSpinner() {
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
    }

    private func configureTooltip() {
        self.view.addSubview(self.mixMatchInfoDialogView)

        NSLayoutConstraint.activate([
            self.mixMatchInfoDialogView.bottomAnchor.constraint(equalTo: self.chipsTypeView.topAnchor, constant: 5),
            self.mixMatchInfoDialogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.mixMatchInfoDialogView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20),
            self.mixMatchInfoDialogView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])

        self.mixMatchInfoDialogView.alpha = 0
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

        // Add and configure floating shortcuts view
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

        self.headerCompetitionCountryImageView.layer.cornerRadius = self.headerCompetitionCountryImageView.frame.size.width / 2

        self.awayServingIndicatorView.layer.cornerRadius = self.awayServingIndicatorView.frame.size.width / 2
        self.homeServingIndicatorView.layer.cornerRadius = self.homeServingIndicatorView.frame.size.width / 2

        // Update the gradient layers if needed
        if let leftMaskLayer = self.leftGradientBaseView?.layer.mask as? CAGradientLayer {
            leftMaskLayer.frame = self.leftGradientBaseView?.bounds ?? .zero
        }

        if let rightMaskLayer = self.rightGradientBaseView?.layer.mask as? CAGradientLayer {
            rightMaskLayer.frame = self.rightGradientBaseView?.bounds ?? .zero
        }
    }
}

extension MatchDetailsViewController {

    // MARK: - Setup Methods

    func setupSubviews() {
        // Add main views to view hierarchy
        view.addSubview(topView)
        view.addSubview(headerDetailView)
        view.addSubview(matchNotAvailableView)
        view.addSubview(marketsNotAvailableView)
        view.addSubview(marketGroupsPagedBaseView)
        view.addSubview(marketsStackView)

        // Top view setup
        setupTopViewHierarchy()

        // Header detail view setup
        setupHeaderDetailViewHierarchy()

        // Match not available view setup
        setupMatchNotAvailableViewHierarchy()

        // Markets not available view setup
        setupMarketsNotAvailableViewHierarchy()

        // Markets stack view setup
        setupMarketsStackViewHierarchy()

        // Add shared game card view
        view.addSubview(sharedGameCardView)

        // Stats collection view height constraint
        statsCollectionViewHeightConstraint = statsCollectionBaseView.heightAnchor.constraint(equalToConstant: 0)

        // Match field web view height constraint
        matchFieldWebViewHeightConstraint = matchFieldWebView.heightAnchor.constraint(equalToConstant: 0)

        // Set up constraints
        setupConstraints()
    }

    private func setupTopViewHierarchy() {
        // Top view is empty for background color
    }

    private func setupHeaderDetailViewHierarchy() {
        // Add main components to header detail view
        headerDetailView.addSubview(headerDetailTopView)
        headerDetailView.addSubview(matchDetailsContentView)
        headerDetailView.addSubview(topSeparatorAlphaLineView)

        // Set up header detail top view
        headerDetailTopView.addSubview(backButton)
        headerDetailTopView.addSubview(shareButton)
        headerDetailTopView.addSubview(headerCompetitionDetailView)
        headerDetailTopView.addSubview(accountValueView)

        // Set up competition detail view
        headerCompetitionDetailView.addSubview(headerCompetitionSportImageView)
        headerCompetitionDetailView.addSubview(headerCompetitionCountryImageView)
        headerCompetitionDetailView.addSubview(headerCompetitionLabel)

        // Set up account value view
        accountValueView.addSubview(accountPlusView)
        accountValueView.addSubview(accountValueLabel)
        accountPlusView.addSubview(accountPlusImageView)

        // Set up match details content view
        matchDetailsContentView.addSubview(homeTeamLabel)
        matchDetailsContentView.addSubview(awayTeamLabel)
        matchDetailsContentView.addSubview(homeServingIndicatorView)
        matchDetailsContentView.addSubview(awayServingIndicatorView)
        matchDetailsContentView.addSubview(preLiveDetailsView)
        matchDetailsContentView.addSubview(liveDetailsView)
        matchDetailsContentView.addSubview(liveTimeLabel)

        // Set up pre-live details view
        preLiveDetailsView.addSubview(preLiveDateLabel)
        preLiveDetailsView.addSubview(preLiveTimeLabel)

        // Set up live details view
        liveDetailsView.addSubview(scoreView)

        // Set up header detail stack view (alternative UI)
        headerDetailView.addSubview(headerDetailStackView)

        // Add views to header detail stack view
        headerDetailStackView.addArrangedSubview(headerDetailHomeView)
        headerDetailStackView.addArrangedSubview(headerDetailMiddleView)
        headerDetailStackView.addArrangedSubview(headerDetailAwayView)

        // Set up home detail view
        headerDetailHomeView.addSubview(headerDetailHomeLabel)

        // Set up away detail view
        headerDetailAwayView.addSubview(headerDetailAwayLabel)

        // Set up middle detail view
        headerDetailMiddleView.addSubview(headerDetailMiddleStackView)

        // Add pre-live and live views to middle stack view
        headerDetailMiddleStackView.addArrangedSubview(headerDetailPreliveView)
        headerDetailMiddleStackView.addArrangedSubview(headerDetailLiveView)

        // Set up pre-live view
        headerDetailPreliveView.addSubview(headerDetailPreliveTopLabel)
        headerDetailPreliveView.addSubview(headerDetailPreliveBottomLabel)

        // Set up live view
        headerDetailLiveView.addSubview(headerDetailLiveTopLabel)
        headerDetailLiveView.addSubview(headerDetailLiveBottomLabel)

        // Add red card indicators
        headerDetailMiddleView.addSubview(homeRedCardImage)
        headerDetailMiddleView.addSubview(homeRedCardLabel)
        headerDetailMiddleView.addSubview(awayRedCardImage)
        headerDetailMiddleView.addSubview(awayRedCardsLabel)
    }

    private func setupMatchNotAvailableViewHierarchy() {
        matchNotAvailableView.addSubview(matchNotAvailableLabel)
    }

    private func setupMarketsNotAvailableViewHierarchy() {
        marketsNotAvailableView.addSubview(marketsNotAvailableLabel)
    }

    private func setupMarketsStackViewHierarchy() {

        // Setup market types view
        marketTypesBaseView.addSubview(chipsTypeView)

        // Add views to markets stack view
        marketsStackView.addArrangedSubview(headerButtonsBaseView)
        marketsStackView.addArrangedSubview(statsBaseView)
        marketsStackView.addArrangedSubview(matchFieldBaseView)
        marketsStackView.addArrangedSubview(marketTypesBaseView)

        // Set up header buttons base view
        headerButtonsBaseView.addSubview(headerButtonsStackView)

        // Add button views to header buttons stack view
        headerButtonsStackView.addArrangedSubview(headerLiveButtonBaseView)
        headerButtonsStackView.addArrangedSubview(headerStatsButtonBaseView)

        // Set up live button view
        headerLiveButtonBaseView.addSubview(liveButtonLabel)
        headerLiveButtonBaseView.addSubview(liveButtonImageView)
        headerLiveButtonBaseView.addSubview(fieldExpandImageView)

        // Set up stats button view
        headerStatsButtonBaseView.addSubview(statsButtonLabel)
        headerStatsButtonBaseView.addSubview(statsButtonImageView)

        // Set up stats base view
        statsBaseView.addSubview(statsCollectionBaseView)
        statsBaseView.addSubview(statsNotFoundLabel)

        // Set up stats collection base view
        statsCollectionBaseView.addSubview(statsCollectionView)
        statsCollectionBaseView.addSubview(statsBackSliderView)

        // Set up match field base view
        matchFieldBaseView.addSubview(matchFieldWebView)
        matchFieldBaseView.addSubview(matchFieldLoadingView)
    }

    private func setupConstraints() {
        // Top level constraints
        NSLayoutConstraint.activate([
            // Top view
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            // Header detail view
            headerDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerDetailView.heightAnchor.constraint(equalToConstant: 130),

            // Background gradient view
            backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundGradientView.topAnchor.constraint(equalTo: headerDetailView.bottomAnchor),
            backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Match not available view
            matchNotAvailableView.topAnchor.constraint(equalTo: headerDetailTopView.bottomAnchor),
            matchNotAvailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            matchNotAvailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            matchNotAvailableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Markets not available view
            marketsNotAvailableView.topAnchor.constraint(equalTo: marketsStackView.bottomAnchor),
            marketsNotAvailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketsNotAvailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketsNotAvailableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Markets stack view
            marketsStackView.topAnchor.constraint(equalTo: headerDetailView.bottomAnchor),
            marketsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Market groups paged base view
            marketGroupsPagedBaseView.topAnchor.constraint(equalTo: marketsStackView.bottomAnchor),
            marketGroupsPagedBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketGroupsPagedBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketGroupsPagedBaseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Shared game card view
            sharedGameCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sharedGameCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sharedGameCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sharedGameCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Header detail top view constraints
        NSLayoutConstraint.activate([
            headerDetailTopView.topAnchor.constraint(equalTo: headerDetailView.topAnchor),
            headerDetailTopView.leadingAnchor.constraint(equalTo: headerDetailView.leadingAnchor),
            headerDetailTopView.trailingAnchor.constraint(equalTo: headerDetailView.trailingAnchor),
            headerDetailTopView.heightAnchor.constraint(equalToConstant: 44),

            // Top separator line
            topSeparatorAlphaLineView.topAnchor.constraint(equalTo: headerDetailTopView.bottomAnchor),
            topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: headerDetailView.leadingAnchor),
            topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: headerDetailView.trailingAnchor),
            topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),

            // Match details content view
            matchDetailsContentView.topAnchor.constraint(equalTo: topSeparatorAlphaLineView.bottomAnchor),
            matchDetailsContentView.leadingAnchor.constraint(equalTo: headerDetailView.leadingAnchor),
            matchDetailsContentView.trailingAnchor.constraint(equalTo: headerDetailView.trailingAnchor),
            matchDetailsContentView.bottomAnchor.constraint(equalTo: headerDetailView.bottomAnchor),

            // Back button
            backButton.leadingAnchor.constraint(equalTo: headerDetailTopView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerDetailTopView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            // Share button
            shareButton.trailingAnchor.constraint(equalTo: headerDetailTopView.trailingAnchor, constant: -1),
            shareButton.centerYAnchor.constraint(equalTo: headerDetailTopView.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 44),

            // Competition detail view
            headerCompetitionDetailView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 1),
            headerCompetitionDetailView.centerYAnchor.constraint(equalTo: headerDetailTopView.centerYAnchor),
            headerCompetitionDetailView.heightAnchor.constraint(equalToConstant: 30),

            // Account value view
            accountValueView.centerYAnchor.constraint(equalTo: headerDetailTopView.centerYAnchor),
            accountValueView.heightAnchor.constraint(equalToConstant: 24),
            accountValueView.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8)
        ])

        // Competition detail view constraints
        NSLayoutConstraint.activate([
            headerCompetitionSportImageView.leadingAnchor.constraint(equalTo: headerCompetitionDetailView.leadingAnchor, constant: 2),
            headerCompetitionSportImageView.centerYAnchor.constraint(equalTo: headerCompetitionDetailView.centerYAnchor),
            headerCompetitionSportImageView.widthAnchor.constraint(equalToConstant: 17),
            headerCompetitionSportImageView.heightAnchor.constraint(equalToConstant: 17),

            headerCompetitionCountryImageView.leadingAnchor.constraint(equalTo: headerCompetitionSportImageView.trailingAnchor, constant: 5),
            headerCompetitionCountryImageView.centerYAnchor.constraint(equalTo: headerCompetitionLabel.centerYAnchor),
            headerCompetitionCountryImageView.widthAnchor.constraint(equalToConstant: 20),
            headerCompetitionCountryImageView.heightAnchor.constraint(equalToConstant: 20),

            headerCompetitionLabel.leadingAnchor.constraint(equalTo: headerCompetitionCountryImageView.trailingAnchor, constant: 5),
            headerCompetitionLabel.centerYAnchor.constraint(equalTo: headerCompetitionDetailView.centerYAnchor),
            headerCompetitionLabel.trailingAnchor.constraint(equalTo: headerCompetitionDetailView.trailingAnchor, constant: -8)
        ])

        // Account value view constraints
        NSLayoutConstraint.activate([
            accountPlusView.leadingAnchor.constraint(equalTo: accountValueView.leadingAnchor, constant: 4),
            accountPlusView.topAnchor.constraint(equalTo: accountValueView.topAnchor, constant: 4),
            accountPlusView.bottomAnchor.constraint(equalTo: accountValueView.bottomAnchor, constant: -4),
            accountPlusView.widthAnchor.constraint(equalTo: accountPlusView.heightAnchor),

            accountPlusImageView.centerXAnchor.constraint(equalTo: accountPlusView.centerXAnchor),
            accountPlusImageView.centerYAnchor.constraint(equalTo: accountPlusView.centerYAnchor),
            accountPlusImageView.widthAnchor.constraint(equalToConstant: 12),

            accountValueLabel.leadingAnchor.constraint(equalTo: accountPlusView.trailingAnchor, constant: 4),
            accountValueLabel.trailingAnchor.constraint(equalTo: accountValueView.trailingAnchor, constant: -4),
            accountValueLabel.centerYAnchor.constraint(equalTo: accountValueView.centerYAnchor)
        ])

        // Match details content view constraints
        NSLayoutConstraint.activate([
            homeTeamLabel.leadingAnchor.constraint(equalTo: matchDetailsContentView.leadingAnchor, constant: 15),
            homeTeamLabel.topAnchor.constraint(equalTo: matchDetailsContentView.topAnchor, constant: 14),

            awayTeamLabel.leadingAnchor.constraint(equalTo: matchDetailsContentView.leadingAnchor, constant: 15),
            awayTeamLabel.topAnchor.constraint(equalTo: homeTeamLabel.bottomAnchor, constant: 10),

            homeServingIndicatorView.leadingAnchor.constraint(equalTo: homeTeamLabel.trailingAnchor, constant: 5),
            homeServingIndicatorView.centerYAnchor.constraint(equalTo: homeTeamLabel.centerYAnchor),
            homeServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),
            homeServingIndicatorView.heightAnchor.constraint(equalToConstant: 9),

            awayServingIndicatorView.leadingAnchor.constraint(equalTo: awayTeamLabel.trailingAnchor, constant: 5),
            awayServingIndicatorView.centerYAnchor.constraint(equalTo: awayTeamLabel.centerYAnchor),
            awayServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),
            awayServingIndicatorView.heightAnchor.constraint(equalToConstant: 9),

            liveTimeLabel.leadingAnchor.constraint(equalTo: homeTeamLabel.leadingAnchor),
            liveTimeLabel.topAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor, constant: 8),
            liveTimeLabel.trailingAnchor.constraint(lessThanOrEqualTo: matchDetailsContentView.centerXAnchor, constant: -10),

            preLiveDetailsView.leadingAnchor.constraint(equalTo: matchDetailsContentView.centerXAnchor),
            preLiveDetailsView.topAnchor.constraint(equalTo: homeTeamLabel.topAnchor),
            preLiveDetailsView.bottomAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor),
            preLiveDetailsView.trailingAnchor.constraint(equalTo: matchDetailsContentView.trailingAnchor, constant: -15),

            liveDetailsView.leadingAnchor.constraint(equalTo: matchDetailsContentView.centerXAnchor),
            liveDetailsView.topAnchor.constraint(equalTo: homeTeamLabel.topAnchor),
            liveDetailsView.bottomAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor),
            liveDetailsView.trailingAnchor.constraint(equalTo: matchDetailsContentView.trailingAnchor, constant: -15)
        ])

        // Pre-live details view constraints
        NSLayoutConstraint.activate([
            preLiveDateLabel.centerYAnchor.constraint(equalTo: homeTeamLabel.centerYAnchor),
            preLiveDateLabel.trailingAnchor.constraint(equalTo: preLiveDetailsView.trailingAnchor),

            preLiveTimeLabel.centerYAnchor.constraint(equalTo: awayTeamLabel.centerYAnchor),
            preLiveTimeLabel.trailingAnchor.constraint(equalTo: preLiveDetailsView.trailingAnchor)
        ])

        // Live details view constraints
        NSLayoutConstraint.activate([
            scoreView.trailingAnchor.constraint(equalTo: liveDetailsView.trailingAnchor),
            scoreView.topAnchor.constraint(equalTo: liveDetailsView.topAnchor),
            scoreView.bottomAnchor.constraint(equalTo: liveDetailsView.bottomAnchor),
            scoreView.leadingAnchor.constraint(greaterThanOrEqualTo: liveDetailsView.leadingAnchor, constant: 30)
        ])

        // Markets stack view constraints
        NSLayoutConstraint.activate([
            // Header buttons base view
            headerButtonsBaseView.heightAnchor.constraint(equalToConstant: 40),

            // Header buttons stack view
            headerButtonsStackView.topAnchor.constraint(equalTo: headerButtonsBaseView.topAnchor, constant: 2),
            headerButtonsStackView.leadingAnchor.constraint(equalTo: headerButtonsBaseView.leadingAnchor),
            headerButtonsStackView.trailingAnchor.constraint(equalTo: headerButtonsBaseView.trailingAnchor),
            headerButtonsStackView.bottomAnchor.constraint(equalTo: headerButtonsBaseView.bottomAnchor),

            // Header stats buttons constraint to match width of live button
            headerLiveButtonBaseView.widthAnchor.constraint(equalTo: headerStatsButtonBaseView.widthAnchor),
        ])

        // Market types base view constraint for height
        NSLayoutConstraint.activate([
            marketTypesBaseView.heightAnchor.constraint(equalToConstant: 70)
        ])

        // Live button components constraints
        NSLayoutConstraint.activate([
            liveButtonImageView.centerYAnchor.constraint(equalTo: headerLiveButtonBaseView.centerYAnchor, constant: -1),
            liveButtonImageView.widthAnchor.constraint(equalToConstant: 13),
            liveButtonImageView.heightAnchor.constraint(equalToConstant: 13),

            liveButtonLabel.centerXAnchor.constraint(equalTo: headerLiveButtonBaseView.centerXAnchor, constant: 8),
            liveButtonLabel.leadingAnchor.constraint(equalTo: liveButtonImageView.trailingAnchor, constant: 8),
            liveButtonLabel.centerYAnchor.constraint(equalTo: headerLiveButtonBaseView.centerYAnchor),

            fieldExpandImageView.leadingAnchor.constraint(equalTo: liveButtonLabel.trailingAnchor, constant: 8),
            fieldExpandImageView.centerYAnchor.constraint(equalTo: headerLiveButtonBaseView.centerYAnchor),
            fieldExpandImageView.widthAnchor.constraint(equalToConstant: 10),
            fieldExpandImageView.heightAnchor.constraint(equalToConstant: 10)
        ])

        // Stats button components constraints
        NSLayoutConstraint.activate([
            statsButtonImageView.leadingAnchor.constraint(equalTo: headerStatsButtonBaseView.leadingAnchor, constant: 4),
            statsButtonImageView.centerYAnchor.constraint(equalTo: headerStatsButtonBaseView.centerYAnchor, constant: -1),
            statsButtonImageView.widthAnchor.constraint(equalToConstant: 12),
            statsButtonImageView.heightAnchor.constraint(equalToConstant: 12),

            statsButtonLabel.leadingAnchor.constraint(equalTo: statsButtonImageView.trailingAnchor, constant: 8),
            statsButtonLabel.centerYAnchor.constraint(equalTo: headerStatsButtonBaseView.centerYAnchor),
            statsButtonLabel.trailingAnchor.constraint(equalTo: headerStatsButtonBaseView.trailingAnchor, constant: -4)
        ])

        // Match field web view constraints
        NSLayoutConstraint.activate([
            matchFieldWebView.topAnchor.constraint(equalTo: matchFieldBaseView.topAnchor),
            matchFieldWebView.leadingAnchor.constraint(equalTo: matchFieldBaseView.leadingAnchor),
            matchFieldWebView.trailingAnchor.constraint(equalTo: matchFieldBaseView.trailingAnchor),
            matchFieldWebView.bottomAnchor.constraint(equalTo: matchFieldBaseView.bottomAnchor),

            matchFieldLoadingView.centerYAnchor.constraint(equalTo: headerLiveButtonBaseView.centerYAnchor),
            matchFieldLoadingView.leadingAnchor.constraint(equalTo: headerLiveButtonBaseView.trailingAnchor, constant: 20)
        ])

        // Stats collection view constraints
        NSLayoutConstraint.activate([
            statsCollectionBaseView.topAnchor.constraint(equalTo: statsBaseView.topAnchor),
            statsCollectionBaseView.leadingAnchor.constraint(equalTo: statsBaseView.leadingAnchor),
            statsCollectionBaseView.trailingAnchor.constraint(equalTo: statsBaseView.trailingAnchor),
            statsCollectionBaseView.bottomAnchor.constraint(equalTo: statsBaseView.bottomAnchor),

            statsCollectionView.topAnchor.constraint(equalTo: statsCollectionBaseView.topAnchor),
            statsCollectionView.leadingAnchor.constraint(equalTo: statsCollectionBaseView.leadingAnchor),
            statsCollectionView.trailingAnchor.constraint(equalTo: statsCollectionBaseView.trailingAnchor),
            statsCollectionView.heightAnchor.constraint(equalToConstant: 147),

            statsBackSliderView.leadingAnchor.constraint(equalTo: statsCollectionBaseView.leadingAnchor, constant: -36),
            statsBackSliderView.centerYAnchor.constraint(equalTo: statsCollectionView.centerYAnchor),
            statsBackSliderView.widthAnchor.constraint(equalToConstant: 78),
            statsBackSliderView.heightAnchor.constraint(equalToConstant: 38),

            statsNotFoundLabel.centerXAnchor.constraint(equalTo: statsCollectionView.centerXAnchor),
            statsNotFoundLabel.centerYAnchor.constraint(equalTo: statsCollectionView.centerYAnchor),
            statsNotFoundLabel.leadingAnchor.constraint(equalTo: statsBaseView.leadingAnchor, constant: 57),
            statsNotFoundLabel.trailingAnchor.constraint(equalTo: statsBaseView.trailingAnchor, constant: -57)
        ])

        // Match not available view constraints
        NSLayoutConstraint.activate([
            matchNotAvailableLabel.centerXAnchor.constraint(equalTo: matchNotAvailableView.centerXAnchor),
            matchNotAvailableLabel.centerYAnchor.constraint(equalTo: matchNotAvailableView.centerYAnchor, constant: -20),
            matchNotAvailableLabel.leadingAnchor.constraint(equalTo: matchNotAvailableView.leadingAnchor, constant: 36),
            matchNotAvailableLabel.trailingAnchor.constraint(equalTo: matchNotAvailableView.trailingAnchor, constant: -36)
        ])

        // Markets not available view constraints
        NSLayoutConstraint.activate([
            marketsNotAvailableLabel.centerXAnchor.constraint(equalTo: marketsNotAvailableView.centerXAnchor),
            marketsNotAvailableLabel.centerYAnchor.constraint(equalTo: marketsNotAvailableView.centerYAnchor),
            marketsNotAvailableLabel.leadingAnchor.constraint(equalTo: marketsNotAvailableView.leadingAnchor, constant: 30),
            marketsNotAvailableLabel.trailingAnchor.constraint(equalTo: marketsNotAvailableView.trailingAnchor, constant: -30)
        ])

        // Alternative header detail stack view (may be hidden initially)
        NSLayoutConstraint.activate([
            headerDetailStackView.topAnchor.constraint(equalTo: headerDetailTopView.bottomAnchor),
            headerDetailStackView.leadingAnchor.constraint(equalTo: headerDetailView.leadingAnchor),
            headerDetailStackView.trailingAnchor.constraint(equalTo: headerDetailView.trailingAnchor),
            headerDetailStackView.bottomAnchor.constraint(equalTo: headerDetailView.bottomAnchor)
        ])

        // Red card indicators constraints
        NSLayoutConstraint.activate([
            homeRedCardImage.centerYAnchor.constraint(equalTo: headerDetailMiddleView.centerYAnchor),
            homeRedCardImage.trailingAnchor.constraint(equalTo: headerDetailMiddleStackView.leadingAnchor),
            homeRedCardImage.widthAnchor.constraint(equalToConstant: 9),
            homeRedCardImage.heightAnchor.constraint(equalToConstant: 14),

            homeRedCardLabel.centerYAnchor.constraint(equalTo: headerDetailMiddleView.centerYAnchor),
            homeRedCardLabel.trailingAnchor.constraint(equalTo: homeRedCardImage.trailingAnchor),
            homeRedCardLabel.widthAnchor.constraint(equalToConstant: 10),
            homeRedCardLabel.heightAnchor.constraint(equalToConstant: 14),

            awayRedCardImage.centerYAnchor.constraint(equalTo: headerDetailMiddleView.centerYAnchor),
            awayRedCardImage.leadingAnchor.constraint(equalTo: headerDetailMiddleStackView.trailingAnchor),
            awayRedCardImage.widthAnchor.constraint(equalToConstant: 9),
            awayRedCardImage.heightAnchor.constraint(equalToConstant: 14),

            awayRedCardsLabel.centerYAnchor.constraint(equalTo: headerDetailMiddleView.centerYAnchor),
            awayRedCardsLabel.leadingAnchor.constraint(equalTo: awayRedCardImage.leadingAnchor),
            awayRedCardsLabel.widthAnchor.constraint(equalToConstant: 10),
            awayRedCardsLabel.heightAnchor.constraint(equalToConstant: 14)
        ])

        NSLayoutConstraint.activate([
            chipsTypeView.leadingAnchor.constraint(equalTo: marketTypesBaseView.leadingAnchor),
            chipsTypeView.trailingAnchor.constraint(equalTo: marketTypesBaseView.trailingAnchor),
            chipsTypeView.topAnchor.constraint(equalTo: marketTypesBaseView.topAnchor),
            chipsTypeView.bottomAnchor.constraint(equalTo: marketTypesBaseView.bottomAnchor),
        ])
        
        // Updatable Constraint for animations
        self.matchFieldWebViewHeightConstraint = NSLayoutConstraint(item: self.matchFieldWebView,
                                                                  attribute: .height,
                                                                    relatedBy: .equal,
                                                                  toItem: nil,
                                                                  attribute: .notAnAttribute,
                                                                    multiplier: 1,
                                                                    constant: 0)
        self.matchFieldWebViewHeightConstraint.isActive = true
        
        self.statsCollectionViewHeightConstraint = NSLayoutConstraint(item: self.statsCollectionBaseView,
                                                                  attribute: .height,
                                                                    relatedBy: .equal,
                                                                  toItem: nil,
                                                                  attribute: .notAnAttribute,
                                                                    multiplier: 1,
                                                                    constant: 0)
        self.statsCollectionViewHeightConstraint.isActive = true
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

        self.headerCompetitionCountryImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor

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

    private func setupEventHandlers() {
        // Add tap gesture recognizers
        let didTapLiveGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveButtonHeaderView))
        headerLiveButtonBaseView.addGestureRecognizer(didTapLiveGesture)

        let didTapStatsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStatsButtonHeaderView))
        headerStatsButtonBaseView.addGestureRecognizer(didTapStatsGesture)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        accountValueView.addGestureRecognizer(accountValueTapGesture)

        let competitionDetailTapGesture = UITapGestureRecognizer(target: self, action: #selector(openCompetitionsDetails))
        headerCompetitionDetailView.addGestureRecognizer(competitionDetailTapGesture)

        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        statsBackSliderView.addGestureRecognizer(backSliderTapGesture)

        // Add button actions
        backButton.addTarget(self, action: #selector(didTapBackAction), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapMoreOptionsButton), for: .primaryActionTriggered)
    }
}

// MARK: - Factory Methods for UI Elements
extension MatchDetailsViewController {

    // MARK: - Top Level Views

    static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    static func createShareButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "more_options_icon"), for: .normal)
        return button
    }

    // MARK: - Competition Detail Views

    static func createHeaderCompetitionDetailView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    static func createHeaderCompetitionSportImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    static func createHeaderCompetitionCountryImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10 // Will be updated in viewDidLayoutSubviews
        imageView.layer.borderWidth = 0.5
        return imageView
    }

    // MARK: - Header Detail Stack Views

    static func createHeaderDetailStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.isHidden = true
        return stackView
    }

    static func createHeaderDetailHomeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailHomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }

    static func createHeaderDetailAwayView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailAwayLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    // MARK: - Serving Indicators

    static func createHomeServingIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createAwayServingIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    // MARK: - Header Middle Section

    static func createHeaderDetailMiddleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailMiddleStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }

    // MARK: - Pre-live Details

    static func createHeaderDetailPreliveView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderDetailPreliveTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("match_label_default")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .center
        return label
    }

    static func createHeaderDetailPreliveBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    // MARK: - Live Details

    static func createHeaderDetailLiveView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createHeaderDetailLiveTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "'0 - 0'"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    static func createHeaderDetailLiveBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("match_start_label_default")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    // MARK: - Header Buttons

    static func createHeaderButtonsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHeaderButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }

    static func createHeaderLiveButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createLiveButtonLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        return label
    }

    static func createLiveButtonImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "tabbar_live_icon")
        return imageView
    }

    static func createFieldExpandImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "arrow_down_icon")
        return imageView
    }

    // MARK: - Stats Button Section

    static func createHeaderStatsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createStatsButtonLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Teams Statistics"
        label.font = AppFont.with(type: .bold, size: 13)
        return label
    }

    static func createStatsButtonImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "market_stats_icon")
        return imageView
    }

    // MARK: - Account Section

    static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 12)
        return label
    }

    static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "plus_small_icon")
        return imageView
    }

    // MARK: - Match Field Section

    static func createMatchFieldBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createMatchFieldLoadingView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }

    static func createMatchFieldWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.bounces = false
        return webView
    }

    static func createMatchFieldWebViewHeightConstraintConstraint() -> NSLayoutConstraint {
        return NSLayoutConstraint()
    }

    // MARK: - Stats Section
    static func createStatsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    static func createStatsCollectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createStatsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }

    static func createStatsCollectionViewHeightConstraintConstraint() -> NSLayoutConstraint {
        return NSLayoutConstraint()
    }

    static func createStatsBackSliderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.0
        view.layer.cornerRadius = 6

        // Add arrow image
        let arrowImage = UIImageView(image: UIImage(named: "arrow_circle_left_icon"))
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.contentMode = .scaleAspectFit
        view.addSubview(arrowImage)

        NSLayoutConstraint.activate([
            arrowImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrowImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -7),
            arrowImage.widthAnchor.constraint(equalToConstant: 24),
            arrowImage.heightAnchor.constraint(equalToConstant: 24)
        ])

        return view
    }

    static func createStatsNotFoundLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 17)
        label.text = localized("There aren't any statistics available for this event.")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }

    // MARK: - Market Types Section

    static func createMarketTypesBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createBackgroundGradientView() -> GradientView {
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        return gradientView
    }

    // MARK: - Market Groups Paged Section

    static func createMarketGroupsPagedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    // MARK: - Match Not Available Section

    static func createMatchNotAvailableView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createMatchNotAvailableLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("This match is no longer available for betting")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    // MARK: - Markets Not Available Section

    static func createMarketsNotAvailableView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createMarketsNotAvailableLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("markets_not_available")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    // MARK: - Red Card Indicators

    static func createHomeRedCardImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "red_card_image")
        imageView.isHidden = true
        return imageView
    }

    static func createAwayRedCardImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "red_card_image")
        imageView.isHidden = true
        return imageView
    }

    static func createHomeRedCardLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }

    static func createAwayRedCardsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }

    // MARK: - Markets Stack

    static func createMarketsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }

    // MARK: - New Top Details View

    static func createTopSeparatorAlphaLineView() -> FadingView {
        let view = FadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.colors = [.clear, .black, .black, .clear]
        view.startPoint = CGPoint(x: 0.0, y: 0.5)
        view.endPoint = CGPoint(x: 1.0, y: 0.5)
        view.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return view
    }

    static func createMatchDetailsContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createHomeTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 16)
        return label
    }

    static func createAwayTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 16)
        return label
    }

    static func createLiveTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 10)
        label.isHidden = true
        return label
    }

    static func createPreLiveDetailsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createPreLiveDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .right
        return label
    }

    static func createPreLiveTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 16)
        label.textAlignment = .right
        return label
    }

    static func createLiveDetailsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createScoreView() -> ScoreView {
        let view = ScoreView(sportCode: "FBL", score: [:])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let view = FloatingShortcutsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createSharedGameCardView() -> SharedGameCardView {
        let view = SharedGameCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    static func createMixMatchInfoDialogView() -> InfoDialogView {
        let view = InfoDialogView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("mix_match_tooltip_description"))
        view.alpha = 0
        return view
    }

}

//
//  Binding and Actions)
extension MatchDetailsViewController {

    // MARK: - Bindings

    func bind(toViewModel viewModel: MatchDetailsViewModel) {

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

                    self?.loadingSpinnerViewController.view.isHidden = true
                    self?.loadingSpinnerViewController.stopAnimating()
                case .failed:
                    self?.loadingSpinnerViewController.view.isHidden = true
                    self?.loadingSpinnerViewController.stopAnimating()

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
                }) { completed in
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
    }

    // MARK: - Methods for UI Updates

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
        self.headerCompetitionCountryImageView.image =  UIImage(named: assetName)

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

    // MARK: - Button Actions and Gestures

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

    @objc func openCompetitionsDetails() {
        // Commented out in original code
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

    @objc private func didTapBackAction() {
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func didTapMoreOptionsButton() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if Env.userSessionStore.isUserLogged() {

            if Env.favoritesManager.isEventFavorite(eventId: self.viewModel.matchId) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ in
                    Env.favoritesManager.removeFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ in
                    Env.favoritesManager.addFavorite(eventId: self.viewModel.matchId, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
        }

        let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ in
            self?.didTapShareButton()
        }
        actionSheetController.addAction(shareAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in }
        actionSheetController.addAction(cancelAction)

        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheetController, animated: true, completion: nil)
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
}

//
//  Delegates Previews
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

// MARK: - WKNavigationDelegate
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

// MARK: - UIGestureRecognizerDelegate
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

// MARK: - UICollectionView Delegate, DataSource & FlowLayout
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

// MARK: - UIScrollViewDelegate
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

// MARK: - InnerTableViewScrollDelegate
extension MatchDetailsViewController: InnerTableViewScrollDelegate {

    var currentHeaderHeight: CGFloat {
        return matchFieldWebViewHeightConstraint.constant
    }

    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        let newHeight = matchFieldWebViewHeightConstraint.constant - scrollDistance

        if newHeight > matchFieldMaximumHeight {
            if matchFieldWebViewHeightConstraint.constant != matchFieldMaximumHeight {
                matchFieldWebViewHeightConstraint.constant = matchFieldMaximumHeight
            }
        }
        else if newHeight < matchFieldMinimumHeight {
            if matchFieldWebViewHeightConstraint.constant != matchFieldMinimumHeight {
                matchFieldWebViewHeightConstraint.constant = matchFieldMinimumHeight
            }
        }
        else {
            matchFieldWebViewHeightConstraint.constant = newHeight
        }
    }

    func innerTableViewScrollEnded(withScrollDirection scrollDirection: InnerScrollDragDirection) {

        let topViewHeight = self.matchFieldWebViewHeightConstraint.constant

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

        self.matchFieldWebViewHeightConstraint.constant = self.matchFieldMaximumHeight

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
        self.matchFieldWebViewHeightConstraint.constant = self.matchFieldMinimumHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

struct MatchDetailsViewController_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            MatchDetailsViewControllerPreview(colorScheme: .light)
                .previewDisplayName("Light Mode")

            MatchDetailsViewControllerPreview(colorScheme: .dark)
                .previewDisplayName("Dark Mode")
        }
    }

    struct MatchDetailsViewControllerPreview: UIViewControllerRepresentable {
        let colorScheme: ColorScheme

        func makeUIViewController(context: Context) -> MatchDetailsViewController {
            // Create a mock match
            let match = PreviewModelsHelper.createFootballMatchWithMultipleMarkets()

            // Create the view model with the mock match
            let viewModel = MatchDetailsViewModel(match: match)

            // Create the view controller with the view model
            return MatchDetailsViewController(viewModel: viewModel)
        }

        func updateUIViewController(_ uiViewController: MatchDetailsViewController, context: Context) {
            // Nothing to update
        }
    }
}

// For iOS 17+
@available(iOS 17.0, *)
#Preview("MatchDetailsViewController", traits: .defaultLayout) {
    MatchDetailsViewController_Previews.MatchDetailsViewControllerPreview(colorScheme: .light)
}
#endif
