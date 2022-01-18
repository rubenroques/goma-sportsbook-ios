//
//  FilterCollapseView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/10/2021.
//

import Foundation
import UIKit

class FilterCollapseView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var topView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleButton: UIButton!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var checkboxButton: CheckboxButton!
    // Constraints
    @IBOutlet private var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var topViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var topViewStackConstraints: NSLayoutConstraint!
    // Variables
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                toggleButton.setImage(UIImage(named: "arrow_up_icon"), for: .normal)
                stackViewHeightConstraint.isActive = true
                viewHeightConstraint.isActive = true
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.stackView.alpha = 0
                }, completion: { _ in
                    self.stackView.isHidden = true
                })
                topViewBottomConstraint.isActive = true
                topViewStackConstraints.isActive = false
                animateView(hiddenFlow: true)
            }
            else {
                toggleButton.setImage(UIImage(named: "arrow_down_icon"), for: .normal)
                stackViewHeightConstraint.isActive = false
                viewHeightConstraint.isActive = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    if self.stackView.alpha != self.enabledAlpha && self.stackView.alpha != 0 {
                        self.stackView.alpha = self.disabledAlpha
                    }
                    else {
                        self.stackView.alpha = self.enabledAlpha
                    }
                    self.stackView.isHidden = false
                }, completion: { _ in
                })
                topViewBottomConstraint.isActive = false
                topViewStackConstraints.isActive = true
                animateView(hiddenFlow: false)
            }
        }
    }
    var hasCheckbox = false {
        didSet {
            if hasCheckbox {
                checkboxButton.isHidden = false
                stackView.isUserInteractionEnabled = false
                stackView.alpha = disabledAlpha
                self.layoutIfNeeded()
            }
            else {
                checkboxButton.isHidden = true
                stackView.alpha = enabledAlpha
                self.layoutIfNeeded()
            }
        }
    }
    var disabledAlpha: CGFloat = 0.7
    var enabledAlpha: CGFloat = 1.0

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
        self.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.secondaryBackground

        containerView.layer.cornerRadius = CornerRadius.modal

        topView.backgroundColor = UIColor.App.secondaryBackground
        topView.layer.cornerRadius = CornerRadius.modal

        titleLabel.text = "Test"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.textColor = UIColor.App.headingMain

        toggleButton.backgroundColor = UIColor.App.secondaryBackground

        checkboxButton.isHidden = true

        checkboxButton.didTapCheckbox = { value in
            if value {
                self.stackView.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.stackView.alpha = self.enabledAlpha
                }, completion: { _ in
                })
            }
            else {
                self.stackView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.stackView.alpha = self.disabledAlpha
                }, completion: { _ in
                })
            }
        }

        stackView.backgroundColor = UIColor.App.secondaryBackground
        stackView.alpha = enabledAlpha

    }

    func setTitle(title: String) {
        titleLabel.text = title
    }

    func setCheckboxSelected(selected: Bool) {
        checkboxButton.isChecked = selected
        if selected {
            stackView.isUserInteractionEnabled = true
            stackView.alpha = enabledAlpha
        }
        else {
            stackView.isUserInteractionEnabled = false
            stackView.alpha = disabledAlpha
        }
    }

    func addViewtoStack(view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func animateView(hiddenFlow: Bool) {
        if hiddenFlow {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.stackView.layoutIfNeeded()
                self.layoutIfNeeded()
            }, completion: { _ in
            })
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.stackView.layoutIfNeeded()
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
