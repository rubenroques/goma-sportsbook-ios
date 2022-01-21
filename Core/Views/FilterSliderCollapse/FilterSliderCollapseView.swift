//
//  FilterSliderCollapseView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/10/2021.
//

import UIKit
import Foundation

class FilterSliderCollapseView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var topView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleButton: UIButton!
    @IBOutlet private var checkboxButton: CheckboxButton!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var leftContentView: FilterSliderInfoView!
    @IBOutlet private var rightContentView: FilterSliderInfoView!
    // Constraints
    @IBOutlet private var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewFullHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var topViewBottomConstraint: NSLayoutConstraint!
    // Variables
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                toggleButton.setImage(UIImage(named: "arrow_up_icon"), for: .normal)

                viewHeightConstraint.isActive = true

                topViewBottomConstraint.isActive = true
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                    self.containerStackView.alpha = 0
                }, completion: { _ in
                    self.containerStackView.isHidden = true
                })
                animateView(hiddenFlow: true)
            }
            else {
                toggleButton.setImage(UIImage(named: "arrow_down_icon"), for: .normal)
                viewHeightConstraint.isActive = false

                topViewBottomConstraint.isActive = false

                UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseOut, animations: {
                    self.containerStackView.alpha = 1
                    self.containerStackView.isHidden = false
                }, completion: { _ in
                })
                animateView(hiddenFlow: false)
            }
        }
    }
    var hasCheckbox = false {
        didSet {
            if hasCheckbox {
                checkboxButton.isHidden = false
                contentView.isUserInteractionEnabled = false
                contentView.alpha = disabledAlpha
                stackView.isUserInteractionEnabled = false
                stackView.alpha = disabledAlpha
            }
            else {
                checkboxButton.isHidden = true
            }
        }
    }

    var hasSliderInfo = false {
        didSet {
            if hasSliderInfo {
                stackView.isHidden = false
            }
            else {
                stackView.isHidden = true
            }
            self.layoutIfNeeded()
        }
    }
    var enabledAlpha: CGFloat = 1.0
    var disabledAlpha: CGFloat = 0.7

    var didToggle: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {

        self.backgroundColor = UIColor.App2.backgroundPrimary

        containerView.backgroundColor = UIColor.App2.backgroundSecondary

        containerView.layer.cornerRadius = CornerRadius.modal

        topView.backgroundColor = UIColor.App2.backgroundSecondary
        topView.layer.cornerRadius = CornerRadius.modal

        titleLabel.text = "Test"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.textColor = UIColor.App2.textPrimary

        toggleButton.backgroundColor = UIColor.App2.backgroundSecondary

        checkboxButton.isHidden = true
        checkboxButton.didTapCheckbox = { value in
            if value {
                self.stackView.isUserInteractionEnabled = true
                self.contentView.isUserInteractionEnabled = true

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.stackView.alpha = self.enabledAlpha
                    self.contentView.alpha = self.enabledAlpha
                }, completion: { _ in
                })
            }
            else {
                self.stackView.isUserInteractionEnabled = false
                self.contentView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.stackView.alpha = self.disabledAlpha
                    self.contentView.alpha = self.disabledAlpha
                }, completion: { _ in
                })
            }
        }

        contentView.backgroundColor = UIColor.App2.backgroundSecondary

        stackView.backgroundColor = UIColor.App2.backgroundSecondary
        stackView.isHidden = true

    }

    func setTitle(title: String) {
        titleLabel.text = title
        
    }
    
    func setTitleWithBold(title: String, charToSplit: String.Element) {
        let boldText = title.split(separator: charToSplit)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        if boldText.count > 1 {
            let normalString = NSMutableAttributedString(string: String(boldText[0]+": "), attributes: attrs)
            let boldString = NSMutableAttributedString(string: String(boldText[1]))
            normalString.append(boldString)
            titleLabel.attributedText = normalString
        }
        else {
            titleLabel.text = title
        }
    }

    func setCheckboxSelected(selected: Bool) {
        checkboxButton.isChecked = selected
        if selected {
            stackView.isUserInteractionEnabled = true
            stackView.alpha = enabledAlpha
            contentView.isUserInteractionEnabled = true
            contentView.alpha = enabledAlpha
        }
        else {
            stackView.isUserInteractionEnabled = false
            stackView.alpha = disabledAlpha
            contentView.isUserInteractionEnabled = false
            contentView.alpha = disabledAlpha
        }
    }

    func updateOddsLabels(fromText: String, toText: String) {
        leftContentView.setLabels(topTitle: "\(localized("from")):", bottomTitle: fromText)
        rightContentView.setLabels(topTitle: "\(localized("to")):", bottomTitle: toText)
    }

    func getContentView() -> UIView {
        return contentView
    }

    func animateView(hiddenFlow: Bool) {
        if hiddenFlow {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in

            })
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in

            })
        }

    }

    @IBAction private func toggleCollapseAction() {
        isCollapsed = !isCollapsed
        didToggle?(isCollapsed)
    }
}
