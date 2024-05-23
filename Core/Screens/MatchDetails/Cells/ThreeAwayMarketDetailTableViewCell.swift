//
//  ThreeAwayMarketDetailTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import UIKit

class ThreeAwayMarketDetailTableViewCell: UITableViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var columnsBaseView: UIView!

    @IBOutlet private var leftColumnsBaseView: UIView!
    @IBOutlet private var middleColumnsBaseView: UIView!
    @IBOutlet private var rightColumnsBaseView: UIView!

    @IBOutlet private var leftColumnsStackView: UIStackView!
    @IBOutlet private var middleColumnsStackView: UIStackView!
    @IBOutlet private var rightColumnsStackView: UIStackView!

    @IBOutlet private var expandBaseView: UIView!
    @IBOutlet private var expandLabel: UILabel!
    @IBOutlet private var expandArrowImageView: UIImageView!

    @IBOutlet private var expandAllBaseView: UIView!
    @IBOutlet private var expandAllArrowImageView: UIImageView!
    @IBOutlet private var cashbackIconImageView: UIImageView!
    @IBOutlet private var customBetIconImageView: UIImageView!
    
    lazy var gradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        return gradientBorderView
    }()

    var match: Match?
    var marketId: String?
    var marketGroupOrganizer: MarketGroupOrganizer?
    var competitionName: String?
    
    private let lineHeight: CGFloat = 56

    private let collapsedMaxNumberOfLines = 4
    var seeAllOutcomes = false {
        didSet {
            if seeAllOutcomes {
                self.expandArrowImageView.image = UIImage(named: "arrow_up_icon")
                self.expandLabel.text = localized("see_less")
            }
            else {
                self.expandArrowImageView.image = UIImage(named: "arrow_down_icon")
                self.expandLabel.text = localized("see_all")
            }
        }
    }

    var isAllExpanded = false {
        didSet {
            if isAllExpanded {
                self.expandAllArrowImageView.image = UIImage(named: "arrow_up_icon")
            }
            else {
                self.expandAllArrowImageView.image = UIImage(named: "arrow_down_icon")
            }
        }
    }
    
    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }
    
    var customBetAvailable: Bool = false {
        didSet {
            self.customBetIconImageView.isHidden = !customBetAvailable
        }
    }

    var didExpandCellAction: ((String) -> Void)?
    var didColapseCellAction: ((String) -> Void)?

    var didExpandAllCellAction: ((String) -> Void)?
    var didColapseAllCellAction: ((String) -> Void)?

    var didLongPressOdd: ((BettingTicket) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = 9

        self.titleLabel.text = localized("market")
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)

        let expandTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapExpandBaseView))
        self.expandBaseView.addGestureRecognizer(expandTapGesture)

        let expandAllTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapExpandAllBaseView))
        self.expandAllBaseView.addGestureRecognizer(expandAllTapGesture)

        self.expandAllArrowImageView.image = UIImage(named: "small_arrow_down_icon")
        
        self.cashbackIconImageView.image = UIImage(named: "cashback_small_blue_icon")
        self.cashbackIconImageView.contentMode = .scaleAspectFit
        
        self.hasCashback = false
        
        self.customBetIconImageView.image = UIImage(named: "mix_match_icon")
        self.customBetIconImageView.contentMode = .scaleAspectFit
        
        self.customBetAvailable = false
        
        self.containerView.addSubview(gradientBorderView)
        self.containerView.sendSubviewToBack(gradientBorderView)

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor),
        ])

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.match = nil
        self.marketId = nil
        self.marketGroupOrganizer = nil

        self.competitionName = nil

        self.expandBaseView.isHidden = false
        self.seeAllOutcomes = false
        self.isAllExpanded = true
        self.hasCashback = false
        self.customBetAvailable = false

        self.leftColumnsStackView.removeAllArrangedSubviews()
        self.middleColumnsStackView.removeAllArrangedSubviews()
        self.rightColumnsStackView.removeAllArrangedSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundCards
        self.expandBaseView.backgroundColor = UIColor.App.backgroundCards

        self.expandLabel.textColor = UIColor.App.textPrimary
        self.titleLabel.textColor = UIColor.App.textPrimary
        
    }

    func configure(withMarketGroupOrganizer marketGroupOrganizer: MarketGroupOrganizer,
                   seeAllOutcomes: Bool,
                   isExpanded: Bool,
                   betBuilderGrayoutsState: BetBuilderGrayoutsState) {

        self.marketGroupOrganizer = marketGroupOrganizer
        self.seeAllOutcomes = seeAllOutcomes
        self.isAllExpanded = isExpanded

        self.titleLabel.text = marketGroupOrganizer.marketName

        if !self.isAllExpanded {
            // if all collapsed we only setup the title
            self.expandBaseView.isHidden = true
            return
        }

        if marketGroupOrganizer.numberOfLines <= collapsedMaxNumberOfLines {
            self.expandBaseView.isHidden = true
        }

        for line in 0 ..< marketGroupOrganizer.numberOfLines {

            if !seeAllOutcomes && line >= collapsedMaxNumberOfLines {
                break
            }
            
            for column in 0 ..< marketGroupOrganizer.numberOfColumns {

                let outcome = marketGroupOrganizer.outcomeFor(column: column, line: line)

                var columnStackView: UIStackView?
                switch column {
                case 0:
                    columnStackView = leftColumnsStackView
                case 1:
                    columnStackView = middleColumnsStackView
                case 2:
                    columnStackView = rightColumnsStackView
                default: ()
                }

                if let stackView = columnStackView {
                    if let outcomeValue = outcome {
                        let outcomeSelectionButtonView = OutcomeSelectionButtonView()
                        outcomeSelectionButtonView.match = self.match
                        outcomeSelectionButtonView.competitionName = self.competitionName
                        outcomeSelectionButtonView.marketId = self.marketId
                        
                        outcomeSelectionButtonView.didLongPressOdd = { [weak self] bettingTicket in
                            self?.didLongPressOdd?(bettingTicket)
                        }
                        
                        outcomeSelectionButtonView.configureWith(outcome: outcomeValue)
                        if betBuilderGrayoutsState.shouldGrayoutOutcome(withId: outcomeValue.id) {
                            outcomeSelectionButtonView.blockOutcomeInteraction()
                        }
                        
                        stackView.addArrangedSubview(outcomeSelectionButtonView)
                    }
                    else {
                        let clearView = UIView()
                        clearView.backgroundColor = .clear
                        clearView.translatesAutoresizingMaskIntoConstraints = false

                        stackView.addArrangedSubview(clearView)
                    }
                }
            }
        }
        
        if let match = self.match {
            self.hasCashback = RePlayFeatureHelper.shouldShowRePlay(forMatch: match)
            
            if let market = match.markets.filter({
                $0.id == marketGroupOrganizer.marketId
            }).first {
                if let customBetAvailable = market.customBetAvailable {
                    self.customBetAvailable = customBetAvailable ? true : false
                }
                else {
                    self.customBetAvailable = false
                }
            }
        }
        
    }

    @objc func didTapExpandBaseView() {
        guard
            let marketGroupOrganizerId = self.marketGroupOrganizer?.marketId
        else {
            return
        }

        if self.seeAllOutcomes {
            self.didColapseCellAction?(marketGroupOrganizerId)
        }
        else {
            self.didExpandCellAction?(marketGroupOrganizerId)
        }
    }

    @objc func didTapExpandAllBaseView() {
        guard
            let marketGroupOrganizerId = self.marketGroupOrganizer?.marketId
        else {
            return
        }

        if self.isAllExpanded {
            self.didColapseAllCellAction?(marketGroupOrganizerId)
        }
        else {
            self.didExpandAllCellAction?(marketGroupOrganizerId)
        }
    }

}
