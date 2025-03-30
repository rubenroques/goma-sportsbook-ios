//
//  OutrightMatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import UIKit
import Kingfisher
import LinkPresentation
import Combine
import ServicesProvider

class OutrightMatchWidgetCollectionViewCell : UICollectionViewCell {

    // MARK: - Properties
    // Custom UI components are moved to Factory extension
    let backgroundImageGradientLayer = CAGradientLayer()
    let backgroundImageBorderGradientLayer = CAGradientLayer()
    let backgroundImageBorderShapeLayer = CAShapeLayer()

    // Programmatically created views - defined in Factory extension
    // Base views
    lazy var baseView: UIView = self.createBaseView()
    lazy var baseStackView: UIStackView = self.createBaseStackView()

    // Replace with new MatchHeaderView
    lazy var matchHeaderView: MatchHeaderView = self.createMatchHeaderView()

    // Content views
    lazy var mainContentBaseView: UIView = self.createMainContentBaseView()

    // Outright
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

    lazy var topRightInfoIconsStackView: UIStackView = self.createTopRightInfoIconsStackView()
    lazy var cashbackIconContainerView: UIView = self.createCashbackIconContainerView()
    lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()

    // New MatchInfoView component
    lazy var matchInfoView: MatchInfoView = self.createMatchInfoView()

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

    lazy var boostedOddBottomLineAnimatedGradientView: GradientView = self.createBoostedOddBottomLineAnimatedGradientView()

    // Separator views
    lazy var topSeparatorAlphaLineView: FadingView = self.createTopSeparatorAlphaLineView()

    // Boosted corner views
    lazy var boostedTopRightCornerBaseView: UIView = self.createBoostedTopRightCornerBaseView()
    lazy var boostedTopRightCornerLabel: UILabel = self.createBoostedTopRightCornerLabel()
    lazy var boostedTopRightCornerImageView: UIImageView = self.createBoostedTopRightCornerImageView()
    lazy var boostedBackgroungImageView: UIImageView = UIImageView()

    // Layout constraints (previously IBOutlets)


    // Business logic properties
    var viewModel: MatchWidgetCellViewModel?

    static var cellHeight: CGFloat = 162

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

    var cancellables: Set<AnyCancellable> = []

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
        setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.cleanupForReuse()
    }

    // MARK: - Setup Initial State
    func setupInitialState() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 9

        // hide non normal widget style elements
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.layer.masksToBounds = true
        self.topImageBaseView.isHidden = true

        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mixMatchContainerView.isHidden = true

        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.topImageView.contentMode = .scaleAspectFill

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
        self.setupFonts()

        // Hide boosted odds views
        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.homeOldBoostedOddValueLabel.text = "-"
        self.drawOldBoostedOddValueLabel.text = "-"
        self.awayOldBoostedOddValueLabel.text = "-"

        // Setup view properties
        self.setupViewProperties()

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

        // Reset odd change indicators
        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        // Setup buttons and views
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
        self.suspendedLabel.text = localized("suspended")

        // Show/hide main views
        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        // Set outright label
        self.outrightSeeLabel.text = localized("view_competition_markets")
    }

    func cancelSubscriptions() {
        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil

        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil

        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil
    }
}
