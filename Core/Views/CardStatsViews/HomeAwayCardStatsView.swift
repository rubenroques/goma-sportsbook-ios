//
//  HomeAwayCardStatsView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/01/2022.
//

import UIKit

class HomeAwayCardStatsView: NibView {

    @IBOutlet private weak var homeValueLabel: UILabel!
    @IBOutlet private weak var homeProgressBar: UIProgressView!
    @IBOutlet private weak var awayValueLabel: UILabel!
    @IBOutlet private weak var awayProgressBar: UIProgressView!

    @IBOutlet private weak var captionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    override func commonInit() {

        self.setupWithTheme()

        self.homeValueLabel.text = "8/10"
        self.homeProgressBar.progress = 0.8

        self.awayValueLabel.text = "3/10"
        self.awayProgressBar.progress = 0.3

        self.captionLabel.text = "(Last 10 Matches)"
    }

    func setupWithTheme() {

        self.homeValueLabel.textColor = UIColor.App.headingSecondary
        self.homeProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.homeProgressBar.progressTintColor = UIColor(hex: 0xD99F00)

        self.awayValueLabel.textColor = UIColor.App.headingSecondary
        self.awayProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.awayProgressBar.progressTintColor = UIColor(hex: 0x46C1A7)

        self.captionLabel.textColor = UIColor.App.headingSecondary
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 38)
    }

}
