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

        self.captionLabel.text = "(Last Matches)"
    }

    func setupWithTheme() {

        self.homeValueLabel.textColor = UIColor.App.textPrimary
        self.homeProgressBar.trackTintColor = UIColor.App.backgroundTertiary
        self.homeProgressBar.progressTintColor = UIColor(hex: 0xD99F00)

        self.awayValueLabel.textColor = UIColor.App.textPrimary
        self.awayProgressBar.trackTintColor = UIColor.App.backgroundTertiary
        self.awayProgressBar.progressTintColor = UIColor(hex: 0x46C1A7)

        self.captionLabel.textColor = UIColor.App.textSecond
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    func setupHomeValues(win: Int, total: Int) {
        self.homeValueLabel.text = "\(win)/\(total)"
        if total != 0 {
            self.homeProgressBar.progress = Float(win) / Float(total)
        }
        else {
            self.homeProgressBar.progress = 0
        }
    }

    func setupAwayValues(win: Int, total: Int) {
        self.awayValueLabel.text = "\(win)/\(total)"
        if total != 0 {
            self.awayProgressBar.progress = Float(win) / Float(total)
        }
        else {
            self.awayProgressBar.progress = 0
        }
    }

}
