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

        self.winHomeValueLabel.text = "9/10"
        self.winHomeProgressBar.progress = 0.9
        self.drawHomeValueLabel.text = "0/10"
        self.drawHomeProgressBar.progress = 0.0
        self.lossHomeValueLabel.text = "1/10"
        self.lossHomeProgressBar.progress = 0.1

        self.winAwayValueLabel.text = "2/10"
        self.winAwayProgressBar.progress = 0.2
        self.drawAwayValueLabel.text = "5/10"
        self.drawAwayProgressBar.progress = 0.5
        self.lossAwayValueLabel.text = "3/10"
        self.lossAwayProgressBar.progress = 0.3

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: winHomeProgressBar.frame.size.height)
        let rotated = CGAffineTransform.identity.rotated(by: Double.pi)

        self.winHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.winHomeProgressBar.transform = rotated

        self.drawHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.drawHomeProgressBar.transform = rotated

        self.lossHomeProgressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.lossHomeProgressBar.transform = rotated
    }

    func setupWithTheme() {

        self.winTitleLabel.textColor = UIColor.App.headingMain
        self.winHomeValueLabel.textColor = UIColor.App.headingMain
        self.winHomeProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.winHomeProgressBar.progressTintColor = UIColor(hex: 0xD99F00)
        self.winAwayValueLabel.textColor = UIColor.App.headingMain
        self.winAwayProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.winAwayProgressBar.progressTintColor = UIColor(hex: 0x46C1A7)

        self.drawTitleLabel.textColor = UIColor.App.headingMain
        self.drawHomeValueLabel.textColor = UIColor.App.headingMain
        self.drawHomeProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.drawHomeProgressBar.progressTintColor = UIColor(hex: 0xD99F00)
        self.drawAwayValueLabel.textColor = UIColor.App.headingMain
        self.drawAwayProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.drawAwayProgressBar.progressTintColor = UIColor(hex: 0x46C1A7)

        self.lossTitleLabel.textColor = UIColor.App.headingMain
        self.lossHomeValueLabel.textColor = UIColor.App.headingMain
        self.lossHomeProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.lossHomeProgressBar.progressTintColor = UIColor(hex: 0xD99F00)
        self.lossAwayValueLabel.textColor = UIColor.App.headingMain
        self.lossAwayProgressBar.trackTintColor = UIColor.App.tertiaryBackground
        self.lossAwayProgressBar.progressTintColor = UIColor(hex: 0x46C1A7)

        self.captionLabel.textColor = UIColor.App.headingSecondary
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 38)
    }

}
