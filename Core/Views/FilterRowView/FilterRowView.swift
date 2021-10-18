//
//  FilterRowView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit

class FilterRowView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkboxButton: CheckboxButton!
    @IBOutlet private var radioButton: RadioButton!
    @IBOutlet private var lineView: UIView!

    enum ButtonType {
        case checkbox
        case radio
    }

    var buttonType = ButtonType.checkbox {
        didSet {
            switch buttonType {
            case .checkbox:
                checkboxButton.isHidden = false
                radioButton.isHidden = true
            case .radio:
                checkboxButton.isHidden = true
                radioButton.isHidden = false
            }
        }
    }

    var hasBorderBottom = true {
        didSet {
            if hasBorderBottom {
                lineView.isHidden = false
            }
            else {
                lineView.isHidden = true
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

        self.backgroundColor = UIColor.App.secondaryBackground
        
        containerView.backgroundColor = UIColor.App.secondaryBackground

        titleLabel.text = "Title Label"
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.textColor = UIColor.App.headingMain

        radioButton.contentMode = .scaleAspectFit
        checkboxButton.contentMode = .scaleAspectFit

        lineView.backgroundColor = UIColor.App.fadedGrayLine

        checkboxButton.isHidden = false
        radioButton.isHidden = true

    }

    func setTitle(title: String) {
        titleLabel.text = title
    }

    func setCheckboxSelected(selected: Bool) {
        checkboxButton.isChecked = selected
    }

    func getRadioButton() -> RadioButton {
        return self.radioButton
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 40)
    }

}
