//
//  ThreeAwayMarketDetailTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import UIKit

class OverUnderMarketDetailTableViewCell: UITableViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var columnsBaseView: UIView!

    @IBOutlet private var leftColumnsBaseView: UIView!
    @IBOutlet private var rightColumnsBaseView: UIView!

    @IBOutlet private var leftColumnsStackView: UIStackView!
    @IBOutlet private var rightColumnsStackView: UIStackView!

    var match: Match?
    var market: Market?
    var mergedMarketGroup: MergedMarketGroup?

    private let lineHeight: CGFloat = 56

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.titleLabel.text = "Market"
        self.titleLabel.font = AppFont.with(type: .bold, size: 14)


        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.match = nil
        self.market = nil
        self.mergedMarketGroup = nil

        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.leftColumnsStackView.removeAllArrangedSubviews()
        self.rightColumnsStackView.removeAllArrangedSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.containerView.backgroundColor = UIColor.App.secondaryBackground
        self.titleLabel.textColor = UIColor.App.headingMain
    }

    func configure(withMarketGroupOrganizer marketGroupOrganizer: MarketGroupOrganizer) {
        
        self.titleLabel.text = marketGroupOrganizer.marketName

        for line in 0 ..< marketGroupOrganizer.numberOfLines {
            for column in 0 ..< marketGroupOrganizer.numberOfColumns {

                let outcome = marketGroupOrganizer.outcomeFor(column: column, line: line)

                var columnStackView: UIStackView?
                switch column {
                case 0:
                    columnStackView = leftColumnsStackView
                case 1:
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

    func configure(withMergedMarketGroup mergedMarketGroup: MergedMarketGroup) {
        self.mergedMarketGroup = mergedMarketGroup

        self.titleLabel.text = mergedMarketGroup.name

        var orderedKeys = Array(mergedMarketGroup.outcomes.keys)
        orderedKeys = orderedKeys.sorted(by: { OddOutcomesSortingHelper.sortValueForOutcome($0) < OddOutcomesSortingHelper.sortValueForOutcome($1) } )

        if orderedKeys.count == 2 {
            
            var sortedLeftOutcome = mergedMarketGroup.outcomes[orderedKeys[0]] ?? []
            var sortedRightOutcome = mergedMarketGroup.outcomes[orderedKeys[1]] ?? []

            sortedLeftOutcome = sortedLeftOutcome.sorted(by: {
                let leftV = ($0.nameDigit1 ?? 0.0) + ($0.nameDigit2 ?? 0.0) + ($0.nameDigit3 ?? 0.0)
                let rightV = ($1.nameDigit1 ?? 0.0) + ($1.nameDigit2 ?? 0.0) + ($1.nameDigit3 ?? 0.0)
                return leftV < rightV
            })
            sortedRightOutcome = sortedRightOutcome.sorted(by: {
                let leftV = ($0.nameDigit1 ?? 0.0) + ($0.nameDigit2 ?? 0.0) + ($0.nameDigit3 ?? 0.0)
                let rightV = ($1.nameDigit1 ?? 0.0) + ($1.nameDigit2 ?? 0.0) + ($1.nameDigit3 ?? 0.0)
                return leftV < rightV
            })

            for outcome in sortedLeftOutcome {
                let outcomeSelectionButtonView = OutcomeSelectionButtonView()
                outcomeSelectionButtonView.match = self.match
                outcomeSelectionButtonView.configureWith(outcome: outcome)
                leftColumnsStackView.addArrangedSubview(outcomeSelectionButtonView)
            }

            for outcome in sortedRightOutcome {
                let outcomeSelectionButtonView = OutcomeSelectionButtonView()
                outcomeSelectionButtonView.match = self.match
                outcomeSelectionButtonView.configureWith(outcome: outcome)
                rightColumnsStackView.addArrangedSubview(outcomeSelectionButtonView)
            }
        }

    }

}
