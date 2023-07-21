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

enum MatchWidgetType: String, CaseIterable {
    case normal
    case topImage
    case boosted
    case backgroundImage
}

class MatchWidgetCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    lazy var gradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        return gradientBorderView
    }()

    lazy var liveTipView: UIView = {
        var liveTipView = UIView()
        liveTipView.translatesAutoresizingMaskIntoConstraints = false

        return liveTipView
    }()

    lazy var liveTipLabel: UILabel = {
        var liveTipLabel = UILabel()
        liveTipLabel.font = AppFont.with(type: .semibold, size: 9)
        liveTipLabel.textAlignment = .left
        liveTipLabel.translatesAutoresizingMaskIntoConstraints = false
        liveTipLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        liveTipLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        return liveTipLabel
    }()

    lazy var cashbackIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_small_blue_icon")
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

    @IBOutlet private weak var numberOfBetsLabels: UILabel!
    
    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var locationFlagImageView: UIImageView!

    @IBOutlet private weak var sportTypeImageView: UIImageView!

    @IBOutlet private weak var favoritesButton: UIButton!

    @IBOutlet private weak var participantsBaseView: UIView!

    @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    @IBOutlet private weak var awayParticipantNameLabel: UILabel!

    @IBOutlet private weak var resultStackView: UIStackView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var matchTimeLabel: UILabel!
    @IBOutlet private weak var liveMatchDotBaseView: UIView!
    @IBOutlet private weak var liveMatchDotImageView: UIView!

    @IBOutlet private weak var headerLineStackView: UIStackView!
    @IBOutlet private weak var dateStackView: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

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

    // Boosted odds View
    private var boostedTopRightCornerBaseView = UIView()
    private var boostedTopRightCornerLabel = UILabel()

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

    private var matchWidgetType: MatchWidgetType = .normal {
        didSet {

            switch self.matchWidgetType {
            case .normal:
                self.backgroundImageView.isHidden = true

                self.topImageBaseView.isHidden = true
                self.boostedOddBottomLineView.isHidden = true
                self.boostedTopRightCornerBaseView.isHidden = true

                self.mainContentBaseView.isHidden = false

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

                self.gradientBorderView.isHidden = false

            case .topImage:
                self.backgroundImageView.isHidden = true

                self.topImageBaseView.isHidden = false

                self.boostedOddBottomLineView.isHidden = true
                self.boostedTopRightCornerBaseView.isHidden = true

                self.mainContentBaseView.isHidden = false

                self.homeBoostedOddValueBaseView.isHidden = true
                self.drawBoostedOddValueBaseView.isHidden = true
                self.awayBoostedOddValueBaseView.isHidden = true

                self.baseView.layer.borderWidth = 0
                self.baseView.layer.borderColor = nil
                self.headerLineStackView.alpha = 1.0
                self.bottomMarginSpaceConstraint.constant = 12
                self.teamsHeightConstraint.constant = 67
                self.topMarginSpaceConstraint.constant = 11

                self.gradientBorderView.isHidden = true

            case .boosted:
                self.backgroundImageView.isHidden = true

                self.topImageBaseView.isHidden = true
                self.boostedOddBottomLineView.isHidden = false
                self.boostedTopRightCornerBaseView.isHidden = false

                self.mainContentBaseView.isHidden = false

                self.homeBoostedOddValueBaseView.isHidden = false
                self.drawBoostedOddValueBaseView.isHidden = false
                self.awayBoostedOddValueBaseView.isHidden = false

//                self.baseView.layer.borderWidth = 2
//                self.baseView.layer.borderColor = UIColor.App.separatorLine.cgColor
                self.headerLineStackView.alpha = 1.0
                self.bottomMarginSpaceConstraint.constant = 12
                self.teamsHeightConstraint.constant = 67
                self.topMarginSpaceConstraint.constant = 11

                self.setupBoostedOddsSubviews()

                self.gradientBorderView.isHidden = false

            case .backgroundImage:
                self.backgroundImageView.isHidden = false

                self.topImageBaseView.isHidden = true
                self.boostedOddBottomLineView.isHidden = true
                self.boostedTopRightCornerBaseView.isHidden = true

                self.mainContentBaseView.isHidden = false

                self.homeBoostedOddValueBaseView.isHidden = true
                self.drawBoostedOddValueBaseView.isHidden = true
                self.awayBoostedOddValueBaseView.isHidden = true

                self.baseView.layer.borderWidth = 0
                self.baseView.layer.borderColor = nil
                self.headerLineStackView.alpha = 0.0

                self.bottomMarginSpaceConstraint.constant = 28
                self.teamsHeightConstraint.constant = 47
                self.topMarginSpaceConstraint.constant = 0

                self.gradientBorderView.isHidden = true

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

    //
    //
    var viewModel: MatchWidgetCellViewModel?

    static var normalCellHeight: CGFloat = 156
    static var smallCellHeight: CGFloat = 90

    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
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
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var matchSubscriber: AnyCancellable?
    private var marketSubscriber: AnyCancellable?

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

    private var leftOutcomeDisabled: Bool = false
    private var middleOutcomeDisabled: Bool = false
    private var rightOutcomeDisabled: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

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

        //
        // Create a gradient layer on top of the image

//        let finalColor = UIColor(hex: 0x3B3B3B, alpha: 0.50)
//        let initialColor = UIColor(hex: 0x000000, alpha: 0.73)

        let finalColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(0.3)
        let initialColor = UIColor.App.highlightSecondaryContrast.withAlphaComponent(1.0)

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.backgroundImageGradientLayer.colors = [initialColor.cgColor, finalColor.cgColor]
        self.backgroundImageGradientLayer.locations = [0.0, 1.0]
        self.backgroundImageGradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // bottom
        self.backgroundImageGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0) // top
        self.backgroundImageView.layer.addSublayer(self.backgroundImageGradientLayer)

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

        self.homeOldBoostedOddValueLabel.text = "1̶.̶0̶0̶"
        self.drawOldBoostedOddValueLabel.text = "1̶.̶0̶0̶"
        self.awayOldBoostedOddValueLabel.text = "1̶.̶0̶0̶"

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

        self.numberOfBetsLabels.isHidden = true
        self.favoritesButton.backgroundColor = .clear
        self.participantsBaseView.backgroundColor = .clear
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

        self.homeOddTitleLabel.text = "-"
        self.drawOddTitleLabel.text = "-"
        self.awayOddTitleLabel.text = "-"

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""

        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.locationFlagImageView.image = nil
        self.sportTypeImageView.image = nil

        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true

        // Live add ons to the base view
        // Gradient Border
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.sendSubviewToBack(self.gradientBorderView)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor),
        ])

        self.gradientBorderView.isHidden = true

        // Live Tip
        self.baseView.addSubview(self.liveTipView)
        self.liveTipView.addSubview(self.liveTipLabel)
        self.liveTipLabel.text = localized("live") + " ⦿"

        self.liveTipView.layer.cornerRadius = 7

        NSLayoutConstraint.activate([
            self.liveTipView.heightAnchor.constraint(equalToConstant: 14),

            self.liveTipView.leadingAnchor.constraint(equalTo: self.liveTipLabel.leadingAnchor, constant: -8),
            self.liveTipView.trailingAnchor.constraint(equalTo: self.liveTipLabel.trailingAnchor, constant: 14),
            self.liveTipView.centerYAnchor.constraint(equalTo: self.liveTipLabel.centerYAnchor),
            self.liveTipView.topAnchor.constraint(equalTo: self.liveTipLabel.topAnchor, constant: 2),

            self.liveTipView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 8),
            self.liveTipView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 12)
        ])

        // Cashback
        self.baseView.addSubview(self.cashbackIconImageView)

        NSLayoutConstraint.activate([
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.cashbackIconImageView.heightAnchor.constraint(equalTo: self.cashbackIconImageView.widthAnchor),
            self.cashbackIconImageView.centerYAnchor.constraint(equalTo: self.liveTipView.centerYAnchor),

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

        self.bringSubviewToFront(self.suspendedBaseView)
        self.bringSubviewToFront(self.seeAllBaseView)

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

        self.hasCashback = false

        self.adjustDesignToCardStyle()
        self.setupWithTheme()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundImageBorderGradientLayer.frame = self.baseView.bounds
        self.backgroundImageBorderShapeLayer.path = UIBezierPath(roundedRect: self.baseView.bounds,
                                                                 cornerRadius: 9).cgPath

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2

        self.topImageView.roundCorners(corners: [.topRight, .topLeft], radius: 9)

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil

        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil

        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil
        
        self.currentHomeOddValue = nil
        self.currentDrawOddValue = nil
        self.currentAwayOddValue = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""

        //
        self.dateStackView.isHidden = false
        self.resultStackView.isHidden = true

        self.dateLabel.isHidden = false

        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.liveMatchDotBaseView.isHidden = true

        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        //
        self.homeOddTitleLabel.text = "-"
        self.drawOddTitleLabel.text = "-"
        self.awayOddTitleLabel.text = "-"
        
        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.sportTypeImageView.image = nil

        self.oddsStackView.alpha = 1.0
        self.oddsStackView.isHidden = false

        self.awayBaseView.isHidden = false
        self.drawBaseView.isHidden = false

        self.isFavorite = false

        self.hasCashback = false

        self.leftOutcomeDisabled = false
        self.middleOutcomeDisabled = false
        self.rightOutcomeDisabled = false

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true

        self.adjustDesignToCardStyle()
        self.setupWithTheme()

    }

    func cellDidDisappear() {
        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil

        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil

        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil
    }

    func setupWithTheme() {

        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.liveMatchDotBaseView.backgroundColor = .clear
        self.liveMatchDotImageView.backgroundColor = .clear

        self.liveTipView.backgroundColor = UIColor.App.highlightPrimary

        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary

        self.seeAllBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary

        self.sportTypeImageView.setTintColor(color: UIColor.App.textPrimary)

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

        //
        // Match Widget Type spec
        switch self.matchWidgetType {
        case .normal, .topImage:
            self.baseView.backgroundColor = UIColor.App.backgroundCards

            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
            self.dateLabel.textColor = UIColor.App.textPrimary
            self.timeLabel.textColor = UIColor.App.textPrimary

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
            self.baseView.backgroundColor = UIColor.App.backgroundCards

            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
            self.dateLabel.textColor = UIColor.App.textPrimary
            self.timeLabel.textColor = UIColor.App.textPrimary

            if isLeftOutcomeButtonSelected {
                self.homeBoostedOddValueBaseView.backgroundColor = UIColor.App.highlightPrimary

                self.homeBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.homeBoostedOddArrowView.highlightColor = .black
            }
            else {
                self.homeBoostedOddValueBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.homeBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.homeBoostedOddArrowView.highlightColor = UIColor.App.highlightPrimary
            }

            if isMiddleOutcomeButtonSelected {
                self.drawBoostedOddValueBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.drawBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.drawBoostedOddArrowView.highlightColor = .black
            }
            else {
                self.drawBoostedOddValueBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.drawBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.drawBoostedOddArrowView.highlightColor = UIColor.App.highlightPrimary
            }

            if isRightOutcomeButtonSelected {
                self.awayBoostedOddValueBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.awayBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.awayBoostedOddArrowView.highlightColor = .black
            }
            else {
                self.awayBoostedOddValueBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.awayBaseView.backgroundColor = UIColor(hex: 0x03061B)
                self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary

                self.awayBoostedOddArrowView.highlightColor = UIColor.App.highlightPrimary
            }

            self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
            self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
            self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

            self.homeBaseView.layer.borderWidth = 0
            self.drawBaseView.layer.borderWidth = 0
            self.awayBaseView.layer.borderWidth = 0

            self.boostedOddBottomLineAnimatedGradientView.startAnimations()

        case .backgroundImage:
            self.baseView.backgroundColor = UIColor.App.backgroundCards

            self.eventNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeParticipantNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonTextPrimary
            self.resultLabel.textColor = UIColor.App.buttonTextPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
            self.dateLabel.textColor = UIColor.App.buttonTextPrimary
            self.timeLabel.textColor = UIColor.App.buttonTextPrimary

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

        }

    }

    private func adjustDesignToCardStyle() {

        if self.matchWidgetType != .normal {
            return
        }

        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardStyle()
        case .normal:
            self.adjustDesignToNormalCardStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToSmallCardStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = 8

        self.headerHeightConstraint.constant = 12
        self.teamsHeightConstraint.constant = 26
        self.resultCenterConstraint.constant = -1
        self.buttonsHeightConstraint.constant = 27

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 9)
        self.dateLabel.font = AppFont.with(type: .semibold, size: 10)
        self.timeLabel.font = AppFont.with(type: .bold, size: 13)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.homeParticipantNameLabel.numberOfLines = 2
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayParticipantNameLabel.numberOfLines = 2

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    private func adjustDesignToNormalCardStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = 12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = 12

        self.headerHeightConstraint.constant = 17
        self.teamsHeightConstraint.constant = 67 // self.teamsHeightConstraint.constant = 26
        self.resultCenterConstraint.constant = 0
        self.buttonsHeightConstraint.constant = 40

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 11)
        self.dateLabel.font = AppFont.with(type: .semibold, size: 12)
        self.timeLabel.font = AppFont.with(type: .bold, size: 16)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.homeParticipantNameLabel.numberOfLines = 3
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.awayParticipantNameLabel.numberOfLines = 3

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {

        self.viewModel = viewModel
        self.matchWidgetType = viewModel.matchWidgetType

        if viewModel.isLiveCard {
            self.dateStackView.isHidden = true
            self.resultStackView.isHidden = false
        }
        else {
            self.dateStackView.isHidden = false
            self.resultStackView.isHidden = true
        }

        if viewModel.isLiveMatch {
            self.liveMatchDotBaseView.isHidden = false
            //self.gradientBorderView.isHidden = false
            self.liveTipView.isHidden = false

            self.cashbackImageViewBaseTrailingConstraint.isActive = false
            self.cashbackImageViewLiveTrailingConstraint.isActive = true
        }
        else {
            self.liveMatchDotBaseView.isHidden = true
            //self.gradientBorderView.isHidden = true
            self.liveTipView.isHidden = true

            self.cashbackImageViewBaseTrailingConstraint.isActive = true
            self.cashbackImageViewLiveTrailingConstraint.isActive = false
        }

        self.liveMatchDotImageView.isHidden = true
        
        self.eventNameLabel.text = "\(viewModel.competitionName)"

        self.homeParticipantNameLabel.text = "\(viewModel.homeTeamName)"
        self.awayParticipantNameLabel.text = "\(viewModel.awayTeamName)"

        self.dateLabel.text = "\(viewModel.startDateString)"
        self.timeLabel.text = "\(viewModel.startTimeString)"

        self.resultLabel.text = "\(viewModel.matchScore)"
        self.matchTimeLabel.text = viewModel.matchTimeDetails
        
        if viewModel.countryISOCode != "" {
            self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        }
        else {
            self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryId))
        }

        //
        let imageName = viewModel.match.sport.id
        if let sportIconImage = UIImage(named: "sport_type_icon_\(imageName)") {
            self.sportTypeImageView.image = sportIconImage
        }
        else {
            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_default")
        }
        self.sportTypeImageView.setTintColor(color: UIColor.App.textPrimary)

        if let additionalImageURL = viewModel.promoImageURL {
            self.backgroundImageView.kf.setImage(with: additionalImageURL)
            self.topImageView.kf.setImage(with: additionalImageURL)
        }

        //
        self.matchSubscriber?.cancel()
        self.matchSubscriber = nil
        
        self.matchSubscriber = Env.servicesProvider.subscribeToEventLiveDataUpdates(withId: viewModel.match.id)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.match(fromEvent:))
            .sink(receiveCompletion: { completion in
                print("matchSubscriber subscribeToEventLiveDataUpdates completion: \(completion)")
            }, receiveValue: { [weak self] updatedMatch in
                self?.viewModel?.match = updatedMatch

                self?.dateLabel.text = "\(viewModel.startDateString)"
                self?.timeLabel.text = "\(viewModel.startTimeString)"

                self?.resultLabel.text = "\(viewModel.matchScore)"
                self?.matchTimeLabel.text = viewModel.matchTimeDetails

                if viewModel.isLiveMatch {
                    self?.liveMatchDotBaseView.isHidden = false
                }
                else {
                    self?.liveMatchDotBaseView.isHidden = true
                }
            })
        
        if let market = viewModel.match.markets.first {

            self.marketSubscriber = Env.servicesProvider.subscribeToEventMarketUpdates(withId: market.id)
                .compactMap({ $0 })
                .map({ (serviceProviderMarket: ServicesProvider.Market) -> Market in
                    return ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)
                })
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("marketSubscriber subscribeToEventMarketUpdates completion: \(completion)")
                }, receiveValue: { [weak self] (marketUpdated: Market) in

                    if marketUpdated.isAvailable {
                        self?.showMarketButtons()
                        print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will show \n")
                    }
                    else {
                        self?.showSuspendedView()
                        print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will hide \n")
                    }
                })

            if let outcome = market.outcomes[safe: 0] {
                
                self.homeOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
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
                    .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap({ $0 })
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                    .handleEvents(receiveOutput: { [weak self] outcome in
                        print("debugbetslip-\(outcome.bettingOffer.id) List Cell  \(outcome.bettingOffer.decimalOdd) left ")
                        self?.leftOutcome = outcome
                    })
                    .map(\.bettingOffer)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
                
                self.drawOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
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
                    .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap({ $0 })
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                    .handleEvents(receiveOutput: { [weak self] outcome in
                        print("debugbetslip-\(outcome.bettingOffer.id) List Cell  \(outcome.bettingOffer.decimalOdd) center ")
                        self?.middleOutcome = outcome
                    })
                    .map(\.bettingOffer)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
                
                self.awayOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
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
                    .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
                    .compactMap({ $0 })
                    .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
                    .handleEvents(receiveOutput: { [weak self] outcome in
                        print("debugbetslip-\(outcome.bettingOffer.id) List Cell  \(outcome.bettingOffer.decimalOdd) right ")
                        self?.rightOutcome = outcome
                    })
                    .map(\.bettingOffer)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
            
            if market.outcomes.count == 2 {
                awayBaseView.isHidden = true
            }
            else if market.outcomes.count == 1 {
                awayBaseView.isHidden = true
                drawBaseView.isHidden = true
            }
        }
        else {
            oddsStackView.alpha = 0.2
            self.showSeeAllView()
        }

        self.isFavorite = Env.favoritesManager.isEventFavorite(eventId: viewModel.match.id)

        // TODO: TEST CASHBACK
        if viewModel.matchWidgetType == .normal {
            if viewModel.match.sport.alphaId == "FBL" {
                self.hasCashback = true
            }
            else {
                self.hasCashback = false
            }
        }
    }

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
        if Env.favoritesManager.isEventFavorite(eventId: match.id) {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
            self.isFavorite = true
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
        if let viewModel = self.viewModel?.match {
            self.tappedMatchWidgetAction?(viewModel)
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
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isLeftOutcomeButtonSelected = true
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
        self.setupWithTheme()
    }

    func deselectMiddleOddButton() {
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
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ -> Void in
                    Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }

            let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ -> Void in
                self?.didTapShareButton()
            }
            actionSheetController.addAction(shareAction)

            let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ -> Void in }
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

        self.boostedTopRightCornerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.boostedTopRightCornerLabel.backgroundColor = .clear
        self.boostedTopRightCornerLabel.text = "BOOSTED\nODDS"
        self.boostedTopRightCornerLabel.font = AppFont.with(type: .bold, size: 10)
        
        self.boostedTopRightCornerLabel.adjustsFontSizeToFitWidth = true
        self.boostedTopRightCornerLabel.textAlignment = .left
        self.boostedTopRightCornerLabel.numberOfLines = 2
        self.boostedTopRightCornerLabel.textColor = UIColor.App.textPrimary

        let boostedTitleArrowView = BoostedArrowView()
        boostedTitleArrowView.translatesAutoresizingMaskIntoConstraints = false
        boostedTitleArrowView.isReversed = true

        self.boostedTopRightCornerBaseView.addSubview(self.boostedTopRightCornerLabel)
        self.boostedTopRightCornerBaseView.addSubview(boostedTitleArrowView)

        self.baseView.addSubview(self.boostedTopRightCornerBaseView)

        NSLayoutConstraint.activate([
            boostedTitleArrowView.widthAnchor.constraint(equalToConstant: 21),
            boostedTitleArrowView.heightAnchor.constraint(equalToConstant: 18),
            boostedTitleArrowView.leadingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.leadingAnchor),
            boostedTitleArrowView.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor, constant: 2),
            boostedTitleArrowView.bottomAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.bottomAnchor, constant: -2),

            self.boostedTopRightCornerLabel.leadingAnchor.constraint(equalTo: boostedTitleArrowView.trailingAnchor, constant: 2),
            self.boostedTopRightCornerLabel.trailingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.trailingAnchor),
            self.boostedTopRightCornerLabel.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor),
            self.boostedTopRightCornerLabel.bottomAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.bottomAnchor),
            self.boostedTopRightCornerLabel.widthAnchor.constraint(equalToConstant: 56),

            self.boostedTopRightCornerBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 8),
            self.boostedTopRightCornerBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 0),
        ])


    }

}
