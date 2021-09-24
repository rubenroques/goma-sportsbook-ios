//
//  PopupView.swift
//  ShowcaseProd
//
//  Created by André Lascas on 21/09/2021.
//

import UIKit

class PopupView: NibView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var roundTitleView: UIView!
    @IBOutlet private var titleImageViewLabel: UILabel!
    @IBOutlet private var subtitleImageViewLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var visitButton: RoundButton!
    @IBOutlet private var dismissButton: UIButton!
    // Variables
    var viewHeight: CGFloat = 0
    var backgroundView: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
        viewHeight = imageView.frame.height + titleLabel.frame.height + textLabel.frame.height + visitButton.frame.height + dismissButton.frame.height
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
        viewHeight = imageView.frame.height + titleLabel.frame.height + textLabel.frame.height + visitButton.frame.height + dismissButton.frame.height
    }

    override func commonInit() {
        self.layer.cornerRadius = BorderRadius.modal

        imageView.image = UIImage(named: "promo_image")
        imageView.contentMode = .scaleAspectFill

        roundTitleView.layer.cornerRadius = BorderRadius.label
        roundTitleView.sizeToFit()

        titleImageViewLabel.text = "Lorem ipsum"
        titleImageViewLabel.font = AppFont.with(type: .bold, size: 19)
        titleImageViewLabel.sizeToFit()

        subtitleImageViewLabel.text = "Lorem ipsum dolor"
        subtitleImageViewLabel.font = AppFont.with(type: .bold, size: 11)

        titleLabel.text = "Lorem ipsum"
        titleLabel.font = AppFont.with(type: .bold, size: 20)

        textLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
        textLabel.font = AppFont.with(type: .regular, size: 14)
        textLabel.sizeToFit()

        visitButton.setTitle(localized("string_see_promo"), for: .normal)
        visitButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        dismissButton.setTitle(localized("string_not_now"), for: .normal)
        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundDarkModal

        roundTitleView.backgroundColor = UIColor.App.buttonMain

        titleImageViewLabel.textColor = UIColor.App.headingMain
        titleImageViewLabel.backgroundColor = UIColor.App.buttonMain

        subtitleImageViewLabel.textColor = UIColor.App.headingMain

        titleLabel.textColor = UIColor.App.headingMain

        textLabel.textColor = UIColor.App.headingMain

        visitButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        visitButton.backgroundColor = UIColor.App.primaryButtonNormalColor
        visitButton.cornerRadius = BorderRadius.button

        dismissButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        dismissButton.backgroundColor = UIColor.App.backgroundDarkModal
    }

    func setPromoItems(image: UIImage, imageTitle: String, imageSubtitle: String, title: String, text: String) {
        imageView.image = image
        titleImageViewLabel.text = imageTitle
        subtitleImageViewLabel.text = imageSubtitle
        titleLabel.text = title
        textLabel.text = text
    }

    func setBannerImage(_ image: UIImage) {
        imageView.image = image
    }

    func setBannerTitle(_ title: String) {
        titleImageViewLabel.text = title
    }

    func setBannerSubtitle(_ subtitle: String) {
        subtitleImageViewLabel.text = subtitle
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setText(_ text: String) {
        textLabel.text = text
    }

    @IBAction private func visitAction() {
        // TO-DO: Call VC for promotion
    }

    @IBAction private func dismissAction() {
        PopupView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 0
                self.backgroundView.alpha = 0
            }, completion: {_ in
                self.removeFromSuperview()
            })
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: viewHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.roundCorners(corners: [.topLeft, .topRight], radius: 11)
    }

}

extension UIImageView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
