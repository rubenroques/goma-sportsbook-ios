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

    var match: Match?
    var market: Market?
    var marketGroupOrganizer: MarketGroupOrganizer?

    private let lineHeight: CGFloat = 56

    private let collapsedMaxNumberOfLines = 4
    var isExpanded = false {
        didSet {
            if isExpanded {
                self.expandArrowImageView.image = UIImage(named: "arrow_up_icon")
                self.expandLabel.text = localized("see_less")
            }
            else {
                self.expandArrowImageView.image = UIImage(named: "arrow_down_icon")
                self.expandLabel.text = localized("see_all")
            }
        }
    }

    var didExpandCellAction: ((String) -> Void)?
    var didColapseCellAction: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.titleLabel.text = localized("market")
        self.titleLabel.font = AppFont.with(type: .bold, size: 14)

        let expandTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapExpandBaseView))
        self.expandBaseView.addGestureRecognizer(expandTapGesture)
        
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.match = nil
        self.market = nil
        self.marketGroupOrganizer = nil

        self.expandBaseView.isHidden = false
        self.isExpanded = false
        
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

    func configure(withMarketGroupOrganizer marketGroupOrganizer: MarketGroupOrganizer, isExpanded: Bool) {

        self.marketGroupOrganizer = marketGroupOrganizer
        self.isExpanded = isExpanded

        self.titleLabel.text = marketGroupOrganizer.marketName

        if marketGroupOrganizer.numberOfLines <= collapsedMaxNumberOfLines {
            self.expandBaseView.isHidden = true
        }

        for line in 0 ..< marketGroupOrganizer.numberOfLines {

            if !isExpanded && line >= collapsedMaxNumberOfLines {
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
                        outcomeSelectionButtonView.configureWith(outcome: outcomeValue)
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
    }

    @objc func didTapExpandBaseView() {
        guard
            let marketGroupOrganizerId = self.marketGroupOrganizer?.marketId
        else {
            return
        }

        if self.isExpanded {
            self.didColapseCellAction?(marketGroupOrganizerId)
        }
        else {
            self.didExpandCellAction?(marketGroupOrganizerId)
        }
    }

}
