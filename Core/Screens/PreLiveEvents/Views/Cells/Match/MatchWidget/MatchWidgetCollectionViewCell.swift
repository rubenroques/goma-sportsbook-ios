//
//  MatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Kingfisher
import LinkPresentation
import Combine
import ServicesProvider

class MatchWidgetCollectionViewCell: UICollectionViewCell {

    //
    var debugUUID = UUID()
    //

    @IBOutlet private weak var baseView: UIView!

    lazy var gradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1.2
        gradientBorderView.gradientCornerRadius = 9

        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]

        return gradientBorderView
    }()

    lazy var liveGradientBorderView: GradientBorderView = {
        var liveGradientBorderView = GradientBorderView()
        liveGradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        liveGradientBorderView.gradientBorderWidth = 2.1
        liveGradientBorderView.gradientCornerRadius = 9

        liveGradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                                 UIColor.App.liveBorderGradient2,
                                                 UIColor.App.liveBorderGradient1]

        return liveGradientBorderView
    }()

    lazy var liveTipView: UIView = {
        var liveTipView = UIView()
        liveTipView.translatesAutoresizingMaskIntoConstraints = false

        // Shadow properties
        liveTipView.layer.masksToBounds = false
        liveTipView.layer.shadowColor = UIColor.App.highlightPrimary.cgColor
        liveTipView.layer.shadowOpacity = 0.7
        liveTipView.layer.shadowOffset = CGSize(width: -4, height: 2)
        liveTipView.layer.shadowRadius = 5

        return liveTipView
    }()

    lazy var liveTipLabel: UILabel = {
        var liveTipLabel = UILabel()
        liveTipLabel.font = AppFont.with(type: .bold, size: 10)
        liveTipLabel.textAlignment = .left
        liveTipLabel.translatesAutoresizingMaskIntoConstraints = false
        liveTipLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        liveTipLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        return liveTipLabel
    }()

    lazy var cashbackIconImageViewHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    lazy var cashbackIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_small_blue_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var cashbackImageViewBaseTrailingConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    lazy var cashbackImageViewLiveTrailingConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    @IBOutlet private weak var baseStackView: UIStackView!

    @IBOutlet private weak var favoritesIconImageView: UIImageView!

    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var locationFlagImageView: UIImageView!

    @IBOutlet private weak var sportTypeImageView: UIImageView!

    @IBOutlet private weak var favoritesButton: UIButton!

    // MARK: - Private Properties
    private lazy var participantsBaseView: UIView = Self.createParticipantsBaseView()
    private lazy var homeParticipantNameLabel: UILabel = Self.createHomeParticipantNameLabel()
    private lazy var awayParticipantNameLabel: UILabel = Self.createAwayParticipantNameLabel()
    private lazy var dateStackView: UIStackView = Self.createDateStackView()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var timeLabel: UILabel = Self.createTimeLabel()
    private lazy var resultStackView: UIStackView = Self.createResultStackView()
    private lazy var resultLabel: UILabel = Self.createResultLabel()

    // MARK: - IBOutlets
    // @IBOutlet private weak var participantsBaseView: UIView!
    // @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    // @IBOutlet private weak var awayParticipantNameLabel: UILabel!
    // @IBOutlet private weak var resultStackView: UIStackView!
    // @IBOutlet private weak var resultLabel: UILabel!
    // @IBOutlet private weak var dateStackView: UIStackView!
    // @IBOutlet private weak var dateLabel: UILabel!
    // @IBOutlet private weak var timeLabel: UILabel!

    @IBOutlet private weak var outrightNameBaseView: UIView!
    @IBOutlet private weak var outrightNameLabel: UILabel!


    @IBOutlet private weak var matchTimeLabel: UILabel!
    @IBOutlet private weak var liveMatchDotBaseView: UIView!
    @IBOutlet private weak var liveMatchDotImageView: UIView!

    @IBOutlet private weak var headerLineStackView: UIStackView!


    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var homeBaseView: UIView!
    @IBOutlet private weak var homeOddTitleLabel: UILabel!
    @IBOutlet private weak var homeOddValueLabel: UILabel!

    @IBOutlet private weak var drawBaseView: UIView!
    @IBOutlet private weak var drawOddTitleLabel: UILabel!
    @IBOutlet private weak var drawOddValueLabel: UILabel!

    @IBOutlet private weak var awayBaseView: UIView!
    @IBOutlet private weak var awayOddTitleLabel: UILabel!
    @IBOutlet private weak var awayOddValueLabel: UILabel!

    // Outrights
    @IBOutlet private weak var outrightBaseView: UIView!
    @IBOutlet private weak var outrightSeeLabel: UILabel!

    // Boosted odds View
    private var boostedTopRightCornerBaseView = UIView()
    private var boostedTopRightCornerLabel = UILabel()
    private var boostedTopRightCornerImageView = UIImageView()
    private let boostedBackgroungImageView = UIImageView()

    // Market name view
    @IBOutlet private weak var marketNameView: UIView!
    @IBOutlet private weak var marketNameInnerView: UIView!
    @IBOutlet private weak var marketNameLabel: UILabel!

    private var boostedOddBarView: UIView = {
        var boostedOddBarView = UIView()
        boostedOddBarView.backgroundColor = .clear
        boostedOddBarView.translatesAutoresizingMaskIntoConstraints = false
        return boostedOddBarView
    }()

    private var boostedOddBarStackView: UIStackView = {
        var boostedOddBarStackView = UIStackView()
        boostedOddBarStackView.axis = .horizontal
        boostedOddBarStackView.spacing = 8
        boostedOddBarStackView.translatesAutoresizingMaskIntoConstraints = false
        return boostedOddBarStackView
    }()

    private var oldValueBoostedButtonContainerView: UIView = {
        var oldValueBoostedButtonContainerView = UIView()
        oldValueBoostedButtonContainerView.backgroundColor = .clear
        oldValueBoostedButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        return oldValueBoostedButtonContainerView
    }()

    private var oldValueBoostedButtonView: UIView = {
        var oldValueBoostedButtonView = UIView()
        oldValueBoostedButtonView.backgroundColor = UIColor.App.inputBorderDisabled
        oldValueBoostedButtonView.layer.borderColor = UIColor.App.inputBackgroundSecondary.cgColor
        oldValueBoostedButtonView.layer.borderWidth = 1.2
        oldValueBoostedButtonView.layer.cornerRadius = 4.5
        oldValueBoostedButtonView.translatesAutoresizingMaskIntoConstraints = false
        return oldValueBoostedButtonView
    }()

    private var oldTitleBoostedOddLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.text = "Label"
        return label
    }()

    private var oldValueBoostedOddLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.text = "Label"
        return label
    }()

    private var arrowSpacerView: UIView = {
        var arrowSpacerView = UIView()
        arrowSpacerView.backgroundColor = .clear
        arrowSpacerView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: "boosted_arrow_right"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        arrowSpacerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: arrowSpacerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: arrowSpacerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: arrowSpacerView.heightAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 19),
        ])
        return arrowSpacerView
    }()

    private var newValueBoostedButtonContainerView: UIView = {
        var newValueBoostedButtonContainerView = UIView()
        newValueBoostedButtonContainerView.backgroundColor = .clear
        newValueBoostedButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        return newValueBoostedButtonContainerView
    }()

    private var newValueBoostedButtonView: UIView = {
        var newValueBoostedButtonView = UIView()
        newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
        newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        newValueBoostedButtonView.layer.borderWidth = 1.3
        newValueBoostedButtonView.layer.cornerRadius = 4.5
        newValueBoostedButtonView.translatesAutoresizingMaskIntoConstraints = false
        return newValueBoostedButtonView
    }()

    private var newTitleBoostedOddLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.text = "Label"
        return label
    }()

    private var newValueBoostedOddLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.text = "Label"
        return label
    }()

    //
    //
    // =============================
    //
    @IBOutlet private weak var homeBoostedOddValueBaseView: UIView!
    @IBOutlet private weak var homeNewBoostedOddValueLabel: UILabel!
    @IBOutlet private weak var homeBoostedOddArrowView: BoostedArrowView!
    @IBOutlet private weak var homeOldBoostedOddValueLabel: UILabel!

    @IBOutlet private weak var drawBoostedOddValueBaseView: UIView!
    @IBOutlet private weak var drawNewBoostedOddValueLabel: UILabel!
    @IBOutlet private weak var drawBoostedOddArrowView: BoostedArrowView!
    @IBOutlet private weak var drawOldBoostedOddValueLabel: UILabel!

    @IBOutlet private weak var awayBoostedOddValueBaseView: UIView!
    @IBOutlet private weak var awayNewBoostedOddValueLabel: UILabel!
    @IBOutlet private weak var awayBoostedOddArrowView: BoostedArrowView!
    @IBOutlet private weak var awayOldBoostedOddValueLabel: UILabel!

    //
    // ---
    @IBOutlet private weak var homeUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var homeDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var drawUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var drawDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var awayUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var awayDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    @IBOutlet private weak var seeAllBaseView: UIView!
    @IBOutlet private weak var seeAllLabel: UILabel!

    //
    // Design Constraints
    @IBOutlet private weak var topMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingMarginSpaceConstraint: NSLayoutConstraint!

    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var teamsHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var resultCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var marketBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var marketTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var marketHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var participantsBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var homeCenterViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var homeResultCenterViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var awayCenterViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var awayResultCenterViewConstraint: NSLayoutConstraint!

    @IBOutlet private weak var homeTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var awayLeadingConstraint: NSLayoutConstraint!

    private var cachedCardsStyle: CardsStyle?
    //
    @IBOutlet private weak var mainContentBaseView: UIView!

    @IBOutlet private weak var backgroundImageView: UIImageView!
    private let backgroundImageGradientLayer = CAGradientLayer()

    private let backgroundImageBorderGradientLayer = CAGradientLayer()
    private let backgroundImageBorderShapeLayer = CAShapeLayer()

    @IBOutlet private weak var topImageBaseView: UIView!
    @IBOutlet private weak var topImageView: UIImageView!

    @IBOutlet private weak var boostedOddBottomLineView: UIView!
    private let boostedOddBottomLineAnimatedGradientView = GradientView()

    //
    // New card design elements
    //
    lazy var homeContentRedesignTopConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    lazy var awayContentRedesignTopConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    lazy var homeToRightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    lazy var awayToRightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    //

    private var contentRedesignBaseView: UIView = {
        var view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var topSeparatorAlphaLineView: FadingView = {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }()

    private var detailedScoreView: ScoreView = {
        var scoreView = ScoreView(sportCode: "", score: [:])
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        return scoreView
    }()

    private lazy var homeNameLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var awayNameLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var homeServingIndicatorView: UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var awayServingIndicatorView: UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var dateNewLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var timeNewLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var matchTimeStatusNewLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var marketNamePillLabelView: PillLabelView = {
        var marketNamePillLabelView = PillLabelView()
        marketNamePillLabelView.translatesAutoresizingMaskIntoConstraints = false
        return marketNamePillLabelView
    }()

    // Bottom see all
    lazy var bottomSeeAllMarketsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    lazy var bottomSeeAllMarketsBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.clipsToBounds = true
        return view
    }()

    lazy var bottomSeeAllMarketsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("see_game_details")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textColor = UIColor.App.textSecondary
        label.textAlignment = .center
        return label
    }()

    lazy var bottomSeeAllMarketsArrowIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nav_arrow_right_icon")
        imageView.setTintColor(color: UIColor.App.iconSecondary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // Mix match bottom bar
    lazy var mixMatchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    lazy var mixMatchBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.clipsToBounds = true
        return view
    }()

    lazy var mixMatchBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_highlight")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var mixMatchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var mixMatchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center

        let text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"

        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: text)
        var range = (text as NSString).range(of: localized("mix_match_mix_string"))

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.buttonTextPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .bold, size: 14), range: fullRange)

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)

        label.attributedText = attributedString

        return label
    }()

    lazy var mixMatchNavigationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_right_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    //
    //
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

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var currentHomeOddValue: Double?
    private var currentDrawOddValue: Double?
    private var currentAwayOddValue: Double?

    private var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }
    private var isMiddleOutcomeButtonSelected: Bool = false {
        didSet {
            self.isMiddleOutcomeButtonSelected ? self.selectMiddleOddButton() : self.deselectMiddleOddButton()
        }
    }
    private var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }

    private var isBoostedOutcomeButtonSelected: Bool = false {
        didSet {
            self.isBoostedOutcomeButtonSelected ? self.selectBoostedOddButton() : self.deselectBoostedOddButton()
        }
    }

    private var leftOutcomeDisabled: Bool = false
    private var middleOutcomeDisabled: Bool = false
    private var rightOutcomeDisabled: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    override func awakeFromNib() {
        super.awakeFromNib()

        // print("BlinkDebug: cell awakeFromNib")

        // hide non normaml widget style elements
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.layer.masksToBounds = true
        self.topImageBaseView.isHidden = true

        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mixMatchContainerView.isHidden = true

        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.mainContentBaseView.isHidden = false
        //

        self.topImageView.contentMode = .scaleAspectFill

        //
        // Add gradient to the bottom booster line
        self.boostedOddBottomLineAnimatedGradientView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedOddBottomLineAnimatedGradientView.colors = [
            (UIColor.init(hex: 0xFF6600), NSNumber(0.0)), // (UIColor.init(hex: 0xD60000), NSNumber(0.0)),
            (UIColor.init(hex: 0xFEDB00), NSNumber(1.0)) // (UIColor.init(hex: 0xFF2600), NSNumber(1.0)),
        ]
        self.boostedOddBottomLineAnimatedGradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.boostedOddBottomLineAnimatedGradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.boostedOddBottomLineAnimatedGradientView.startAnimations()

        self.boostedOddBottomLineView.addSubview(self.boostedOddBottomLineAnimatedGradientView)

        NSLayoutConstraint.activate([
            self.boostedOddBottomLineView.leadingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.leadingAnchor),
            self.boostedOddBottomLineView.trailingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.trailingAnchor),
            self.boostedOddBottomLineView.topAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.topAnchor),
            self.boostedOddBottomLineView.bottomAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.bottomAnchor),
        ])

        self.suspendedBaseView.layer.borderWidth = 1

        //
        // Create a gradient layer on top of the image

        // let finalColor = UIColor(hex: 0x3B3B3B, alpha: 0.50)
        // let initialColor = UIColor(hex: 0x000000, alpha: 0.73)

        let finalColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(0.3)
        let initialColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(1.0)

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.backgroundImageGradientLayer.colors = [initialColor.cgColor, finalColor.cgColor]
        self.backgroundImageGradientLayer.locations = [0.0, 1.0]
        self.backgroundImageGradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // bottom
        self.backgroundImageGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0) // top
        self.backgroundImageView.layer.addSublayer(self.backgroundImageGradientLayer)

        //
        // Setup fonts
        self.eventNameLabel.font = AppFont.with(type: .medium, size: 11)
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
        // Date and time labels
        self.dateLabel.font = AppFont.with(type: .medium, size: 12)
        self.timeLabel.font = AppFont.with(type: .bold, size: 16)
        self.resultLabel.font = AppFont.with(type: .bold, size: 17)
        self.matchTimeLabel.font = AppFont.with(type: .semibold, size: 8)
        // Participant name labels
        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 14)

        //
        // Hide boosted odds views
        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.homeNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.homeOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)
        self.drawNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)
        self.awayNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)

        self.homeOldBoostedOddValueLabel.text = "-"
        self.drawOldBoostedOddValueLabel.text = "-"
        self.awayOldBoostedOddValueLabel.text = "-"

        //
        //
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

        self.favoritesButton.backgroundColor = .clear
        self.participantsBaseView.backgroundColor = .clear
        self.outrightNameBaseView.backgroundColor = .clear

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
        self.outrightBaseView.layer.cornerRadius = 4.5

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

        self.eventNameLabel.text = ""

        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""

        self.homeNameLabel.text = ""
        self.awayNameLabel.text = ""

        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        self.detailedScoreView.updateScores([:])

        self.outrightNameLabel.text = ""

        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.matchTimeStatusNewLabel.text = ""

        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.dateNewLabel.text = ""
        self.timeNewLabel.text = ""

        self.matchTimeStatusNewLabel.isHidden = true

        self.suspendedLabel.text = localized("suspended")

        self.locationFlagImageView.image = nil
        self.sportTypeImageView.image = nil

        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        self.liveMatchDotImageView.isHidden = true

        // Outright
        self.outrightSeeLabel.text = localized("view_competition_markets")
        self.outrightSeeLabel.font = AppFont.with(type: .semibold, size: 12)

        // old Market view and label
        self.marketNameLabel.text = ""
        self.marketNameLabel.font = AppFont.with(type: .bold, size: 8)

        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true

        // Old style for teams and scores
        self.participantsBaseView.isHidden = true
        self.marketNameView.isHidden = true

        // Live add ons to the base view
        // Gradient Border
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveGradientBorderView)

        self.baseView.sendSubviewToBack(self.liveGradientBorderView)
        self.baseView.sendSubviewToBack(self.gradientBorderView)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),

            self.baseView.leadingAnchor.constraint(equalTo: self.liveGradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.liveGradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.liveGradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.liveGradientBorderView.bottomAnchor),
        ])

        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        // Live Tip
        self.liveTipView.isHidden = true
        self.baseView.addSubview(self.liveTipView)
        self.liveTipView.addSubview(self.liveTipLabel)
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"

        self.liveTipView.layer.cornerRadius = 9

        NSLayoutConstraint.activate([
            self.liveTipView.heightAnchor.constraint(equalToConstant: 18),

            self.liveTipView.leadingAnchor.constraint(equalTo: self.liveTipLabel.leadingAnchor, constant: -9),
            self.liveTipView.trailingAnchor.constraint(equalTo: self.liveTipLabel.trailingAnchor, constant: 18),
            self.liveTipView.centerYAnchor.constraint(equalTo: self.liveTipLabel.centerYAnchor),
            self.liveTipView.topAnchor.constraint(equalTo: self.liveTipLabel.topAnchor, constant: 2),

            self.liveTipView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 8),
            self.liveTipView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 10)
        ])

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
                                                                          constant: -4)
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

        self.bringSubviewToFront(self.suspendedBaseView)
        self.bringSubviewToFront(self.seeAllBaseView)
        self.bringSubviewToFront(self.outrightBaseView)

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeBaseView.addGestureRecognizer(longPressLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(longPressMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayBaseView.addGestureRecognizer(longPressRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCard))
        self.participantsBaseView.addGestureRecognizer(longPressGestureRecognizer)

        let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch))
        self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)

        self.hasCashback = false

        //
        self.createRedesignInterface()

        self.setupBoostedOddBarView()

        //
        self.adjustDesignToCardHeightStyle()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adjustDesignToCardHeightStyle()
        self.setupWithTheme()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundImageBorderGradientLayer.frame = self.baseView.bounds
        self.backgroundImageBorderShapeLayer.path = UIBezierPath(roundedRect: self.baseView.bounds,
                                                                 cornerRadius: 9).cgPath

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2

        self.awayServingIndicatorView.layer.cornerRadius = self.awayServingIndicatorView.frame.size.width / 2
        self.homeServingIndicatorView.layer.cornerRadius = self.homeServingIndicatorView.frame.size.width / 2

        self.locationFlagImageView.layer.borderWidth = 0.5

        self.topImageView.roundCorners(corners: [.topRight, .topLeft], radius: 9)

        self.marketNameInnerView.layer.cornerRadius = self.marketNameInnerView.frame.size.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.mixMatchContainerView.isHidden = true
        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.cancellables.removeAll()

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil

        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil

        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.currentHomeOddValue = nil
        self.currentDrawOddValue = nil
        self.currentAwayOddValue = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.isBoostedOutcomeButtonSelected = false

        self.oddsStackView.alpha = 1.0
        self.oddsStackView.isHidden = false

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        self.outrightNameBaseView.isHidden = true

        // Old style for teams and scores
        self.participantsBaseView.isHidden = true
        self.marketNameView.isHidden = true

        self.adjustDesignToCardHeightStyle()

        return

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""

        self.homeNameLabel.text = ""
        self.awayNameLabel.text = ""

        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.dateNewLabel.text = ""
        self.timeNewLabel.text = ""

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.detailedScoreView.updateScores([:])

        self.outrightNameLabel.text = ""

        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.matchTimeStatusNewLabel.isHidden = true
        self.matchTimeStatusNewLabel.text = ""

        self.marketNameLabel.text = ""

        //
        self.dateStackView.isHidden = false
        self.resultStackView.isHidden = true

        self.dateLabel.isHidden = false
        self.timeLabel.isHidden = false

        self.liveMatchDotBaseView.isHidden = true
        self.liveTipView.isHidden = true

        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true

        //
        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.sportTypeImageView.image = nil

        // self.awayBaseView.isHidden = false
        // self.drawBaseView.isHidden = false

        self.isFavorite = false

        self.hasCashback = false

        self.leftOutcomeDisabled = false
        self.middleOutcomeDisabled = false
        self.rightOutcomeDisabled = false

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        self.setupWithTheme()
    }

    func cellDidDisappear() {
        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil

        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil

        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil
    }

    func setupWithTheme() {
        self.liveMatchDotBaseView.backgroundColor = .clear
        self.liveMatchDotImageView.backgroundColor = .clear

        self.liveTipView.backgroundColor = UIColor.App.highlightPrimary

        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedBaseView.layer.borderColor = UIColor.App.backgroundBorder.resolvedColor(with: self.traitCollection).cgColor

        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary

        self.seeAllBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary

        self.outrightBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.outrightSeeLabel.textColor = UIColor.App.textPrimary

        self.locationFlagImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor

        self.homeServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary
        self.awayServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary

        //
        //
        self.bottomSeeAllMarketsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.bottomSeeAllMarketsLabel.textColor = UIColor.App.textSecondary
        self.bottomSeeAllMarketsArrowIconImageView.setTintColor(color: UIColor.App.iconSecondary)

        //
        // Boosted Odds
        self.boostedTopRightCornerLabel.textColor = UIColor.App.textPrimary

        self.homeBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.drawBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.awayBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.homeNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.homeOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary

        self.liveGradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                                      UIColor.App.liveBorderGradient2,
                                                      UIColor.App.liveBorderGradient1]

        self.gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                                  UIColor.App.cardBorderLineGradient2,
                                                  UIColor.App.cardBorderLineGradient3]

        self.contentRedesignBaseView.backgroundColor = .clear

        //
        // Match Widget Type spec
        switch self.viewModel?.matchWidgetType ?? .normal {
        case .normal, .topImage, .topImageWithMixMatch:
            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary

            self.dateLabel.textColor = UIColor.App.textSecondary
            self.timeLabel.textColor = UIColor.App.textPrimary

            self.dateNewLabel.textColor = UIColor.App.textSecondary
            self.timeNewLabel.textColor = UIColor.App.textPrimary
            self.matchTimeStatusNewLabel.textColor = UIColor.App.buttonBackgroundPrimary

            self.topSeparatorAlphaLineView.isHidden = false

            self.oddsStackView.isHidden = false
            self.boostedOddBarView.isHidden = true

            if isLeftOutcomeButtonSelected {
                self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
                self.homeOddValueLabel.textColor = UIColor.App.textPrimary
            }

            if isMiddleOutcomeButtonSelected {
                self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
                self.drawOddValueLabel.textColor = UIColor.App.textPrimary
            }

            if isRightOutcomeButtonSelected {
                self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
                self.awayOddValueLabel.textColor = UIColor.App.textPrimary
            }

            self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
            self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
            self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

            self.homeBaseView.layer.borderWidth = 0
            self.drawBaseView.layer.borderWidth = 0
            self.awayBaseView.layer.borderWidth = 0

        case .topImageOutright:
            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
            self.outrightNameLabel.textColor = UIColor.App.textPrimary

            self.dateLabel.textColor = UIColor.App.textSecondary
            self.timeLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary

            self.dateNewLabel.textColor = UIColor.App.textSecondary
            self.timeNewLabel.textColor = UIColor.App.textPrimary
            self.matchTimeStatusNewLabel.textColor = UIColor.App.buttonBackgroundPrimary

            self.topSeparatorAlphaLineView.isHidden = false

            self.oddsStackView.isHidden = false
            self.boostedOddBarView.isHidden = true

            if isLeftOutcomeButtonSelected {
                self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
                self.homeOddValueLabel.textColor = UIColor.App.textPrimary
            }

            if isMiddleOutcomeButtonSelected {
                self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
                self.drawOddValueLabel.textColor = UIColor.App.textPrimary
            }

            if isRightOutcomeButtonSelected {
                self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
                self.awayOddValueLabel.textColor = UIColor.App.textPrimary
            }

            self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
            self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
            self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

            self.homeBaseView.layer.borderWidth = 0
            self.drawBaseView.layer.borderWidth = 0
            self.awayBaseView.layer.borderWidth = 0
        case .boosted:
            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary

            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary

            self.dateLabel.textColor = UIColor.App.textSecondary
            self.timeLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary

            self.dateNewLabel.textColor = UIColor.App.textSecondary
            self.timeNewLabel.textColor = UIColor.App.textPrimary
            self.matchTimeStatusNewLabel.textColor = UIColor.App.buttonBackgroundPrimary

            self.topSeparatorAlphaLineView.isHidden = false

            self.oddsStackView.isHidden = true
            self.boostedOddBarView.isHidden = false

            if self.isBoostedOutcomeButtonSelected {
                self.newValueBoostedButtonView.backgroundColor = UIColor.App.highlightPrimary
                self.newValueBoostedButtonView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
                self.newTitleBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
                self.newValueBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
                self.newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                self.newTitleBoostedOddLabel.textColor = UIColor.App.textPrimary
                self.newValueBoostedOddLabel.textColor = UIColor.App.textPrimary
            }

            self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
            self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
            self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

            self.homeBaseView.layer.borderWidth = 0
            self.drawBaseView.layer.borderWidth = 0
            self.awayBaseView.layer.borderWidth = 0

            self.boostedOddBottomLineAnimatedGradientView.startAnimations()

        case .backgroundImage:
            self.eventNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeParticipantNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.resultLabel.textColor = UIColor.App.buttonTextPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary

            self.dateLabel.textColor = UIColor.App.textSecondary
            self.timeLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonTextPrimary

            self.dateNewLabel.textColor = UIColor.App.textSecondary
            self.timeNewLabel.textColor = UIColor.App.textPrimary
            self.matchTimeStatusNewLabel.textColor = UIColor.App.buttonTextPrimary

            self.marketNameView.backgroundColor = .clear
            self.marketNameInnerView.backgroundColor = UIColor.App.highlightPrimary

            self.topSeparatorAlphaLineView.isHidden = true

            self.contentRedesignBaseView.backgroundColor = .clear

            self.oddsStackView.isHidden = false
            self.boostedOddBarView.isHidden = true

            if isLeftOutcomeButtonSelected {
                self.homeBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.homeBaseView.layer.borderWidth = 0
            }

            if isMiddleOutcomeButtonSelected {
                self.drawBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.drawBaseView.layer.borderWidth = 0
            }

            if isRightOutcomeButtonSelected {
                self.awayBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.awayBaseView.layer.borderWidth = 0
            }

            self.homeBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
            self.drawBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
            self.awayBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor

            self.homeBaseView.layer.borderWidth = 2
            self.drawBaseView.layer.borderWidth = 2
            self.awayBaseView.layer.borderWidth = 2

            self.homeBaseView.backgroundColor = UIColor.clear
            self.drawBaseView.backgroundColor = UIColor.clear
            self.awayBaseView.backgroundColor = UIColor.clear

            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }

        // Colors based of status
        switch self.viewModel?.matchWidgetStatus ?? .unknown {
        case .live:
            self.baseView.backgroundColor = UIColor.App.backgroundDrop
            // self.contentRedesignBaseView.backgroundColor = self.baseView.backgroundColor
        case .preLive:
            self.baseView.backgroundColor = UIColor.App.backgroundCards
            // self.contentRedesignBaseView.backgroundColor = self.baseView.backgroundColor
        case .unknown:
            break
        }

        self.detailedScoreView.setupWithTheme()
        self.marketNamePillLabelView.setupWithTheme()
    }

    private func adjustMarketNameView(isShown: Bool) {

        if isShown {
            self.marketTopConstraint.constant = 8
            self.marketBottomConstraint.constant = -10
            self.marketHeightConstraint.constant = 15

            self.marketNamePillLabelView.isHidden = false

            self.homeCenterViewConstraint.isActive = false
            self.homeResultCenterViewConstraint.isActive = true

            self.awayCenterViewConstraint.isActive = false

            self.awayResultCenterViewConstraint.isActive = true

            self.homeTrailingConstraint.constant = 20
            self.awayLeadingConstraint.constant = 20
        }
        else {
            self.marketTopConstraint.constant = 0
            self.marketBottomConstraint.constant = 0
            self.marketHeightConstraint.constant = 0

            self.marketNameLabel.text = ""

            self.marketNamePillLabelView.title = ""
            self.marketNamePillLabelView.isHidden = true

            self.homeCenterViewConstraint.isActive = true
            self.homeResultCenterViewConstraint.isActive = false

            self.awayCenterViewConstraint.isActive = true

            self.awayResultCenterViewConstraint.isActive = false

            self.homeTrailingConstraint.constant = 10
            self.awayLeadingConstraint.constant = 10
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToCardHeightStyle() {

        guard let matchWidgetType = self.viewModel?.matchWidgetType else { return }

        if matchWidgetType != .normal {
            if self.cachedCardsStyle == .small {
                self.cachedCardsStyle = .normal

                self.contentRedesignBaseView.isHidden = false
                self.participantsBaseView.isHidden = true
                self.marketNameView.isHidden = true

                self.adjustDesignToNormalCardHeightStyle()

                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            return
        }

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.contentRedesignBaseView.isHidden = true
            self.participantsBaseView.isHidden = false
            self.marketNameView.isHidden = true
        case .normal:
            self.contentRedesignBaseView.isHidden = false
            self.participantsBaseView.isHidden = true
            self.marketNameView.isHidden = true
        }

        // Avoid calling redraw and layout if the style is the same.
        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardHeightStyle()
        case .normal:
            self.adjustDesignToNormalCardHeightStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToSmallCardHeightStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = 8

        self.headerHeightConstraint.constant = 12
        self.teamsHeightConstraint.constant = 26
        self.resultCenterConstraint.constant = -1
        self.buttonsHeightConstraint.constant = 27

        self.cashbackIconImageViewHeightConstraint.constant = 12

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 9)
        self.dateLabel.font = AppFont.with(type: .semibold, size: 10)
        self.timeLabel.font = AppFont.with(type: .bold, size: 13)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.homeParticipantNameLabel.numberOfLines = 2
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayParticipantNameLabel.numberOfLines = 2
        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.outrightNameLabel.numberOfLines = 2

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    private func adjustDesignToNormalCardHeightStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = 12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = 12

        self.headerHeightConstraint.constant = 17
        self.teamsHeightConstraint.constant = 67
        self.resultCenterConstraint.constant = 0
        self.buttonsHeightConstraint.constant = 40

        self.cashbackIconImageViewHeightConstraint.constant = 18

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 11)
        self.dateLabel.font = AppFont.with(type: .semibold, size: 12)
        self.timeLabel.font = AppFont.with(type: .bold, size: 16)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.homeParticipantNameLabel.numberOfLines = 3
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.awayParticipantNameLabel.numberOfLines = 3

        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.outrightNameLabel.numberOfLines = 3

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func drawAsLiveCard() {
        self.dateStackView.isHidden = true
        self.dateNewLabel.isHidden = true
        self.timeNewLabel.isHidden = true

        self.homeToRightConstraint.isActive = false
        self.awayToRightConstraint.isActive = false

        self.detailedScoreView.isHidden = false

        self.resultStackView.isHidden = false
        self.matchTimeStatusNewLabel.isHidden = false

        self.liveMatchDotBaseView.isHidden = true
        self.liveTipView.isHidden = false

        self.cashbackImageViewBaseTrailingConstraint.isActive = false
        self.cashbackImageViewLiveTrailingConstraint.isActive = true

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustMarketNameView(isShown: false)
        case .normal:
            self.adjustMarketNameView(isShown: true)
        }

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = 12

            self.homeContentRedesignTopConstraint.constant = 13
            self.awayContentRedesignTopConstraint.constant = 33
        }
    }

    func drawAsPreLiveCard() {

        self.dateStackView.isHidden = false
        self.dateNewLabel.isHidden = false
        self.timeNewLabel.isHidden = false

        self.homeToRightConstraint.isActive = true
        self.awayToRightConstraint.isActive = true

        self.detailedScoreView.isHidden = true

        self.resultStackView.isHidden = true
        self.matchTimeStatusNewLabel.isHidden = true

        self.liveMatchDotBaseView.isHidden = true
        self.liveTipView.isHidden = true

        self.cashbackImageViewBaseTrailingConstraint.isActive = true
        self.cashbackImageViewLiveTrailingConstraint.isActive = false

        self.adjustMarketNameView(isShown: false)

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = 12

            self.homeContentRedesignTopConstraint.constant = 25
            self.awayContentRedesignTopConstraint.constant = 45
        }
    }

    func drawForMatchWidgetType(_ matchWidgetType: MatchWidgetType) {
        switch matchWidgetType {
        case .normal:
            self.backgroundImageView.isHidden = true

            self.topImageBaseView.isHidden = true
            self.boostedOddBottomLineView.isHidden = true
            self.boostedTopRightCornerBaseView.isHidden = true

            self.mainContentBaseView.isHidden = false

            self.outrightNameBaseView.isHidden = true

            self.baseView.layer.borderWidth = 0
            self.baseView.layer.borderColor = nil
            self.headerLineStackView.alpha = 1.0

            self.homeBoostedOddValueBaseView.isHidden = true
            self.drawBoostedOddValueBaseView.isHidden = true
            self.awayBoostedOddValueBaseView.isHidden = true

            switch StyleHelper.cardsStyleActive() {
            case .small:
                self.bottomMarginSpaceConstraint.constant = 8
                self.teamsHeightConstraint.constant = 26
                self.topMarginSpaceConstraint.constant = 8
            case .normal:
                self.bottomMarginSpaceConstraint.constant = 12
                self.teamsHeightConstraint.constant = 67
                self.topMarginSpaceConstraint.constant = 11
            }

        case .topImage, .topImageWithMixMatch:
            self.backgroundImageView.isHidden = true

            self.topImageBaseView.isHidden = false

            self.boostedOddBottomLineView.isHidden = true
            self.boostedTopRightCornerBaseView.isHidden = true

            self.mainContentBaseView.isHidden = false

            self.outrightNameBaseView.isHidden = true

            self.homeBoostedOddValueBaseView.isHidden = true
            self.drawBoostedOddValueBaseView.isHidden = true
            self.awayBoostedOddValueBaseView.isHidden = true

            self.baseView.layer.borderWidth = 0
            self.baseView.layer.borderColor = nil
            self.headerLineStackView.alpha = 1.0
            self.bottomMarginSpaceConstraint.constant = 12
            self.teamsHeightConstraint.constant = 67
            self.topMarginSpaceConstraint.constant = 11

        case .topImageOutright:
            self.backgroundImageView.isHidden = true

            self.topImageBaseView.isHidden = false

            self.boostedOddBottomLineView.isHidden = true
            self.boostedTopRightCornerBaseView.isHidden = true

            self.mainContentBaseView.isHidden = false

            self.homeBoostedOddValueBaseView.isHidden = true
            self.drawBoostedOddValueBaseView.isHidden = true
            self.awayBoostedOddValueBaseView.isHidden = true

            self.seeAllBaseView.isHidden = true
            self.oddsStackView.isHidden = true
            self.suspendedBaseView.isHidden = true
            self.outrightBaseView.isHidden = false

            self.baseView.layer.borderWidth = 0
            self.baseView.layer.borderColor = nil
            self.headerLineStackView.alpha = 1.0
            self.bottomMarginSpaceConstraint.constant = 12
            self.teamsHeightConstraint.constant = 67
            self.topMarginSpaceConstraint.constant = 11

        case .boosted:
            self.backgroundImageView.isHidden = true

            self.topImageBaseView.isHidden = true
            self.boostedOddBottomLineView.isHidden = false
            self.boostedTopRightCornerBaseView.isHidden = false

            self.mainContentBaseView.isHidden = false

            self.outrightNameBaseView.isHidden = true

            self.homeBoostedOddValueBaseView.isHidden = false
            self.drawBoostedOddValueBaseView.isHidden = false
            self.awayBoostedOddValueBaseView.isHidden = false

            self.headerLineStackView.alpha = 1.0
            self.bottomMarginSpaceConstraint.constant = 12
            self.teamsHeightConstraint.constant = 67
            self.topMarginSpaceConstraint.constant = 11

            self.setupBoostedOddsSubviews()

        case .backgroundImage:
            self.backgroundImageView.isHidden = false

            self.topImageBaseView.isHidden = true
            self.boostedOddBottomLineView.isHidden = true
            self.boostedTopRightCornerBaseView.isHidden = true

            self.mainContentBaseView.isHidden = false

            self.outrightNameBaseView.isHidden = true

            self.homeBoostedOddValueBaseView.isHidden = true
            self.drawBoostedOddValueBaseView.isHidden = true
            self.awayBoostedOddValueBaseView.isHidden = true

            self.baseView.layer.borderWidth = 0
            self.baseView.layer.borderColor = nil
            self.headerLineStackView.alpha = 0.0

            self.bottomMarginSpaceConstraint.constant = 28
            self.teamsHeightConstraint.constant = 47
            self.topMarginSpaceConstraint.constant = 0

            self.backgroundImageBorderGradientLayer.colors = [UIColor(hex: 0x404CFF).cgColor, UIColor(hex: 0x404CFF).withAlphaComponent(0.0).cgColor]
            self.backgroundImageBorderGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            self.backgroundImageBorderGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

            self.backgroundImageBorderShapeLayer.cornerRadius = 9
            self.backgroundImageBorderShapeLayer.lineWidth = 2
            self.backgroundImageBorderShapeLayer.strokeColor = UIColor.black.cgColor
            self.backgroundImageBorderShapeLayer.fillColor = UIColor.clear.cgColor

            self.backgroundImageBorderGradientLayer.mask = self.backgroundImageBorderShapeLayer
            self.baseView.layer.addSublayer(self.backgroundImageBorderGradientLayer)
        }

        self.setupWithTheme()
    }
}

extension MatchWidgetCollectionViewCell {

    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {

        self.viewModel = viewModel

        guard
            let viewModel = self.viewModel
        else {
            return
        }

        self.adjustDesignToCardHeightStyle()

        // let viewModelDesc = "[\(viewModel.match.id) \(viewModel.match.homeParticipant.name) vs \(viewModel.match.awayParticipant.name)]"
        // print("BlinkDebug: cell  \(self.debugUUID.self) configure(withViewModel \(viewModelDesc)")

        Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.$matchWidgetType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus, matchWidgetType in
                switch matchWidgetType {
                case .normal, .boosted, .topImage, .topImageWithMixMatch:
                    if matchWidgetStatus == .live {
                        self?.gradientBorderView.isHidden = true
                        self?.liveGradientBorderView.isHidden = false
                    }
                    else {
                        self?.gradientBorderView.isHidden = false
                        self?.liveGradientBorderView.isHidden = true
                    }
                case .backgroundImage, .topImageOutright:
                    self?.gradientBorderView.isHidden = true
                    self?.liveGradientBorderView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.isLiveCardPublisher)
            .removeDuplicates(by: { oldPair, newPair in
                return oldPair.0 == newPair.0 && oldPair.1 == newPair.1
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus, isLiveCard in
                if isLiveCard || matchWidgetStatus == .live {
                    self?.drawAsLiveCard()
                }
                else {
                    self?.drawAsPreLiveCard()
                }
            }
            .store(in: &self.cancellables)

        viewModel.$matchWidgetType
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetType in

                self?.drawForMatchWidgetType(matchWidgetType)

                switch matchWidgetType {
                case .normal:
                    break
                case .topImage, .topImageWithMixMatch:
                    break
                case .boosted:
                    break
                case .backgroundImage:
                    break
                case .topImageOutright:
                    self?.showOutrightLayout()
                }
            }
            .store(in: &self.cancellables)

        viewModel.homeTeamNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeTeamName in
                self?.homeParticipantNameLabel.text = homeTeamName
                self?.homeNameLabel.text = homeTeamName
            }
            .store(in: &self.cancellables)

        viewModel.awayTeamNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] awayTeamName in
                self?.awayNameLabel.text = awayTeamName
                self?.awayParticipantNameLabel.text = awayTeamName
            }
            .store(in: &self.cancellables)

        viewModel.activePlayerServePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activePlayerServing in
                switch activePlayerServing {
                case .home:
                    self?.homeServingIndicatorView.isHidden = false
                    self?.awayServingIndicatorView.isHidden = true
                case .away:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = false
                case .none:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        viewModel.startDateStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startDateString in
                self?.dateLabel.text = startDateString
                self?.dateNewLabel.text = startDateString
            }
            .store(in: &self.cancellables)

        viewModel.startTimeStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startTimeString in
                self?.timeLabel.text = startTimeString
                self?.timeNewLabel.text = startTimeString
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(
            viewModel.$match,
            viewModel.$oldBoostedOddOutcome
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] match, oldBoostedOddOutcome in

            self?.oldTitleBoostedOddLabel.text = "" // same title for both old and new
            self?.oldValueBoostedOddLabel.text = "-" // The new odd, from the market outcome

            self?.newTitleBoostedOddLabel.text = "" // same title for both old and new
            self?.newValueBoostedOddLabel.text = "-" // The old odd from the old market subscriber

            guard
                let newMarket = match.markets.first,
                let newOutcome = newMarket.outcomes.first
            else {
                // No "new" market found
                return
            }

            // We have enought data to show the new odd value and title
            self?.newTitleBoostedOddLabel.text = newOutcome.typeName // same title for both old and new

            var newValueString = OddFormatter.formatOdd(withValue: newOutcome.bettingOffer.decimalOdd)
            self?.newValueBoostedOddLabel.text = newValueString // The old odd from the old market subscriber

            guard
                let oldBoostedOddOutcomeValue = oldBoostedOddOutcome
            else {
                // No old value found
                // we need to configure the new market and new outcome
                self?.configureBoostedOutcome()
                return
            }

            self?.oldValueBoostedOddLabel.attributedText = oldBoostedOddOutcomeValue.valueAttributedString // The old odd, from the old market outcome
            self?.oldTitleBoostedOddLabel.text = newOutcome.typeName // same title for both old and new

            self?.configureBoostedOutcome()
        }
        .store(in: &self.cancellables)

        //
        // Scores
        viewModel.matchScorePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchScore in
                self?.resultLabel.text = matchScore
            }
            .store(in: &self.cancellables)

        viewModel.detailedScoresPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detailedScoresDict, sportAlphaId in
                self?.detailedScoreView.sportCode = sportAlphaId
                self?.detailedScoreView.updateScores(detailedScoresDict)
            }
            .store(in: &self.cancellables)

        // icon images
        viewModel.countryFlagImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryFlagImage in
                self?.locationFlagImageView.image = countryFlagImage
            }
            .store(in: &self.cancellables)

        viewModel.sportIconImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImage in
                self?.sportTypeImageView.image = sportIconImage
            }
            .store(in: &self.cancellables)

        //
        viewModel.matchTimeDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchTimeDetails in
                self?.matchTimeLabel.text = matchTimeDetails
                self?.matchTimeStatusNewLabel.text = matchTimeDetails
            }
            .store(in: &self.cancellables)

        viewModel.promoImageURLPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] promoImageURL in
                self?.backgroundImageView.kf.setImage(with: promoImageURL)
                self?.topImageView.kf.setImage(with: promoImageURL)
            }
            .store(in: &self.cancellables)

        viewModel.isFavoriteMatchPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavoriteMatch in
                self?.isFavorite = isFavoriteMatch
            }
            .store(in: &self.cancellables)

        viewModel.canHaveCashbackPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canHaveCashback in
                self?.hasCashback = canHaveCashback
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(viewModel.defaultMarketPublisher, viewModel.isDefaultMarketAvailablePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] defaultMarket, isAvailable in
                if let market = defaultMarket {
                    // Setup outcome buttons
                    self?.oddsStackView.alpha = 1.0

                    if viewModel.matchWidgetType == .boosted {
                        self?.configureBoostedOutcome()
                    }
                    else {
                        self?.configureOutcomes(withMarket: market)
                    }

                    if isAvailable {
                        self?.showMarketButtons()
                    }
                    else {
                        self?.showSuspendedView()
                    }

                    if viewModel.matchWidgetType == .topImageWithMixMatch {
                        if let customBetAvailable = market.customBetAvailable,
                           customBetAvailable {
                            self?.mixMatchContainerView.isHidden = false
                            self?.bottomSeeAllMarketsContainerView.isHidden = true
                        }
                        else {
                            self?.mixMatchContainerView.isHidden = true
                            self?.bottomSeeAllMarketsContainerView.isHidden = false
                        }
                    }
                    else if viewModel.matchWidgetType == .topImage {
                        self?.mixMatchContainerView.isHidden = true
                        self?.bottomSeeAllMarketsContainerView.isHidden = false
                    }
                }
                else {
                    // Hide outcome buttons if we don't have any market
                    self?.oddsStackView.alpha = 0.2
                    self?.showSeeAllView()
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest4(viewModel.mainMarketNamePublisher,
                                  viewModel.$matchWidgetType,
                                  viewModel.$matchWidgetStatus,
                                  viewModel.defaultMarketPublisher)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] mainMarketName, matchWidgetType, matchWidgetStatus, defaultMarket in
            self?.marketNameLabel.text = mainMarketName
            self?.marketNamePillLabelView.title = mainMarketName

            if matchWidgetType == .normal && matchWidgetStatus == .live && defaultMarket != nil {
                self?.marketNamePillLabelView.isHidden = false
            }
            else if matchWidgetType == .boosted {
                self?.marketNamePillLabelView.isHidden = false
            }
            //            else if matchWidgetType == .topImageOutright || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch {
            //                self?.marketNamePillLabelView.isHidden = false
            //            }
            else {
                self?.marketNamePillLabelView.isHidden = true
            }
        }
        .store(in: &self.cancellables)

        // Outrights publishers
        Publishers.CombineLatest3(viewModel.$matchWidgetType,
                                  viewModel.eventNamePublisher,
                                  viewModel.competitionNamePublisher)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] matchWidgetType, eventName, competitionName in
            switch matchWidgetType {
            case .topImageOutright:
                self?.eventNameLabel.text = eventName
            default:
                self?.eventNameLabel.text = competitionName
            }
        }
        .store(in: &self.cancellables)

        viewModel.outrightNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outrightName in
                self?.outrightNameLabel.text = outrightName
            }
            .store(in: &self.cancellables)

    }

    private func configureBoostedOutcome() {

        if self.viewModel?.matchWidgetType != .boosted {
            return
        }

        self.boostedOddBarView.isHidden = false

        self.homeBaseView.isHidden = true
        self.drawBaseView.isHidden = true
        self.awayBaseView.isHidden = true

        guard let market = self.viewModel?.match.markets.first, let outcome = market.outcomes.first else { return }

        self.isBoostedOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

    }

    private func configureOutcomes(withMarket market: Market) {

        if let outcome = market.outcomes[safe: 0] {

            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.homeOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.homeOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.homeOddTitleLabel.text = outcome.typeName
            }

            self.leftOutcome = outcome
            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.homeBaseView.isUserInteractionEnabled = false
                self.homeBaseView.alpha = 0.5
                self.setHomeOddValueLabel(toText: "-")
            }

            self.leftOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .handleEvents(receiveOutput: { [weak self] outcome in
                    self?.leftOutcome = outcome
                })
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.homeBaseView.isUserInteractionEnabled = false
                        weakSelf.homeBaseView.alpha = 0.5
                        weakSelf.setHomeOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.homeBaseView.isUserInteractionEnabled = true
                        weakSelf.homeBaseView.alpha = 1.0

                        let newOddValue = bettingOffer.decimalOdd

                        if let currentOddValue = weakSelf.currentHomeOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.homeUpChangeOddValueImage,
                                                              baseView: weakSelf.homeBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.homeDownChangeOddValueImage,
                                                                baseView: weakSelf.homeBaseView)
                            }
                        }
                        weakSelf.currentHomeOddValue = newOddValue
                        weakSelf.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })

        }

        if let outcome = market.outcomes[safe: 1] {

            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.drawOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.drawOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.drawOddTitleLabel.text = outcome.typeName
            }

            self.middleOutcome = outcome
            self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.drawBaseView.isUserInteractionEnabled = false
                self.drawBaseView.alpha = 0.5
                self.setDrawOddValueLabel(toText: "-")
            }

            self.middleOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                .handleEvents(receiveOutput: { [weak self] outcome in
                    self?.middleOutcome = outcome
                })
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.drawBaseView.isUserInteractionEnabled = false
                        weakSelf.drawBaseView.alpha = 0.5
                        weakSelf.setDrawOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.drawBaseView.isUserInteractionEnabled = true
                        weakSelf.drawBaseView.alpha = 1.0

                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentDrawOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.drawUpChangeOddValueImage,
                                                              baseView: weakSelf.drawBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.drawDownChangeOddValueImage,
                                                                baseView: weakSelf.drawBaseView)
                            }
                        }
                        weakSelf.currentDrawOddValue = newOddValue
                        weakSelf.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }

        if let outcome = market.outcomes[safe: 2] {

            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.awayOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.awayOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.awayOddTitleLabel.text = outcome.typeName
            }

            self.rightOutcome = outcome
            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.awayBaseView.isUserInteractionEnabled = false
                self.awayBaseView.alpha = 0.5
                self.setAwayOddValueLabel(toText: "-")
            }

            self.rightOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                .handleEvents(receiveOutput: { [weak self] outcome in
                    self?.rightOutcome = outcome
                })
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.awayBaseView.isUserInteractionEnabled = false
                        weakSelf.awayBaseView.alpha = 0.5
                        weakSelf.setAwayOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.awayBaseView.isUserInteractionEnabled = true
                        weakSelf.awayBaseView.alpha = 1.0

                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentAwayOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.awayUpChangeOddValueImage,
                                                              baseView: weakSelf.awayBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.awayDownChangeOddValueImage,
                                                                baseView: weakSelf.awayBaseView)
                            }
                        }

                        weakSelf.currentAwayOddValue = newOddValue
                        weakSelf.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }

        // boostedOdds uses a different style of outcome buttons
        // old_odd >> new_odd
        self.boostedOddBarView.isHidden = true

        //
        if market.outcomes.count == 3 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = false
        }
        else if market.outcomes.count == 2 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = true
        }
        else if market.outcomes.count == 1 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = true
            self.awayBaseView.isHidden = true
        }
    }

}

extension MatchWidgetCollectionViewCell {

    //
    //
    private func showMarketButtons() {
        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
    }

    private func showSuspendedView() {
        self.suspendedLabel.text = localized("suspended")
        self.suspendedBaseView.isHidden = false
        self.seeAllBaseView.isHidden = true
        self.oddsStackView.isHidden = true
    }

    private func showClosedView() {
        self.suspendedLabel.text = localized("closed_market")
        self.suspendedBaseView.isHidden = false
        self.seeAllBaseView.isHidden = true
        self.oddsStackView.isHidden = true
    }

    private func showSeeAllView() {
        self.seeAllLabel.text = localized("see_all")
        self.seeAllBaseView.isHidden = false
        self.oddsStackView.isHidden = true
    }

    private func showOutrightLayout() {
        self.oddsStackView.isHidden = true
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = false

        self.participantsBaseView.isHidden = true
        self.outrightNameBaseView.isHidden = false

        self.contentRedesignBaseView.isHidden = true
    }

    private func setHomeOddValueLabel(toText text: String) {
        self.homeOddValueLabel.text = text
        self.homeNewBoostedOddValueLabel.text = text
    }

    private func setDrawOddValueLabel(toText text: String) {
        self.drawOddValueLabel.text = text
        self.drawNewBoostedOddValueLabel.text = text
    }

    private func setAwayOddValueLabel(toText text: String) {
        self.awayOddValueLabel.text = text
        self.awayNewBoostedOddValueLabel.text = text
    }

    //
    //
    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    func markAsFavorite(match: Match) {
        if self.viewModel?.matchWidgetType == .topImageOutright {
            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .competition)
                self.isFavorite = false
            }
            else {
                Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .competition)
                self.isFavorite = true
            }
        }
        else {
            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                self.isFavorite = false
            }
            else {
                Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                self.isFavorite = true
            }
        }
    }

    @IBAction private func didTapFavoritesButton(_ sender: Any) {
        if Env.userSessionStore.isUserLogged() {
            if let match = self.viewModel?.match {
                self.markAsFavorite(match: match)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }

    @IBAction private func didTapMatchView(_ sender: Any) {

        if let viewModel = self.viewModel {
            let match = viewModel.match
            if viewModel.matchWidgetType == .topImageOutright {
                if let competition = match.competitionOutright {
                    self.tappedMatchOutrightWidgetAction?(competition)
                }
            }
            else {
                self.tappedMatchWidgetAction?(match)
            }
        }

    }

    @objc private func didTapMixMatch() {
        if let viewModel = self.viewModel {
            let match = viewModel.match
            self.tappedMixMatchAction?(match)
        }
    }

    //
    // TODO: This func is called even if the cell is reused
    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true, downChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

    }

    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }

    //
    // Odd buttons interaction
    //
    func selectLeftOddButton() {
        self.setupWithTheme()
    }

    func deselectLeftOddButton() {
        self.setupWithTheme()
    }

    @objc func didTapLeftOddButton() {

        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.leftOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false

            self.unselectedOutcome?(match, market, outcome)
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            self.isLeftOutcomeButtonSelected = true

            self.selectedOutcome?(match, market, outcome)
        }

    }

    @objc func didLongPressLeftOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {
            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.leftOutcome
            else {
                return
            }
            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
            self.didLongPressOdd?(bettingTicket)
        }
    }

    //
    func selectMiddleOddButton() {
        /*
         switch self.viewModel?.matchWidgetType ?? .normal {
         case .normal, .topImage, .topImageOutright:
         self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
         self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
         self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
         case .boosted:
         self.homeBoostedOddValueBaseView.backgroundColor = UIColor.App.highlightPrimary
         self.homeBaseView.backgroundColor = UIColor.App.highlightPrimary
         self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
         self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
         self.homeBoostedOddArrowView.highlightColor = .black
         case .backgroundImage:
         ()
         }
         */

        self.setupWithTheme()
    }

    func deselectMiddleOddButton() {

        // TODO: avoid calling the entire setup with theme

        /*
         switch self.viewModel?.matchWidgetType ?? .normal {
         case .normal, .topImage, .topImageOutright:
         self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
         self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
         self.homeOddValueLabel.textColor = UIColor.App.textPrimary
         case .boosted:
         self.homeBoostedOddValueBaseView.backgroundColor = UIColor(hex: 0x03061B)
         self.homeBaseView.backgroundColor = UIColor(hex: 0x03061B)
         self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
         self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
         self.homeBoostedOddArrowView.highlightColor = UIColor.App.highlightPrimary
         case .backgroundImage:
         ()
         }
         */

        self.setupWithTheme()
    }

    @objc func didTapMiddleOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.middleOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isMiddleOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressMiddleOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.middleOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)

        }
    }

    //
    func selectRightOddButton() {
        self.setupWithTheme()
    }

    func deselectRightOddButton() {
        self.setupWithTheme()
    }

    @objc func didTapRightOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.rightOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isRightOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressRightOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.rightOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)

        }
    }

    func selectBoostedOddButton() {
        self.newValueBoostedButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.newValueBoostedButtonView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
        self.newTitleBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
        self.newValueBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func deselectBoostedOddButton() {
        self.newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
        self.newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.newTitleBoostedOddLabel.textColor = UIColor.App.textPrimary
        self.newValueBoostedOddLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapBoostedOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = market.outcomes.first
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isBoostedOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isBoostedOutcomeButtonSelected = true
        }
    }

}

extension MatchWidgetCollectionViewCell {

    @IBAction private func didLongPressCard() {

        if Env.userSessionStore.isUserLogged() {

            guard
                let parentViewController = self.viewController,
                let match = self.viewModel?.match
            else {
                return
            }

            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ in
                    Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ in
                    Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }

            let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ in
                self?.didTapShareButton()
            }
            actionSheetController.addAction(shareAction)

            let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in }
            actionSheetController.addAction(cancelAction)

            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = parentViewController.view
                popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            parentViewController.present(actionSheetController, animated: true, completion: nil)

        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }

    private func didTapShareButton() {

        guard
            let parentViewController = self.viewController,
            let match = self.viewModel?.match
        else {
            return
        }

        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let snapshot = renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }

        let metadata = LPLinkMetadata()
        let urlMobile = TargetVariables.clientBaseUrl

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
            popoverController.sourceView = parentViewController.view
            popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        parentViewController.present(shareActivityViewController, animated: true, completion: nil)
    }

}

extension MatchWidgetCollectionViewCell {

    private func setupBoostedOddsSubviews() {

        self.boostedTopRightCornerBaseView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedTopRightCornerBaseView.backgroundColor = .clear

        self.boostedTopRightCornerImageView.image = UIImage(named: "boosted_odd_promotional")
        self.boostedTopRightCornerImageView.contentMode = .scaleAspectFit
        self.boostedTopRightCornerImageView.translatesAutoresizingMaskIntoConstraints = false

        self.boostedTopRightCornerBaseView.addSubview(self.boostedTopRightCornerImageView)
        self.baseView.addSubview(self.boostedTopRightCornerBaseView)

        self.boostedBackgroungImageView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedBackgroungImageView.backgroundColor = UIColor.App.backgroundCards
        self.boostedBackgroungImageView.contentMode = .scaleAspectFill
        self.boostedBackgroungImageView.image = UIImage(named: "boosted_card_background")

        self.baseView.insertSubview(self.boostedBackgroungImageView, at: 0)

        NSLayoutConstraint.activate([
            //            boostedTitleArrowView.widthAnchor.constraint(equalToConstant: 21),
            //            boostedTitleArrowView.heightAnchor.constraint(equalToConstant: 18),
            //            boostedTitleArrowView.leadingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.leadingAnchor),
            //            boostedTitleArrowView.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor, constant: 2),
            //            boostedTitleArrowView.bottomAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.bottomAnchor, constant: -2),
            //
            //            self.boostedTopRightCornerLabel.leadingAnchor.constraint(equalTo: boostedTitleArrowView.trailingAnchor, constant: 2),
            //            self.boostedTopRightCornerLabel.trailingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.trailingAnchor),
            //            self.boostedTopRightCornerLabel.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor),
            //            self.boostedTopRightCornerLabel.bottomAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.bottomAnchor),
            //            self.boostedTopRightCornerLabel.widthAnchor.constraint(equalToConstant: 56),

            self.boostedTopRightCornerImageView.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor),
            self.boostedTopRightCornerImageView.trailingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.trailingAnchor),
            self.boostedTopRightCornerImageView.widthAnchor.constraint(equalTo: self.boostedTopRightCornerImageView.heightAnchor, multiplier: (134.0/34.0) ),

            self.boostedTopRightCornerImageView.heightAnchor.constraint(equalToConstant: 24),

            self.boostedBackgroungImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.boostedBackgroungImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.boostedBackgroungImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.boostedBackgroungImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.boostedTopRightCornerBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 6),
            self.boostedTopRightCornerBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -7),
        ])

    }

}

extension MatchWidgetCollectionViewCell {

    func setupBoostedOddBarView() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapBoostedOddButton))
        self.newValueBoostedButtonView.addGestureRecognizer(tapGesture)

        self.oldValueBoostedButtonView.addSubview(self.oldValueBoostedOddLabel)
        self.oldValueBoostedButtonView.addSubview(self.oldTitleBoostedOddLabel)

        self.oldValueBoostedButtonContainerView.addSubview(self.oldValueBoostedButtonView)

        self.newValueBoostedButtonView.addSubview(self.newValueBoostedOddLabel)
        self.newValueBoostedButtonView.addSubview(self.newTitleBoostedOddLabel)

        self.newValueBoostedButtonContainerView.addSubview(self.newValueBoostedButtonView)

        self.boostedOddBarStackView.addArrangedSubview(self.oldValueBoostedButtonContainerView)
        self.boostedOddBarStackView.addArrangedSubview(self.arrowSpacerView)
        self.boostedOddBarStackView.addArrangedSubview(self.newValueBoostedButtonContainerView)

        self.boostedOddBarView.addSubview(self.boostedOddBarStackView)

        self.mainContentBaseView.addSubview(self.boostedOddBarView)

        NSLayoutConstraint.activate([

            self.oldTitleBoostedOddLabel.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.leadingAnchor, constant: 3),
            self.oldTitleBoostedOddLabel.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.trailingAnchor, constant: -3),
            self.oldTitleBoostedOddLabel.topAnchor.constraint(equalTo: self.oldValueBoostedButtonView.topAnchor, constant: 6),
            self.oldTitleBoostedOddLabel.heightAnchor.constraint(equalToConstant: 9),

            self.oldValueBoostedOddLabel.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.leadingAnchor, constant: 3),
            self.oldValueBoostedOddLabel.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.trailingAnchor, constant: 3),
            self.oldValueBoostedOddLabel.bottomAnchor.constraint(equalTo: self.oldValueBoostedButtonView.bottomAnchor, constant: -6),
            self.oldValueBoostedOddLabel.heightAnchor.constraint(equalToConstant: 15),

            self.oldValueBoostedButtonView.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.leadingAnchor),
            self.oldValueBoostedButtonView.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.trailingAnchor),
            self.oldValueBoostedButtonView.topAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.topAnchor),
            self.oldValueBoostedButtonView.bottomAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.bottomAnchor),

            self.newTitleBoostedOddLabel.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonView.leadingAnchor, constant: 3),
            self.newTitleBoostedOddLabel.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonView.trailingAnchor, constant: -3),
            self.newTitleBoostedOddLabel.topAnchor.constraint(equalTo: self.newValueBoostedButtonView.topAnchor, constant: 6),
            self.newTitleBoostedOddLabel.heightAnchor.constraint(equalToConstant: 9),

            self.newValueBoostedOddLabel.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonView.leadingAnchor, constant: 3),
            self.newValueBoostedOddLabel.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonView.trailingAnchor, constant: 3),
            self.newValueBoostedOddLabel.bottomAnchor.constraint(equalTo: self.newValueBoostedButtonView.bottomAnchor, constant: -6),
            self.newValueBoostedOddLabel.heightAnchor.constraint(equalToConstant: 15),

            self.newValueBoostedButtonView.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.leadingAnchor),
            self.newValueBoostedButtonView.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.trailingAnchor),
            self.newValueBoostedButtonView.topAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.topAnchor),
            self.newValueBoostedButtonView.bottomAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.bottomAnchor),

            self.boostedOddBarView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.boostedOddBarView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.boostedOddBarView.topAnchor.constraint(equalTo: self.oddsStackView.topAnchor),
            self.boostedOddBarView.bottomAnchor.constraint(equalTo: self.oddsStackView.bottomAnchor),

            self.arrowSpacerView.widthAnchor.constraint(equalTo: self.boostedOddBarStackView.heightAnchor),

            self.oldValueBoostedButtonContainerView.widthAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.widthAnchor),

            self.boostedOddBarStackView.leadingAnchor.constraint(equalTo: self.boostedOddBarView.leadingAnchor),
            self.boostedOddBarStackView.trailingAnchor.constraint(equalTo: self.boostedOddBarView.trailingAnchor),
            self.boostedOddBarStackView.topAnchor.constraint(equalTo: self.boostedOddBarView.topAnchor),
            self.boostedOddBarStackView.bottomAnchor.constraint(equalTo: self.boostedOddBarView.bottomAnchor),
        ])
    }

    func createRedesignInterface() {
        self.contentRedesignBaseView.backgroundColor = UIColor.App.backgroundCards

        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary

        self.mainContentBaseView.addSubview(self.contentRedesignBaseView)
        self.contentRedesignBaseView.addSubview(self.topSeparatorAlphaLineView)

        self.contentRedesignBaseView.addSubview(self.detailedScoreView)

        let homeElementsStackView = UIStackView()
        homeElementsStackView.translatesAutoresizingMaskIntoConstraints = false
        homeElementsStackView.axis = .horizontal
        homeElementsStackView.distribution = .fill
        homeElementsStackView.alignment = .center
        homeElementsStackView.spacing = 4

        homeElementsStackView.addArrangedSubview(self.homeNameLabel)
        homeElementsStackView.addArrangedSubview(self.homeServingIndicatorView)

        self.contentRedesignBaseView.addSubview(homeElementsStackView)

        let awayElementsStackView = UIStackView()
        awayElementsStackView.translatesAutoresizingMaskIntoConstraints = false
        awayElementsStackView.axis = .horizontal
        awayElementsStackView.distribution = .fill
        awayElementsStackView.alignment = .center
        awayElementsStackView.spacing = 4

        awayElementsStackView.addArrangedSubview(self.awayNameLabel)
        awayElementsStackView.addArrangedSubview(self.awayServingIndicatorView)

        self.contentRedesignBaseView.addSubview(awayElementsStackView)

        // self.contentRedesignBaseView.addSubview(self.homeNameLabel)
        // self.contentRedesignBaseView.addSubview(self.awayNameLabel)

        // self.contentRedesignBaseView.addSubview()
        // self.contentRedesignBaseView.addSubview(self.awayServingIndicatorView)

        self.contentRedesignBaseView.addSubview(self.dateNewLabel)
        self.contentRedesignBaseView.addSubview(self.timeNewLabel)

        self.contentRedesignBaseView.addSubview(self.matchTimeStatusNewLabel)

        self.contentRedesignBaseView.addSubview(self.marketNamePillLabelView)

        self.homeContentRedesignTopConstraint = homeElementsStackView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 13)
        self.awayContentRedesignTopConstraint = awayElementsStackView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 33)

        self.homeToRightConstraint = self.dateNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: homeElementsStackView.trailingAnchor, constant: 5)
        self.awayToRightConstraint = self.timeNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: awayElementsStackView.trailingAnchor, constant: 5)

        NSLayoutConstraint.activate([
            self.contentRedesignBaseView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 2),
            self.contentRedesignBaseView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -2),
            self.contentRedesignBaseView.topAnchor.constraint(equalTo: self.headerLineStackView.bottomAnchor, constant: 3),
            self.contentRedesignBaseView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: -1),

            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 4),

            self.detailedScoreView.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.detailedScoreView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 13),

            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: homeElementsStackView.trailingAnchor, constant: 5),
            // self.homeNameLabel.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            // self.homeNameLabel.trailingAnchor.constraint(equalTo: self.detailedScoreView.leadingAnchor, constant: -5),
            self.homeContentRedesignTopConstraint,
            self.homeNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),

            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: awayElementsStackView.trailingAnchor, constant: 5),
            // self.awayNameLabel.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            // self.awayNameLabel.trailingAnchor.constraint(equalTo: self.detailedScoreView.leadingAnchor, constant: -5),
            self.awayContentRedesignTopConstraint,
            self.awayNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),

            //
            homeElementsStackView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            awayElementsStackView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),

            // self.timeNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: homeElementsStackView.trailingAnchor, constant: 5),
            // self.dateNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: awayElementsStackView.trailingAnchor, constant: 5),

            //
            self.homeServingIndicatorView.widthAnchor.constraint(equalTo: self.homeServingIndicatorView.heightAnchor),
            self.homeServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),

            self.awayServingIndicatorView.widthAnchor.constraint(equalTo: self.awayServingIndicatorView.heightAnchor),
            self.awayServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),

            //
            self.dateNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.dateNewLabel.topAnchor.constraint(equalTo: self.homeNameLabel.topAnchor),
            self.homeToRightConstraint,

            self.timeNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.timeNewLabel.bottomAnchor.constraint(equalTo: self.awayNameLabel.bottomAnchor),
            self.awayToRightConstraint,

            self.matchTimeStatusNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.matchTimeStatusNewLabel.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -6),

            self.marketNamePillLabelView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 11),
            self.marketNamePillLabelView.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -4),

            self.matchTimeStatusNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.marketNamePillLabelView.trailingAnchor, constant: 5),
        ])

        self.marketNamePillLabelView.setContentCompressionResistancePriority(UILayoutPriority(990), for: .horizontal)
        self.matchTimeStatusNewLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.homeNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
        self.awayNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
    }

}

private extension MatchWidgetCollectionViewCell {

    private func setupSubviews() {
        self.setupParticipantsViews()
        self.initConstraints()
    }

    // MARK: - Setup Methods
    private func setupParticipantsViews() {
        // Add subviews to main content view
        self.mainContentBaseView.addSubview(self.participantsBaseView)

        // Add subviews to participants base view
        self.participantsBaseView.addSubview(self.homeParticipantNameLabel)
        self.participantsBaseView.addSubview(self.awayParticipantNameLabel)
        self.participantsBaseView.addSubview(self.dateStackView)
        self.participantsBaseView.addSubview(self.resultStackView)

        // Add subviews to date stack view
        self.dateStackView.addArrangedSubview(self.dateLabel)
        self.dateStackView.addArrangedSubview(self.timeLabel)

        // Add subviews to result stack view
        self.resultStackView.addArrangedSubview(self.resultLabel)
    }

    private func initConstraints() {
        self.initParticipantsConstraints()
    }

    private func initParticipantsConstraints() {
        // Participants base view constraints
        NSLayoutConstraint.activate([
            self.participantsBaseView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.participantsBaseView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.participantsBaseView.topAnchor.constraint(equalTo: self.headerLineStackView.bottomAnchor, constant: 4),
            // This constraint is excluded in variation but kept for reference
            // self.oddsStackView.topAnchor.constraint(equalTo: self.participantsBaseView.bottomAnchor, constant: 5),
            self.participantsBaseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 67)
        ])

        // Home participant name label constraints
        NSLayoutConstraint.activate([
            self.homeParticipantNameLabel.leadingAnchor.constraint(equalTo: self.participantsBaseView.leadingAnchor),
            self.homeParticipantNameLabel.topAnchor.constraint(equalTo: self.participantsBaseView.topAnchor, constant: 4),
            self.homeParticipantNameLabel.centerYAnchor.constraint(equalTo: self.participantsBaseView.centerYAnchor)
        ])

        // Away participant name label constraints
        NSLayoutConstraint.activate([
            self.awayParticipantNameLabel.trailingAnchor.constraint(equalTo: self.participantsBaseView.trailingAnchor),
            self.awayParticipantNameLabel.topAnchor.constraint(equalTo: self.participantsBaseView.topAnchor, constant: 4),
            self.awayParticipantNameLabel.centerYAnchor.constraint(equalTo: self.participantsBaseView.centerYAnchor)
        ])

        // Date stack view constraints
        NSLayoutConstraint.activate([
            self.dateStackView.centerXAnchor.constraint(equalTo: self.participantsBaseView.centerXAnchor),
            self.dateStackView.centerYAnchor.constraint(equalTo: self.participantsBaseView.centerYAnchor)
        ])

        // Result stack view constraints
        NSLayoutConstraint.activate([
            self.resultStackView.centerXAnchor.constraint(equalTo: self.participantsBaseView.centerXAnchor)
        ])

        // Result label constraints
        NSLayoutConstraint.activate([
            self.resultLabel.centerYAnchor.constraint(equalTo: self.participantsBaseView.centerYAnchor, constant: -4)
        ])

        // Spacing constraints between elements
        NSLayoutConstraint.activate([
            self.dateStackView.leadingAnchor.constraint(equalTo: self.homeParticipantNameLabel.trailingAnchor, constant: 10),
            self.awayParticipantNameLabel.leadingAnchor.constraint(equalTo: self.dateStackView.trailingAnchor, constant: 10)
        ])

    }

    static func createParticipantsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    static func createHomeParticipantNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    static func createAwayParticipantNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    static func createDateStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }

    static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Medium", size: 12)
        label.textColor = UIColor(white: 0.333333, alpha: 1.0)
        label.textAlignment = .center
        return label
    }

    static func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Bold", size: 16)
        label.textAlignment = .center
        return label
    }

    static func createResultStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }

    static func createResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Bold", size: 17)
        label.textAlignment = .center
        return label
    }

}
