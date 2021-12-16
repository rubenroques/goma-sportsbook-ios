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

                buttonImageView.backgroundColor = UIColor.App.secondaryBackground

                buttonImageView.layer.borderWidth = 2
                buttonImageView.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
                buttonImageView.layer.cornerRadius = 4

                buttonImageView.tintColor = UIColor.App.headingMain

                buttonImageView.image = nil

            case .radio:

                buttonImageView.layer.cornerRadius = buttonImageView.frame.width/2
                buttonImageView.layer.borderWidth = 2.0

                buttonImageView.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
                buttonImageView.backgroundColor = UIColor.App.secondaryBackground
                
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
                buttonImageView.backgroundColor = UIColor.App.mainTint
                    buttonImageView.layer.borderColor = UIColor.App.mainTint.cgColor

                }
                else if buttonType == ButtonType.radio {
                    buttonImageView.layer.borderColor = UIColor.App.mainTint.cgColor
                    buttonImageView.backgroundColor = UIColor.App.mainTint
                    buttonImageView.image = (UIImage(named: "white_dot_icon"))
                }
            }
            else {
                if buttonType == ButtonType.checkbox {
                buttonImageView.image = nil
                buttonImageView.backgroundColor = UIColor.App.secondaryBackground
                buttonImageView.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
                }
                else if buttonType == ButtonType.radio {
                    buttonImageView.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
                    buttonImageView.backgroundColor = UIColor.App.secondaryBackground
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

        buttonImageView.contentMode = .scaleAspectFit

        lineView.backgroundColor = UIColor.App.fadedGrayLine

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
