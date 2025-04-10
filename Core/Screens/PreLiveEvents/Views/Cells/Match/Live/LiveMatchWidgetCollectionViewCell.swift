//
//  LiveMatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import UIKit
import Kingfisher
import LinkPresentation
import Combine
import ServicesProvider

class LiveMatchWidgetCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
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

    var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupInitialState()
        self.setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
        self.setupInitialState()
        self.setupGestureRecognizers()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
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
        self.suspendedLabel.font = AppFont.with(type: .bold, size: 13)
        self.seeAllLabel.font = AppFont.with(type: .bold, size: 13)
        // Odd value labels
        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        // Odd title labels
        self.homeOddTitleLabel.font = AppFont.with(type: .medium, size: 10)
        self.drawOddTitleLabel.font = AppFont.with(type: .medium, size: 10)
        self.awayOddTitleLabel.font = AppFont.with(type: .medium, size: 10)

        // Setup view properties
        self.setupViewProperties()

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

        self.liveGradientBorderView.isHidden = false

        // Live tip
        self.liveTipView.isHidden = true
        self.topRightInfoIconsStackView.spacing = 0

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

    func setupViewProperties() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 9

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

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.homeBaseView.layer.cornerRadius = 4.5
        self.drawBaseView.layer.cornerRadius = 4.5
        self.awayBaseView.layer.cornerRadius = 4.5

        self.seeAllBaseView.layer.cornerRadius = 4.5

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.suspendedLabel.text = localized("suspended")

        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true

        // Setup Live Tip
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"
        self.liveTipView.layer.cornerRadius = 9

        // Setup Gradient Border
        self.liveGradientBorderView.isHidden = true

        // Setup Cashback
        self.hasCashback = false

        // Init with Theme
        self.setupWithTheme()
    }


}
