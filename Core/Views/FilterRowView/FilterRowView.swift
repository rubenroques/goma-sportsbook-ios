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
    @IBOutlet private var buttonImageView: UIImageView!
    @IBOutlet private var lineView: UIView!

    enum ButtonType {
        case checkbox
        case radio
    }

    var buttonType = ButtonType.checkbox {
        didSet {
            switch buttonType {
            case .checkbox:

                buttonImageView.backgroundColor = UIColor.App.backgroundSecondary

                buttonImageView.layer.borderWidth = 2
                buttonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                buttonImageView.layer.cornerRadius = 4

                buttonImageView.tintColor = UIColor.App.buttonTextPrimary

                buttonImageView.image = nil

            case .radio:

                buttonImageView.layer.cornerRadius = buttonImageView.frame.width/2
                buttonImageView.layer.borderWidth = 2.0

                buttonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                buttonImageView.backgroundColor = UIColor.App.backgroundSecondary
                
                buttonImageView.image = nil
                buttonImageView.contentMode = .center
            }
        }
    }

    var isChecked: Bool = false {
        didSet {
            if isChecked {
                if buttonType == ButtonType.checkbox {
                    buttonImageView.image = UIImage(named: "active_toggle_icon")
                    buttonImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                    buttonImageView.backgroundColor = UIColor.App.highlightPrimary
                    buttonImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                }
                else if buttonType == ButtonType.radio {
                    buttonImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                    buttonImageView.backgroundColor = UIColor.App.highlightPrimary
                    buttonImageView.image = (UIImage(named: "white_dot_icon"))
                    buttonImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
                }
            }
            else {
                if buttonType == ButtonType.checkbox {
                buttonImageView.image = nil
                buttonImageView.backgroundColor = UIColor.App.backgroundSecondary
                    buttonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                }
                else if buttonType == ButtonType.radio {
                    buttonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                    buttonImageView.backgroundColor = UIColor.App.backgroundSecondary
                    buttonImageView.image = nil
                }
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
    var viewId: Int = 0

    var didTapView: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundSecondary
        
        containerView.backgroundColor = UIColor.App.backgroundSecondary

        titleLabel.text = "Title Label"
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.textColor = UIColor.App.textPrimary

        buttonImageView.contentMode = .scaleAspectFit

        lineView.backgroundColor = UIColor.App.separatorLine

        buttonImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        self.buttonType = .checkbox

        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedView))
        self.addGestureRecognizer(gestureTap)

    }

    @objc func tappedView(sender: UITapGestureRecognizer) {
        if buttonType == ButtonType.checkbox {
            isChecked = !isChecked
        }
        else if buttonType == ButtonType.radio {
            if !isChecked {
                isChecked = true
            }
        }
        didTapView?(isChecked)
    }

    func setTitle(title: String) {
        titleLabel.text = title
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 40)
    }

}
