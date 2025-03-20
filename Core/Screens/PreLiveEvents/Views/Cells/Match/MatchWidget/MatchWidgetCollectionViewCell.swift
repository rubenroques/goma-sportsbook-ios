//
//  MatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import UIKit
import Kingfisher
import LinkPresentation
import Combine
import ServicesProvider

class MatchWidgetCollectionViewCell: UICollectionViewCell {
    // MARK: - Debug
    var debugUUID = UUID()

    // MARK: - Properties
    // Custom UI components are moved to Factory extension
    let backgroundImageGradientLayer = CAGradientLayer()
    let backgroundImageBorderGradientLayer = CAGradientLayer()
    let backgroundImageBorderShapeLayer = CAShapeLayer()
    let boostedOddBottomLineAnimatedGradientView = GradientView()

    // Programmatically created views - defined in Factory extension
    // Base views
    lazy var baseView: UIView = self.createBaseView()
    lazy var baseStackView: UIStackView = self.createBaseStackView()
    lazy var headerLineStackView: UIStackView = self.createHeaderLineStackView()

    // Header elements
    lazy var favoritesIconImageView: UIImageView = self.createFavoritesIconImageView()
    lazy var eventNameLabel: UILabel = self.createEventNameLabel()
    lazy var locationFlagImageView: UIImageView = self.createLocationFlagImageView()
    lazy var sportTypeImageView: UIImageView = self.createSportTypeImageView()
    lazy var favoritesButton: UIButton = self.createFavoritesButton()

    // Content views
    lazy var mainContentBaseView: UIView = self.createMainContentBaseView()
    lazy var horizontalMatchInfoBaseView: UIView = self.createHorizontalMatchInfoBaseView()
    lazy var outrightNameBaseView: UIView = self.createOutrightNameBaseView()
    lazy var outrightNameLabel: UILabel = self.createOutrightNameLabel()

    // Odds views
    lazy var oddsStackView: UIStackView = self.createOddsStackView()
    lazy var homeBaseView: UIView = self.createHomeBaseView()
    lazy var homeOddTitleLabel: UILabel = self.createHomeOddTitleLabel()
    lazy var homeOddValueLabel: UILabel = self.createHomeOddValueLabel()
    lazy var drawBaseView: UIView = self.createDrawBaseView()
    lazy var drawOddTitleLabel: UILabel = self.createDrawOddTitleLabel()
    lazy var drawOddValueLabel: UILabel = self.createDrawOddValueLabel()
    lazy var awayBaseView: UIView = self.createAwayBaseView()
    lazy var awayOddTitleLabel: UILabel = self.createAwayOddTitleLabel()
    lazy var awayOddValueLabel: UILabel = self.createAwayOddValueLabel()

    // Outright views
    lazy var outrightBaseView: UIView = self.createOutrightBaseView()
    lazy var outrightSeeLabel: UILabel = self.createOutrightSeeLabel()

    // Market views
    lazy var marketNameView: UIView = self.createMarketNameView()
    lazy var marketNameInnerView: UIView = self.createMarketNameInnerView()
    lazy var marketNameLabel: UILabel = self.createMarketNameLabel()

    // Boosted odds views
    lazy var homeBoostedOddValueBaseView: UIView = self.createHomeBoostedOddValueBaseView()
    lazy var homeNewBoostedOddValueLabel: UILabel = self.createNewTitleBoostedOddLabel()
    lazy var homeBoostedOddArrowView: BoostedArrowView = self.createHomeBoostedOddArrowView()
    lazy var homeOldBoostedOddValueLabel: UILabel = self.createOldTitleBoostedOddLabel()
    //
    lazy var drawBoostedOddValueBaseView: UIView = self.createDrawBoostedOddValueBaseView()
    lazy var drawNewBoostedOddValueLabel: UILabel = self.createNewTitleBoostedOddLabel()
    lazy var drawBoostedOddArrowView: BoostedArrowView = self.createDrawBoostedOddArrowView()
    lazy var drawOldBoostedOddValueLabel: UILabel = self.createOldTitleBoostedOddLabel()
    //
    lazy var awayBoostedOddValueBaseView: UIView = self.createAwayBoostedOddValueBaseView()
    lazy var awayNewBoostedOddValueLabel: UILabel = self.createNewTitleBoostedOddLabel()
    lazy var awayBoostedOddArrowView: BoostedArrowView = self.createAwayBoostedOddArrowView()
    lazy var awayOldBoostedOddValueLabel: UILabel = self.createOldTitleBoostedOddLabel()

    // Odds change indicators
    lazy var homeUpChangeOddValueImage: UIImageView = self.createHomeUpChangeOddValueImage()
    lazy var homeDownChangeOddValueImage: UIImageView = self.createHomeDownChangeOddValueImage()
    lazy var drawUpChangeOddValueImage: UIImageView = self.createDrawUpChangeOddValueImage()
    lazy var drawDownChangeOddValueImage: UIImageView = self.createDrawDownChangeOddValueImage()
    lazy var awayUpChangeOddValueImage: UIImageView = self.createAwayUpChangeOddValueImage()
    lazy var awayDownChangeOddValueImage: UIImageView = self.createAwayDownChangeOddValueImage()

    // Status views
    lazy var suspendedBaseView: UIView = self.createSuspendedBaseView()
    lazy var suspendedLabel: UILabel = self.createSuspendedLabel()
    lazy var seeAllBaseView: UIView = self.createSeeAllBaseView()
    lazy var seeAllLabel: UILabel = self.createSeeAllLabel()

    // Image views
    lazy var backgroundImageView: UIImageView = self.createBackgroundImageView()
    lazy var topImageBaseView: UIView = self.createTopImageBaseView()
    lazy var topImageView: UIImageView = self.createTopImageView()
    lazy var boostedOddBottomLineView: UIView = self.createBoostedOddBottomLineView()

    // Border views
    lazy var gradientBorderView: GradientBorderView = self.createGradientBorderView()
    lazy var liveGradientBorderView: GradientBorderView = self.createLiveGradientBorderView()
    lazy var liveTipView: UIView = self.createLiveTipView()
    lazy var liveTipLabel: UILabel = self.createLiveTipLabel()
    lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()
    lazy var horizontalMatchInfoView: HorizontalMatchInfoView = self.createHorizontalMatchInfoView()

    // Team info views
    lazy var homeNameLabel: UILabel = self.createHomeNameLabel()
    lazy var awayNameLabel: UILabel = self.createAwayNameLabel()
    lazy var homeServingIndicatorView: UIView = self.createHomeServingIndicatorView()
    lazy var awayServingIndicatorView: UIView = self.createAwayServingIndicatorView()

    // Time and date views
    lazy var dateNewLabel: UILabel = self.createDateLabel()
    lazy var timeNewLabel: UILabel = self.createTimeLabel()
    lazy var matchTimeStatusNewLabel: UILabel = self.createMatchTimeStatusLabel()

    // Score views
    lazy var detailedScoreView: ScoreView = self.createDetailedScoreView()

    // Market info views
    lazy var marketNamePillLabelView: PillLabelView = self.createMarketNamePillLabelView()

    // Bottom action views
    lazy var bottomSeeAllMarketsContainerView: UIView = self.createBottomSeeAllMarketsContainerView()
    lazy var bottomSeeAllMarketsBaseView: UIView = self.createBottomSeeAllMarketsBaseView()
    lazy var bottomSeeAllMarketsLabel: UILabel = self.createBottomSeeAllMarketsLabel()
    lazy var bottomSeeAllMarketsArrowIconImageView: UIImageView = self.createBottomSeeAllMarketsArrowIconImageView()

    // Mix match views
    lazy var mixMatchContainerView: UIView = self.createMixMatchContainerView()
    lazy var mixMatchBaseView: UIView = self.createMixMatchBaseView()
    lazy var mixMatchBackgroundImageView: UIImageView = self.createMixMatchBackgroundImageView()
    lazy var mixMatchIconImageView: UIImageView = self.createMixMatchIconImageView()
    lazy var mixMatchLabel: UILabel = self.createMixMatchLabel()
    lazy var mixMatchNavigationIconImageView: UIImageView = self.createMixMatchNavigationIconImageView()

    // Boosted odds views
    lazy var boostedOddBarView: UIView = self.createBoostedOddBarView()
    lazy var boostedOddBarStackView: UIStackView = self.createBoostedOddBarStackView()
    lazy var oldValueBoostedButtonContainerView: UIView = self.createOldValueBoostedButtonContainerView()
    lazy var oldValueBoostedButtonView: UIView = self.createOldValueBoostedButtonView()
    lazy var oldTitleBoostedOddLabel: UILabel = self.createOldTitleBoostedOddLabel()
    lazy var oldValueBoostedOddLabel: UILabel = self.createOldValueBoostedOddLabel()
    lazy var arrowSpacerView: UIView = self.createArrowSpacerView()
    lazy var newValueBoostedButtonContainerView: UIView = self.createNewValueBoostedButtonContainerView()
    lazy var newValueBoostedButtonView: UIView = self.createNewValueBoostedButtonView()
    lazy var newTitleBoostedOddLabel: UILabel = self.createNewTitleBoostedOddLabel()
    lazy var newValueBoostedOddLabel: UILabel = self.createNewValueBoostedOddLabel()

    // Separator views
    lazy var topSeparatorAlphaLineView: FadingView = self.createTopSeparatorAlphaLineView()
    lazy var contentRedesignBaseView: UIView = self.createContentRedesignBaseView()

    // Boosted corner views
    lazy var boostedTopRightCornerBaseView: UIView = self.createBoostedTopRightCornerBaseView()
    lazy var boostedTopRightCornerLabel: UILabel = self.createBoostedTopRightCornerLabel()
    lazy var boostedTopRightCornerImageView: UIImageView = self.createBoostedTopRightCornerImageView()
    lazy var boostedBackgroungImageView: UIImageView = UIImageView()

    // Constraint references
    lazy var cashbackIconImageViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var cashbackImageViewBaseTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var cashbackImageViewLiveTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var homeContentRedesignTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var awayContentRedesignTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var homeToRightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var awayToRightConstraint: NSLayoutConstraint = NSLayoutConstraint()

    // Layout constraints (previously IBOutlets)
    lazy var topMarginSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var bottomMarginSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var leadingMarginSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var trailingMarginSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var headerHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var teamsHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var buttonsHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var marketBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var marketTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var marketHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var participantsBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()

    // Business logic properties
    var viewModel: MatchWidgetCellViewModel?

    static var normalCellHeight: CGFloat = 162
    static var smallCellHeight: CGFloat = 92

    var isFavorite: Bool = false {
        didSet {
            if self.isFavorite {
                self.favoritesIconImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoritesIconImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }

    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }

    var tappedMatchWidgetAction: ((Match) -> Void)?
    var selectedOutcome: ((Match, Market, Outcome) -> Void)?
    var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var tappedMatchOutrightWidgetAction: ((Competition) -> Void)?
    var tappedMixMatchAction: ((Match) -> Void)?

    var leftOddButtonSubscriber: AnyCancellable?
    var middleOddButtonSubscriber: AnyCancellable?
    var rightOddButtonSubscriber: AnyCancellable?

    var leftOutcome: Outcome?
    var middleOutcome: Outcome?
    var rightOutcome: Outcome?

    var currentHomeOddValue: Double?
    var currentDrawOddValue: Double?
    var currentAwayOddValue: Double?

    var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }

    var isMiddleOutcomeButtonSelected: Bool = false {
        didSet {
            self.isMiddleOutcomeButtonSelected ? self.selectMiddleOddButton() : self.deselectMiddleOddButton()
        }
    }

    var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }

    var isBoostedOutcomeButtonSelected: Bool = false {
        didSet {
            self.isBoostedOutcomeButtonSelected ? self.selectBoostedOddButton() : self.deselectBoostedOddButton()
        }
    }

    var leftOutcomeDisabled: Bool = false
    var middleOutcomeDisabled: Bool = false
    var rightOutcomeDisabled: Bool = false

    var cachedCardsStyle: CardsStyle?
    var cancellables: Set<AnyCancellable> = []

    // Supporting views
    lazy var eventNameContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // Team elements stack views
    lazy var homeElementsStackView: UIStackView = self.createHomeElementsStackView()
    lazy var awayElementsStackView: UIStackView = self.createAwayElementsStackView()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupInitialState()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupInitialState()
        setupGestureRecognizers()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // This is kept for backward compatibility
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustDesignToCardHeightStyle()
        setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanupForReuse()
    }

    // MARK: - Setup Initial State
    func setupInitialState() {
        // hide non normal widget style elements
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.layer.masksToBounds = true
        self.topImageBaseView.isHidden = true

        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mixMatchContainerView.isHidden = true

        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.topImageView.contentMode = .scaleAspectFill

        // Add gradient to the bottom booster line
        setupBoostedOddBottomLine()

        self.suspendedBaseView.layer.borderWidth = 1

        // Create a gradient layer on top of the image
        let finalColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(0.3)
        let initialColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(1.0)

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.backgroundImageGradientLayer.colors = [initialColor.cgColor, finalColor.cgColor]
        self.backgroundImageGradientLayer.locations = [0.0, 1.0]
        self.backgroundImageGradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // bottom
        self.backgroundImageGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0) // top
        self.backgroundImageView.layer.addSublayer(self.backgroundImageGradientLayer)

        // Setup fonts
        setupFonts()

        // Hide boosted odds views
        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.homeOldBoostedOddValueLabel.text = "-"
        self.drawOldBoostedOddValueLabel.text = "-"
        self.awayOldBoostedOddValueLabel.text = "-"

        // Setup view properties
        setupViewProperties()

        // Hide non-normal widget style elements
        self.backgroundImageView.isHidden = true
        self.topImageBaseView.isHidden = true
        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true
        self.mixMatchContainerView.isHidden = true
        self.bottomSeeAllMarketsContainerView.isHidden = true
        self.mainContentBaseView.isHidden = false

        // Set up content modes and masking
        self.topImageBaseView.layer.masksToBounds = true
        self.topImageView.contentMode = .scaleAspectFill

        // Set up initial UI element states
        self.boostedOddBottomLineAnimatedGradientView.colors = [
            (UIColor.init(hex: 0xFF6600), NSNumber(0.0)),
            (UIColor.init(hex: 0xFEDB00), NSNumber(1.0))
        ]
        self.boostedOddBottomLineAnimatedGradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.boostedOddBottomLineAnimatedGradientView.endPoint = CGPoint(x: 1.0, y: 0.5)

        // Set up suspendedBaseView
        self.suspendedBaseView.layer.borderWidth = 1

        // Hide boosted odds views
        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.homeOldBoostedOddValueLabel.text = "-"
        self.drawOldBoostedOddValueLabel.text = "-"
        self.awayOldBoostedOddValueLabel.text = "-"

        // Basic setup
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 9

        // Reset odd change indicators
        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        // Setup buttons and views
        self.favoritesButton.backgroundColor = .clear
        self.horizontalMatchInfoBaseView.backgroundColor = .clear
        self.outrightNameBaseView.backgroundColor = .clear

        self.oddsStackView.backgroundColor = .clear
        self.homeBaseView.backgroundColor = .clear
        self.drawBaseView.backgroundColor = .clear
        self.awayBaseView.backgroundColor = .clear

        self.awayBaseView.isHidden = false
        self.drawBaseView.isHidden = false

        // Corner radius for buttons
        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.homeBaseView.layer.cornerRadius = 4.5
        self.drawBaseView.layer.cornerRadius = 4.5
        self.awayBaseView.layer.cornerRadius = 4.5

        self.seeAllBaseView.layer.cornerRadius = 4.5
        self.outrightBaseView.layer.cornerRadius = 4.5

        // Clear text labels
        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        // Enable interaction
        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        // Reset alpha values
        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        // Clear text
        self.eventNameLabel.text = ""
        self.suspendedLabel.text = localized("suspended")

        // Hide images
        self.locationFlagImageView.image = nil
        self.sportTypeImageView.image = nil

        // Show/hide main views
        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        // Set outright label
        self.outrightSeeLabel.text = localized("view_competition_markets")

        // Market view setup
        self.marketNameLabel.text = ""

        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true

        // Old style views
        self.horizontalMatchInfoBaseView.isHidden = true
        self.marketNameView.isHidden = true

        // Gradient borders
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        // Live tip
        self.liveTipView.isHidden = true
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"
    }

    func cellDidDisappear() {
        cancelSubscriptions()
    }

    func cancelSubscriptions() {
        leftOddButtonSubscriber?.cancel()
        leftOddButtonSubscriber = nil

        middleOddButtonSubscriber?.cancel()
        middleOddButtonSubscriber = nil

        rightOddButtonSubscriber?.cancel()
        rightOddButtonSubscriber = nil
    }

}

//
// Core functionality is kept in this file
// MARK: - Factory Extension (implement in MatchWidgetCollectionViewCell+Factory.swift)
extension MatchWidgetCollectionViewCell {
    // Factory methods for UI components
}

// MARK: - Layout Extension (implement in MatchWidgetCollectionViewCell+Layout.swift)
extension MatchWidgetCollectionViewCell {
    // Layout methods
}

// MARK: - Configuration Extension (implement in MatchWidgetCollectionViewCell+Configuration.swift)
extension MatchWidgetCollectionViewCell {
    // Configuration methods
}

// MARK: - Interactions Extension (implement in MatchWidgetCollectionViewCell+Interactions.swift)
extension MatchWidgetCollectionViewCell {
    // Interaction methods
}

// MARK: - Styling Extension (implement in MatchWidgetCollectionViewCell+Styling.swift)
extension MatchWidgetCollectionViewCell {
    // Styling methods
}

// MARK: - Animation Extension (implement in MatchWidgetCollectionViewCell+Animations.swift)
extension MatchWidgetCollectionViewCell {
    // Animation methods
}

extension MatchWidgetCollectionViewCell {

    func setupBoostedAndMixMatch() {



        // Cashback
        self.baseView.addSubview(self.cashbackIconImageView)

        self.cashbackIconImageViewHeightConstraint = self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 18)

        NSLayoutConstraint.activate([
            self.cashbackIconImageViewHeightConstraint,
            self.cashbackIconImageView.heightAnchor.constraint(equalTo: self.cashbackIconImageView.widthAnchor),
            self.cashbackIconImageView.centerYAnchor.constraint(equalTo: self.headerLineStackView.centerYAnchor),

            self.headerLineStackView.trailingAnchor.constraint(greaterThanOrEqualTo: self.cashbackIconImageView.leadingAnchor, constant: 1),
        ])

        self.cashbackImageViewBaseTrailingConstraint = NSLayoutConstraint(item: self.cashbackIconImageView,
                                                                          attribute: .trailing,
                                                                          relatedBy: .equal,
                                                                          toItem: self.baseView,
                                                                          attribute: .trailing,
                                                                          multiplier: 1,
                                                                          constant: -8)
        self.cashbackImageViewBaseTrailingConstraint.isActive = true

        self.cashbackImageViewLiveTrailingConstraint = NSLayoutConstraint(item: self.cashbackIconImageView,
                                                                          attribute: .trailing,
                                                                          relatedBy: .equal,
                                                                          toItem: self.liveTipView,
                                                                          attribute: .leading,
                                                                          multiplier: 1,
                                                                          constant: -6)
        self.cashbackImageViewLiveTrailingConstraint.isActive = false

        NSLayoutConstraint.activate([
            self.headerLineStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.cashbackIconImageView.leadingAnchor, constant: -5)
        ])
        //

        // see all button
        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.baseStackView.addArrangedSubview(self.bottomSeeAllMarketsContainerView)

        self.bottomSeeAllMarketsContainerView.addSubview(self.bottomSeeAllMarketsBaseView)
        self.bottomSeeAllMarketsBaseView.addSubview(self.bottomSeeAllMarketsLabel)
        self.bottomSeeAllMarketsBaseView.addSubview(self.bottomSeeAllMarketsArrowIconImageView)

        NSLayoutConstraint.activate([
            self.bottomSeeAllMarketsContainerView.heightAnchor.constraint(equalToConstant: 34),

            self.bottomSeeAllMarketsBaseView.heightAnchor.constraint(equalToConstant: 27),
            self.bottomSeeAllMarketsBaseView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.leadingAnchor, constant: 12),
            self.bottomSeeAllMarketsBaseView.trailingAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.trailingAnchor, constant: -12),
            self.bottomSeeAllMarketsBaseView.topAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.topAnchor),

            self.bottomSeeAllMarketsLabel.centerXAnchor.constraint(equalTo: self.bottomSeeAllMarketsBaseView.centerXAnchor),
            self.bottomSeeAllMarketsLabel.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsBaseView.centerYAnchor),

            self.bottomSeeAllMarketsArrowIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.bottomSeeAllMarketsArrowIconImageView.heightAnchor.constraint(equalToConstant: 12),
            self.bottomSeeAllMarketsArrowIconImageView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.trailingAnchor, constant: 4),
            self.bottomSeeAllMarketsArrowIconImageView.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.centerYAnchor),
        ])

        // MixMatch
        self.mixMatchContainerView.isHidden = true

        self.baseStackView.addArrangedSubview(self.mixMatchContainerView)
        self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
        self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchLabel)
        self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)

        NSLayoutConstraint.activate([
            self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 34),

            self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
            self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 12),
            self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: -12),
            self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),

            self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
            self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
            self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
            self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),

            self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor),
            self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),

            self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
            self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
            self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
            self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),

            self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
            self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
            self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
            self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),

        ])

    }
}
