//
//  FilterSliderInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 15/10/2021.
//

import Foundation
import UIKit

class FilterSliderInfoView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var topLabel: UILabel!
    @IBOutlet private var bottomLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {
        self.backgroundColor = UIColor.App.separatorLine
        self.layer.cornerRadius = CornerRadius.modal

        containerView.backgroundColor = UIColor.App.separatorLine
        containerView.layer.cornerRadius = CornerRadius.modal

        topLabel.text = "Top"
        topLabel.textColor = UIColor.App.textPrimary
        topLabel.font = AppFont.with(type: .semibold, size: 12)

        bottomLabel.text = "Bottom"
        bottomLabel.textColor = UIColor.App.textPrimary
        bottomLabel.font = AppFont.with(type: .semibold, size: 16)
    }

    func setLabels(topTitle: String, bottomTitle: String) {
        topLabel.text = topTitle
        bottomLabel.text = bottomTitle
    }
}
