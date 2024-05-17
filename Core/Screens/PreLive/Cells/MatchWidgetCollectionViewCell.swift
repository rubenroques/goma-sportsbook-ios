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
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        
        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]
        
        return gradientBorderView
    }()
    
    lazy var liveGradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 2
        gradientBorderView.gradientCornerRadius = 9
        
        gradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                             UIColor.App.liveBorderGradient2,
                                             UIColor.App.liveBorderGradient1]
        
        return gradientBorderView
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
    
    @IBOutlet private weak var participantsBaseView: UIView!
    
    @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    @IBOutlet private weak var awayParticipantNameLabel: UILabel!
    
    @IBOutlet private weak var outrightNameBaseView: UIView!
    @IBOutlet private weak var outrightNameLabel: UILabel!
    
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
    
    // Outrights
    @IBOutlet private weak var outrightBaseView: UIView!
    @IBOutlet private weak var outrightSeeLabel: UILabel!
    
    // Boosted odds View
    private var boostedTopRightCornerBaseView = UIView()
    private var boostedTopRightCornerLabel = UILabel()
    
    // Market name view
    @IBOutlet private weak var marketNameView: UIView!
    @IBOutlet private weak var marketNameInnerView: UIView!
    @IBOutlet private weak var marketNameLabel: UILabel!
    
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
    
    //
    //
    var viewModel: MatchWidgetCellViewModel?
    
    static var normalCellHeight: CGFloat = 162
    static var smallCellHeight: CGFloat = 90
    
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
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var tappedMatchOutrightWidgetAction: ((Competition) -> Void)?
    
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
    
    private var leftOutcomeDisabled: Bool = false
    private var middleOutcomeDisabled: Bool = false
    private var rightOutcomeDisabled: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("BlinkDebug: cell awakeFromNib")
        
        // hide non normaml widget style elements
        self.backgroundImageView.isHidden = true
        
        self.topImageBaseView.layer.masksToBounds = true
        self.topImageBaseView.isHidden = true
        
        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true
        
        self.mainContentBaseView.isHidden = false
        //
        
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
        
        // Market view and label
        self.marketNameLabel.text = ""
        self.marketNameLabel.font = AppFont.with(type: .bold, size: 8)
        
        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true
        
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
        
        NSLayoutConstraint.activate([
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 20),
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
        
        self.hasCashback = false
        
        //
        self.createRedesignInterface()
        
        //
        self.adjustDesignToCardHeightStyle()
        self.setupWithTheme()
        
        
#if DEBUG
        let debugLabel = UILabel()
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.text = self.debugUUID.uuidString
        debugLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(debugLabel)
        
        NSLayoutConstraint.activate([
            debugLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            debugLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 15),
        ])
#endif
        
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
        
        self.locationFlagImageView.layer.borderWidth = 0.5
        
        self.topImageView.roundCorners(corners: [.topRight, .topLeft], radius: 9)
        
        self.marketNameInnerView.layer.cornerRadius = self.marketNameInnerView.frame.size.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("BlinkDebug: cell \(self.debugUUID.self) prepareForReuse")
        
        if let viewModel = self.viewModel {
            let viewModelDesc = "[\(viewModel.match.id) \(viewModel.match.homeParticipant.name) vs \(viewModel.match.awayParticipant.name)]"
            print("BlinkDebug: cell  \(self.debugUUID.self) old ViewModel: \(viewModelDesc)")
        }
        
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
        
        self.currentHomeOddValue = nil
        self.currentDrawOddValue = nil
        self.currentAwayOddValue = nil
        
        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false
        
        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        
        self.homeNameLabel.text = ""
        self.awayNameLabel.text = ""
        
        self.detailedScoreView.updateScores([:])
        
        self.outrightNameLabel.text = ""
        //
        self.dateStackView.isHidden = false
        self.resultStackView.isHidden = true
        
        self.dateLabel.isHidden = false
        self.timeLabel.isHidden = false
        
        self.dateLabel.text = ""
        self.timeLabel.text = ""
        
        self.dateNewLabel.text = ""
        self.timeNewLabel.text = ""
        
        self.liveMatchDotBaseView.isHidden = true
        self.liveTipView.isHidden = true
        
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true
        
        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""
        
        self.matchTimeStatusNewLabel.isHidden = true
        self.matchTimeStatusNewLabel.text = ""
        
        self.marketNameLabel.text = ""
        
        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true
        
        //
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
        self.outrightBaseView.isHidden = true
        
        self.cancellables.removeAll()
        
        self.adjustDesignToCardHeightStyle()
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
        self.baseView.backgroundColor = UIColor.App.backgroundCards
        
        self.liveMatchDotBaseView.backgroundColor = .clear
        self.liveMatchDotImageView.backgroundColor = .clear
        
        self.liveTipView.backgroundColor = UIColor.App.highlightPrimary
        
        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
        
        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        
        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary
        
        self.seeAllBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary
        
        self.outrightBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.outrightSeeLabel.textColor = UIColor.App.textPrimary
        
        self.locationFlagImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor
        
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
        
        //
        // Match Widget Type spec
        switch self.viewModel?.matchWidgetType ?? .normal {
        case .normal, .topImage:
            self.eventNameLabel.textColor = UIColor.App.textSecondary
            self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
            self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
            self.resultLabel.textColor = UIColor.App.textPrimary
            self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
            
            self.dateLabel.textColor = UIColor.App.textSecondary
            self.timeLabel.textColor = UIColor.App.textPrimary
            
            self.dateNewLabel.textColor = UIColor.App.textSecondary
            self.timeNewLabel.textColor = UIColor.App.textSecondary
            self.matchTimeStatusNewLabel.textColor = UIColor.App.buttonBackgroundPrimary
            
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
            self.marketNameLabel.textColor = UIColor.App.buttonTextPrimary
            
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
            // Live
            self.baseView.backgroundColor = UIColor.App.backgroundDrop
            self.contentRedesignBaseView.backgroundColor = self.baseView.backgroundColor
        default:
            self.baseView.backgroundColor = UIColor.App.backgroundCards
            self.contentRedesignBaseView.backgroundColor = self.baseView.backgroundColor
            
        }
        
        self.detailedScoreView.setupWithTheme()
        self.marketNamePillLabelView.setupWithTheme()
    }
    
    private func adjustMarketNameView(isShown: Bool) {
        
        if isShown {
            self.marketNameView.isHidden = false
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
            self.marketNameView.isHidden = true
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
        
        if (self.viewModel?.matchWidgetType ?? .normal) != .normal {
            return
        }
        
        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }
        
        self.cachedCardsStyle = StyleHelper.cardsStyleActive()
        
        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.contentRedesignBaseView.isHidden = true
            self.adjustDesignToSmallCardHeightStyle()
        case .normal:
            self.contentRedesignBaseView.isHidden = false
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
        
        let viewModelDesc = "[\(viewModel.match.id) \(viewModel.match.homeParticipant.name) vs \(viewModel.match.awayParticipant.name)]"
        print("BlinkDebug: cell  \(self.debugUUID.self) configure(withViewModel \(viewModelDesc)")
        
        Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.$matchWidgetType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus, matchWidgetType in
                switch matchWidgetType {
                case .normal, .boosted:
                    if matchWidgetStatus == .live {
                        self?.gradientBorderView.isHidden = true
                        self?.liveGradientBorderView.isHidden = false
                    }
                    else {
                        self?.gradientBorderView.isHidden = false
                        self?.liveGradientBorderView.isHidden = true
                    }
                case .topImage, .backgroundImage, .topImageOutright:
                    self?.gradientBorderView.isHidden = true
                    self?.liveGradientBorderView.isHidden = true
                }
            }
            .store(in: &self.cancellables)
        
        viewModel.$matchWidgetStatus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus in
                switch matchWidgetStatus {
                case .live:
                    self?.drawAsLiveCard()
                case .preLive, .unknown:
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
                case .topImage:
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
        
        viewModel.$homeOldBoostedOddAttributedString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.homeOldBoostedOddValueLabel.attributedText = newValue
            }
            .store(in: &self.cancellables)
        
        viewModel.$drawOldBoostedOddAttributedString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.drawOldBoostedOddValueLabel.attributedText = newValue
            }
            .store(in: &self.cancellables)
        
        viewModel.$awayOldBoostedOddAttributedString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.awayOldBoostedOddValueLabel.attributedText = newValue
            }
            .store(in: &self.cancellables)
        
        
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
                    self?.configureOutcomes(withMarket: market)
                    
                    if isAvailable {
                        self?.showMarketButtons()
                    }
                    else {
                        self?.showSuspendedView()
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
                .sink(receiveCompletion: { completion in
                    // print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
                .sink(receiveCompletion: { completion in
                    // print("middleOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
                .sink(receiveCompletion: { completion in
                    // print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
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
        
        if market.outcomes.count == 3 {
            self.homeBaseView.isHidden = false
            self.awayBaseView.isHidden = false
            self.drawBaseView.isHidden = false
        }
        else if market.outcomes.count == 2 {
            self.awayBaseView.isHidden = true
        }
        else if market.outcomes.count == 1 {
            self.awayBaseView.isHidden = true
            self.drawBaseView.isHidden = true
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

        self.boostedTopRightCornerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.boostedTopRightCornerLabel.backgroundColor = .clear
//        self.boostedTopRightCornerLabel.text = "BOOSTED\nODDS"
        self.boostedTopRightCornerLabel.text = "COTE\nBOOSTÉE"
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

extension MatchWidgetCollectionViewCell {
    
    func createRedesignInterface() {
        
        self.contentRedesignBaseView.backgroundColor = UIColor.App.backgroundCards
                
        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
        
        self.mainContentBaseView.addSubview(self.contentRedesignBaseView)
        self.contentRedesignBaseView.addSubview(self.topSeparatorAlphaLineView)
        
        self.contentRedesignBaseView.addSubview(self.detailedScoreView)
        
        self.contentRedesignBaseView.addSubview(self.homeNameLabel)
        self.contentRedesignBaseView.addSubview(self.awayNameLabel)
        
        self.contentRedesignBaseView.addSubview(self.dateNewLabel)
        self.contentRedesignBaseView.addSubview(self.timeNewLabel)
        
        self.contentRedesignBaseView.addSubview(self.matchTimeStatusNewLabel)
        
        self.contentRedesignBaseView.addSubview(self.marketNamePillLabelView)
        
        self.homeContentRedesignTopConstraint = self.homeNameLabel.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 13)
        self.awayContentRedesignTopConstraint = self.awayNameLabel.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 33)
        
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
            
            self.homeNameLabel.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            self.homeNameLabel.trailingAnchor.constraint(equalTo: self.detailedScoreView.leadingAnchor, constant: -5),
            self.homeContentRedesignTopConstraint,
            self.homeNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),
            
            self.awayNameLabel.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            self.awayNameLabel.trailingAnchor.constraint(equalTo: self.detailedScoreView.leadingAnchor, constant: -5),
            self.awayContentRedesignTopConstraint,
            self.awayNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),
            
            self.dateNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.dateNewLabel.topAnchor.constraint(equalTo: self.homeNameLabel.topAnchor),
            
            self.timeNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.timeNewLabel.bottomAnchor.constraint(equalTo: self.awayNameLabel.bottomAnchor),
            
            self.matchTimeStatusNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.matchTimeStatusNewLabel.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -6),
            
            self.marketNamePillLabelView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 11),
            self.marketNamePillLabelView.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -4),
        ])
        
    }
    
}
