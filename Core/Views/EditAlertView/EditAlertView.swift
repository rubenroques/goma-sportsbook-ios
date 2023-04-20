//
//  EditAlertView.swift
//  Sportsbook
//
//  Created by André Lascas on 17/09/2021.
//

import UIKit

class EditAlertView: NibView {

    struct AlertInfo {
        var alertType: AlertState
        var message: String
    }

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var alertImageView: UIImageView!
    @IBOutlet private var alertLabel: UILabel!
    @IBOutlet private var alertTextLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!

    // Variables
    var onClose: (() -> Void)?

    enum AlertState {
        case success
        case error
        case info
    }

    var alertState: AlertState = .success {
        didSet {
            switch self.alertState {
            case .success:
                alertImageView.image = UIImage(named: "success_circle_icon")
                alertLabel.text = localized("success")
                alertLabel.textColor = UIColor.App.alertSuccess
                alertTextLabel.text = localized("success_edit")
            case .error:
                alertImageView.image = UIImage(named: "error_input_icon")
                alertLabel.textColor = UIColor.App.alertError
                alertLabel.text = localized("error")
                alertTextLabel.text = localized("error_edit")
            case .info:
                alertImageView.image = UIImage(named: "info_blue_icon")
                alertLabel.textColor = UIColor.App.textPrimary
                alertLabel.text = localized("info")
                alertTextLabel.text = localized("info_text")
            }
        }
    }

    var hasBorder: Bool = false {
        didSet {
            if hasBorder {
                containerView.layer.cornerRadius = CornerRadius.button
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.App.textPrimary.cgColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }

    override func commonInit() {

        alertImageView.image = UIImage(named: "success_circle_icon")

        alertLabel.text = ""

        alertTextLabel.text = ""
        alertTextLabel.numberOfLines = 0

        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(named: "small_close_cross_light_icon"), for: .normal)

    }

    func setupWithTheme() {
        self.alpha = 0

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        alertImageView.backgroundColor = UIColor.App.backgroundPrimary
        alertLabel.textColor = UIColor.App.inputTextTitle
        alertTextLabel.textColor = UIColor.App.inputText

        closeButton.backgroundColor = UIColor.App.backgroundPrimary
        closeButton.tintColor = UIColor.App.textPrimary

    }

    func setAlertIcon(_ icon: UIImage) {
        alertImageView.image = icon
    }

    func setAlertTitle(_ title: String) {
        alertLabel.text = title
    }

    func setAlertText(_ text: String) {
        alertTextLabel.text = text
        self.invalidateIntrinsicContentSize()
    }

    @IBAction private func closeView() {
        onClose?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: self.alertTextLabel.frame.height + 30)
    }

}
