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
        self.containerView.backgroundColor = UIColor.App.secondaryBackground
        self.titleLabel.textColor = UIColor.App.headingMain
    }

    func configure(withMergedMarketGroup mergedMarketGroup: MergedMarketGroup) {
        self.mergedMarketGroup = mergedMarketGroup

        self.titleLabel.text = mergedMarketGroup.name

        var orderedKeys = Array(mergedMarketGroup.outcomes.keys)
        orderedKeys = orderedKeys.sorted(by: { OddOutcomesSortingHelper.sortValueForOutcome($0) < OddOutcomesSortingHelper.sortValueForOutcome($1) } )

        if orderedKeys.count == 3 {
            var sortedLeftOutcome = mergedMarketGroup.outcomes[ orderedKeys[0] ] ?? []
            var sortedMiddleOutcome = mergedMarketGroup.outcomes[ orderedKeys[1] ] ?? []
            var sortedRightOutcome = mergedMarketGroup.outcomes[ orderedKeys[2] ] ?? []

            sortedLeftOutcome = sortedLeftOutcome.sorted(by: {
                let leftV = ($0.nameDigit1 ?? 0.0) + ($0.nameDigit2 ?? 0.0) + ($0.nameDigit3 ?? 0.0)
                let rightV = ($1.nameDigit1 ?? 0.0) + ($1.nameDigit2 ?? 0.0) + ($1.nameDigit3 ?? 0.0)
                return leftV < rightV
            })
            sortedMiddleOutcome = sortedMiddleOutcome.sorted(by: {
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

            for outcome in sortedMiddleOutcome {
                let outcomeSelectionButtonView = OutcomeSelectionButtonView()
                outcomeSelectionButtonView.match = self.match
                outcomeSelectionButtonView.configureWith(outcome: outcome)
                middleColumnsStackView.addArrangedSubview(outcomeSelectionButtonView)
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
