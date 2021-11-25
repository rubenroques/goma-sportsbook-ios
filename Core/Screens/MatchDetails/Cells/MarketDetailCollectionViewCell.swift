//
//  MarketDetailCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/11/2021.
//

import UIKit

class MarketDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var marketTypeLabel: UILabel!
    @IBOutlet private var marketOddLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.marketTypeLabel.text = "Market Type"

        self.marketOddLabel.text = "1.0"
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.mainBackground
        self.containerView.layer.cornerRadius = CornerRadius.button

        self.marketTypeLabel.textColor = UIColor.App.headingMain
        self.marketTypeLabel.font = AppFont.with(type: .medium, size: 11)

        self.marketOddLabel.textColor = UIColor.App.headingMain
        self.marketOddLabel.font = AppFont.with(type: .bold, size: 13)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupDetails(marketType: String, marketOdd: String) {
        self.marketTypeLabel.text = marketType

        self.marketOddLabel.text = marketOdd
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        //self.marketTypeLabel.text = ""

        //self.marketOddLabel.text = ""
    }

}
