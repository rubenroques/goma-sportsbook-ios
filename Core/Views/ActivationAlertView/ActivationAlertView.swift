//
//  ActivationAlertView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/11/2021.
//

import UIKit

class ActivationAlertView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var linkLabel: UILabel!
    // Variables
    var onClose:(() -> Void)?

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
        titleLabel.text = "Lorem Ipsum"

        closeButton.setImage(UIImage(named: "small_close_cross_icon"), for: .normal)

        infoLabel.text = "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum"
        infoLabel.numberOfLines = 0

        linkLabel.text = "Click here"
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.linkLabel.isUserInteractionEnabled = true
        self.linkLabel.addGestureRecognizer(labelTap)
    }

    func setupWithTheme() {

        containerView.backgroundColor = UIColor.App.secondaryBackground

        titleLabel.textColor = UIColor.App.headingMain
        titleLabel.font = AppFont.with(type: .bold, size: 16)

        closeButton.backgroundColor = UIColor.App.secondaryBackground

        infoLabel.textColor = UIColor.App.headingMain
        infoLabel.font = AppFont.with(type: .semibold, size: 14)

        linkLabel.textColor = UIColor.App.mainTint
        linkLabel.font = AppFont.with(type: .semibold, size: 14)
    }

    func setText(title: String, info: String, linkText: String) {
        self.titleLabel.text = title
        self.infoLabel.text = info
        self.linkLabel.text = linkText
    }

    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        print("Tapped")
    }

    @IBAction func closeButtonAction() {
        self.onClose?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 100)
    }

}
