//
//  PopUpPromotionView.swift
//  ShowcaseProd
//
//  Created by André Lascas on 21/09/2021.
//

import UIKit
import Kingfisher

class PopUpPromotionView: NibView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var roundTitleView: UIView!
    @IBOutlet private var titleImageViewLabel: UILabel!
    @IBOutlet private var subtitleImageViewLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var visitButton: RoundButton!
    @IBOutlet private var dismissButton: UIButton!

    // Variables
    var backgroundView: UIView = UIView()

    var details: PopUpDetails

    var didTapPromotionButton: ((String?) -> Void)?
    var didTapCloseButton: (() -> Void)?

    convenience init(_ details: PopUpDetails) {
        self.init(frame: .zero, details: details)
    }

    init(frame: CGRect, details: PopUpDetails) {
        self.details = details
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func commonInit() {
        self.layer.cornerRadius = BorderRadius.modal

        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let imageURL = URL(string: details.coverImage) {
            imageView.kf.setImage(with: imageURL)
        }

        roundTitleView.layer.cornerRadius = BorderRadius.label
        roundTitleView.sizeToFit()

        titleImageViewLabel.text = details.title
        titleImageViewLabel.font = AppFont.with(type: .bold, size: 19)
        titleImageViewLabel.sizeToFit()

        subtitleImageViewLabel.text = details.subtitle
        subtitleImageViewLabel.font = AppFont.with(type: .semibold, size: 11)

        titleLabel.text = details.textTile
        titleLabel.font = AppFont.with(type: .bold, size: 20)

        textLabel.text = details.text
        textLabel.font = AppFont.with(type: .semibold, size: 14)
        textLabel.setLineSpacing(lineSpacing: 6, lineHeightMultiple: 1)
        textLabel.textAlignment = .center

        visitButton.setTitle(details.promoButtonText, for: .normal)
        visitButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        dismissButton.setTitle(details.closeButtonText, for: .normal)
        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 14)
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
        self.didTapPromotionButton?(details.linkURL)
    }

    @IBAction private func dismissAction() {
        self.didTapCloseButton?()
    }

    override var intrinsicContentSize: CGSize {
        let viewHeight = imageView.frame.height + titleLabel.frame.height + textLabel.frame.height + visitButton.frame.height + dismissButton.frame.height
        return CGSize(width: self.frame.width, height: viewHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.roundCorners(corners: [.topLeft, .topRight], radius: 11)
    }

}

// Todo: colocas as extensions no ficheiros proprios
extension UIImageView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
