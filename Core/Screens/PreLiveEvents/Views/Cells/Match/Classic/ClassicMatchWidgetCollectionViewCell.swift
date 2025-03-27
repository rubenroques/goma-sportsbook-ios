//
//  ClassicMatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import UIKit
import Kingfisher
import LinkPresentation
import Combine
import ServicesProvider

class ClassicMatchWidgetCollectionViewCell : UICollectionViewCell {

    // MARK: - Properties

    // Programmatically created views - defined in Factory extension
    // Base views
    lazy var baseView: UIView = self.createBaseView()
    lazy var baseStackView: UIStackView = self.createBaseStackView()

    // Replace with new MatchHeaderView
    lazy var matchHeaderView: MatchHeaderView = self.createMatchHeaderView()

    // Content views
    lazy var mainContentBaseView: UIView = self.createMainContentBaseView()

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

    // Border views
    lazy var gradientBorderView: GradientBorderView = self.createGradientBorderView()
    lazy var liveGradientBorderView: GradientBorderView = self.createLiveGradientBorderView()
    
    lazy var topRightInfoIconsStackView: UIStackView = self.createTopRightInfoIconsStackView()
    lazy var liveTipView: UIView = self.createLiveTipView()
    lazy var liveTipLabel: UILabel = self.createLiveTipLabel()
    lazy var cashbackIconContainerView: UIView = self.createCashbackIconContainerView()
    lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()

    // New MatchInfoView component
    lazy var matchInfoView: MatchInfoView = self.createMatchInfoView()

    // Separator views
    lazy var topSeparatorAlphaLineView: FadingView = self.createTopSeparatorAlphaLineView()

    static var cellHeight: CGFloat = 92

    // Business logic properties
    var viewModel: MatchWidgetCellViewModel?

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

    var cachedCardsStyle: CardsStyle?
    var cancellables: Set<AnyCancellable> = []

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
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
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

        self.suspendedBaseView.layer.borderWidth = 1

        // Setup fonts
        self.setupFonts()

        // Setup view properties
        self.setupViewProperties()
        self.mainContentBaseView.isHidden = false

        // Set up suspendedBaseView
        self.suspendedBaseView.layer.borderWidth = 1

        // Reset odd change indicators
        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

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

        // Gradient borders
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        // Live tip
        self.hideLiveTipView()
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"
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
