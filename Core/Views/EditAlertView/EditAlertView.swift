//
//  EditAlertView.swift
//  Sportsbook
//
//  Created by André Lascas on 17/09/2021.
//

import UIKit

class EditAlertView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var alertImageView: UIImageView!
    @IBOutlet private var alertLabel: UILabel!
    @IBOutlet private var alertTextLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    // Variables
    var onClose:(() -> Void)?

    enum AlertState {
        case success
        case error
    }

    var alertState: AlertState = .success {
        didSet {
            switch self.alertState {
            case .success:
                alertImageView.image = UIImage(named: "Active")
                alertLabel.text = localized("string_success")
                alertLabel.textColor = UIColor.App.success
                alertTextLabel.text = localized("string_success_edit")
            case .error:
                alertImageView.image = UIImage(named: "Error")
                alertLabel.textColor = UIColor.App.error
                alertLabel.text = localized("string_error")
                alertTextLabel.text = localized("string_error_edit")
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

        alertImageView.image = UIImage(named: "Success")

        alertLabel.text = "Alert"

        alertTextLabel.text = "Lorem ipsum dolor."
        alertTextLabel.numberOfLines = 0

        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(named: "x-circle"), for: .normal)

    }

    func setupWithTheme() {
        self.alpha = 0

        containerView.backgroundColor = UIColor.App.backgroundDarkProfile

        alertImageView.backgroundColor = UIColor.App.backgroundDarkProfile

        alertLabel.textColor = UIColor.App.headingMain

        alertTextLabel.textColor = UIColor.App.headingMain

        closeButton.backgroundColor = UIColor.App.backgroundDarkProfile
        closeButton.tintColor = UIColor.App.headerTextFieldGray

    }

    func setAlertIcon(_ icon: UIImage) {
        alertImageView.image = icon
    }

    func setAlertTitle(_ title: String) {
        alertLabel.text = title
    }

    func setAlertText(_ text: String) {
        alertTextLabel.text = text
    }

    @IBAction private func closeView() {
        onClose?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 100)
    }

}
