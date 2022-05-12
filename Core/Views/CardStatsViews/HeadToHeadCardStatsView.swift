//
//  HeadToHeadCardStatsView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/01/2022.
//

import UIKit

class HeadToHeadCardStatsView: NibView {

    @IBOutlet private weak var winTitleLabel: UILabel!
    @IBOutlet private weak var winHomeValueLabel: UILabel!
    @IBOutlet private weak var winHomeProgressBar: UIProgressView!
    @IBOutlet private weak var winAwayValueLabel: UILabel!
    @IBOutlet private weak var winAwayProgressBar: UIProgressView!

    @IBOutlet private weak var drawTitleLabel: UILabel!
    @IBOutlet private weak var drawHomeValueLabel: UILabel!
    @IBOutlet private weak var drawHomeProgressBar: UIProgressView!
    @IBOutlet private weak var drawAwayValueLabel: UILabel!
    @IBOutlet private weak var drawAwayProgressBar: UIProgressView!

    @IBOutlet private weak var lossTitleLabel: UILabel!
    @IBOutlet private weak var lossHomeValueLabel: UILabel!
    @IBOutlet private weak var lossHomeProgressBar: UIProgressView!
    @IBOutlet private weak var lossAwayValueLabel: UILabel!
    @IBOutlet private weak var lossAwayProgressBar: UIProgressView!

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

        self.winHomeValueLabel.text = "9"
        self.winHomeProgressBar.progress = 0.9
        self.drawHomeValueLabel.text = "0"
        self.drawHomeProgressBar.progress = 0.0
        self.lossHomeValueLabel.text = "1"
        self.lossHomeProgressBar.progress = 0.1

        self.winAwayValueLabel.text = "2"
        self.winAwayProgressBar.progress = 0.2
        self.drawAwayValueLabel.text = "5"
        self.drawAwayProgressBar.progress = 0.5
        self.lossAwayValueLabel.text = "3"
        self.lossAwayProgressBar.progress = 0.3

        self.captionLabel.text = "(Last Matches)"
    }

    func setupHomeValues(win: Int, draw: Int, loss: Int, total: Int) {
        self.winHomeValueLabel.text = "\(win)"
        self.drawHomeValueLabel.text = "\(draw)"
        self.lossHomeValueLabel.text = "\(loss)"

        if total != 0 {
            self.winHomeProgressBar.progress = Float(win) / Float(total)
            self.drawHomeProgressBar.progress = Float(draw) / Float(total)
            self.lossHomeProgressBar.progress = Float(loss) / Float(total)
        }
        else {
            self.winHomeProgressBar.progress = 0
            self.drawHomeProgressBar.progress = 0
            self.lossHomeProgressBar.progress = 0
        }
    }

    func setupAwayValues(win: Int, draw: Int, loss: Int, total: Int) {
        self.winAwayValueLabel.text = "\(win)"
        self.drawAwayValueLabel.text = "\(draw)"
        self.lossAwayValueLabel.text = "\(loss)"

        if total != 0 {
            self.winAwayProgressBar.progress = Float(win) / Float(total)
            self.drawAwayProgressBar.progress = Float(draw) / Float(total)
            self.lossAwayProgressBar.progress = Float(loss) / Float(total)
        }
        else {
            self.winAwayProgressBar.progress = 0
            self.drawAwayProgressBar.progress = 0
            self.lossAwayProgressBar.progress = 0
        }
    }

    func setupCaptionText(_ captionText: String) {
        self.captionLabel.text = captionText
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let rotated = CGAffineTransform.identity.rotated(by: Double.pi)

        self.winHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.winHomeProgressBar.transform = rotated

        self.drawHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.drawHomeProgressBar.transform = rotated

        self.lossHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.lossHomeProgressBar.transform = rotated
    }

    func setupWithTheme() {

        self.winTitleLabel.textColor = UIColor.App.textPrimary
        self.winHomeValueLabel.textColor = UIColor.App.textPrimary
        self.winHomeProgressBar.trackTintColor = UIColor.App.scroll
        self.winHomeProgressBar.progressTintColor = UIColor.App.statsHome
        self.winAwayValueLabel.textColor = UIColor.App.textPrimary
        self.winAwayProgressBar.trackTintColor = UIColor.App.scroll
        self.winAwayProgressBar.progressTintColor = UIColor.App.statsAway

        self.drawTitleLabel.textColor = UIColor.App.textPrimary
        self.drawHomeValueLabel.textColor = UIColor.App.textPrimary
        self.drawHomeProgressBar.trackTintColor = UIColor.App.scroll
        self.drawHomeProgressBar.progressTintColor = UIColor.App.statsHome
        self.drawAwayValueLabel.textColor = UIColor.App.textPrimary
        self.drawAwayProgressBar.trackTintColor = UIColor.App.scroll
        self.drawAwayProgressBar.progressTintColor = UIColor.App.statsAway

        self.lossTitleLabel.textColor = UIColor.App.textPrimary
        self.lossHomeValueLabel.textColor = UIColor.App.textPrimary
        self.lossHomeProgressBar.trackTintColor = UIColor.App.scroll
        self.lossHomeProgressBar.progressTintColor = UIColor.App.statsHome
        self.lossAwayValueLabel.textColor = UIColor.App.textPrimary
        self.lossAwayProgressBar.trackTintColor = UIColor.App.scroll
        self.lossAwayProgressBar.progressTintColor = UIColor.App.statsAway

        self.captionLabel.textColor = UIColor.App.textSecondary
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 52)
    }

}
