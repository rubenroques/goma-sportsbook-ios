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
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleButton: UIButton!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var checkboxButton: CheckboxButton!
    //Constraints
    @IBOutlet var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var labelLeadingButtonConstraint: NSLayoutConstraint!
    @IBOutlet var labelLeadingViewConstraint: NSLayoutConstraint!
    // Variables
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                toggleButton.setImage(UIImage(named: "arrow_up_icon"), for: .normal)
                stackViewHeightConstraint.isActive = true
                viewHeightConstraint.isActive = true
                self.stackView.isHidden = true
                animateView(hiddenFlow: true)
            }
            else {
                toggleButton.setImage(UIImage(named: "arrow_down_icon"), for: .normal)
                stackViewHeightConstraint.isActive = false
                viewHeightConstraint.isActive = false
                self.stackView.isHidden = false
                animateView(hiddenFlow: false)
            }
        }
    }
    var hasCheckbox = false {
        didSet {
            if hasCheckbox {
                labelLeadingButtonConstraint.isActive = true
                labelLeadingViewConstraint.isActive = false
                checkboxButton.isHidden = false
            }
            else {
                labelLeadingButtonConstraint.isActive = false
                labelLeadingViewConstraint.isActive = true
                checkboxButton.isHidden = true
            }
        }
    }

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

        titleLabel.text = "Test"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.textColor = UIColor.App.headingMain

        toggleButton.backgroundColor = UIColor.App.secondaryBackground

        checkboxButton.isHidden = true

        stackView.backgroundColor = UIColor.App.secondaryBackground
    }

    func setTitle(title: String) {
        titleLabel.text = title
    }

    func setCheckboxSelected(selected: Bool) {
        checkboxButton.isChecked = selected
    }

    func addViewtoStack(view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func animateView(hiddenFlow: Bool) {
        if hiddenFlow {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn ,animations: {
                self.stackView.layoutIfNeeded()
                self.layoutIfNeeded()
            }, completion: { _ in

            })
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut ,animations: {
                self.stackView.layoutIfNeeded()
                self.layoutIfNeeded()
            }, completion: { _ in

            })
        }

    }

    @IBAction private func toggleCollapseAction() {
        isCollapsed = !isCollapsed
    }

}
