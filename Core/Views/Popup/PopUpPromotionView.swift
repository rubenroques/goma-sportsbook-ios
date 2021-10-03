//
//  PopUpPromotionView.swift
//  ShowcaseProd
//
//  Created by André Lascas on 21/09/2021.
//

import UIKit
import Kingfisher

class PopUpPromotionView: NibView {

    @IBOutlet private var baseView: UIView!

    @IBOutlet private var stackView: UIStackView!

    @IBOutlet private var imageBaseView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var gradientView: UIView!

    @IBOutlet private var topTitleBaseView: UIView!
    @IBOutlet private var topTitleLabel: UILabel!
    @IBOutlet private var topSubtitleLabel: UILabel!

    @IBOutlet private var titleBaseView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabelBaseView: UIView!
    @IBOutlet private var subtitleLabel: UILabel!

    @IBOutlet private var spacerView: UIView!

    @IBOutlet private var visitButtonBaseView: UIView!
    @IBOutlet private var visitButton: UIButton!
    @IBOutlet private var dismissButtonBaseView: UIView!
    @IBOutlet private var dismissButton: UIButton!

    @IBOutlet private var topCornerDismissView: UIView!

    // Variables
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.topCornerDismissView.layer.cornerRadius = self.topCornerDismissView.frame.size.width / 2
    }

    override func commonInit() {
        self.layer.cornerRadius = CornerRadius.modal

        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true


        gradientView.backgroundColor = .black
        let leftGradientMaskLayer = CAGradientLayer()
        leftGradientMaskLayer.frame = gradientView.bounds
        leftGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        leftGradientMaskLayer.locations = [0, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        leftGradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientView.layer.mask = leftGradientMaskLayer


        if let imageURLString = details.coverImage, let imageURL = URL(string: imageURLString) {
            imageView.kf.setImage(with: imageURL)
        }
        else {
            imageBaseView.isHidden = true
        }

        // -- Top Title
        if let topTitle = details.title {
            topTitleBaseView.layer.cornerRadius = CornerRadius.label
            topTitleLabel.text = topTitle
        }
        else {
            topTitleBaseView.isHidden = true
        }

        // -- Top SubTitle
        if let topSubtitle = details.subtitle {
            topSubtitleLabel.text = topSubtitle
        }
        else {
            topSubtitleLabel.isHidden = true
        }

        // -- Bottom Title
        if let title = details.textTile {
            titleLabel.text = title
        }
        else {
            titleBaseView.isHidden = true
        }

        // -- Bottom Subtitle
        if let subtitleText = details.text {
            subtitleLabel.text = subtitleText
            subtitleLabel.setLineSpacing(lineSpacing: 6, lineHeightMultiple: 1)
            subtitleLabel.textAlignment = .center
        }
        else {
            subtitleLabelBaseView.isHidden = true
        }

        // -- Buttons
        if let visitLinkText = details.promoButtonText {
            visitButton.layer.cornerRadius = CornerRadius.button
            visitButton.setTitle(visitLinkText, for: .normal)
            visitButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        }
        else {
            visitButtonBaseView.isHidden = true
        }

        if let closeText = details.closeButtonText {
            dismissButton.setTitle(closeText, for: .normal)
            dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 14)
        }
        else {
            dismissButtonBaseView.isHidden = true
        }

        if details.type == 1 {
            self.dismissButtonBaseView.isHidden = false
            self.topCornerDismissView.isHidden = true
        }
        else if details.type == 2 {
            self.dismissButtonBaseView.isHidden = true
            self.topCornerDismissView.isHidden = false
        }

        self.clipsToBounds = true
        self.baseView.layer.cornerRadius = 12
        self.baseView.clipsToBounds = true

        let closeCornerTap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseAction))
        self.topCornerDismissView.addGestureRecognizer(closeCornerTap)

        if dismissButtonBaseView.isHidden &&
            visitButtonBaseView.isHidden &&
            topCornerDismissView.isHidden {
            let closeBackgroundTap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseAction))
            self.baseView.addGestureRecognizer(closeBackgroundTap)
        }
    }


    func setupWithTheme() {

        self.backgroundColor = UIColor.clear

        imageBaseView.backgroundColor = UIColor.clear
        baseView.backgroundColor = UIColor.App.secondaryBackground

        spacerView.backgroundColor = .clear
        stackView.backgroundColor = .clear
        topTitleBaseView.backgroundColor = .clear
        titleBaseView.backgroundColor = .clear
        subtitleLabelBaseView.backgroundColor = .clear
        visitButtonBaseView.backgroundColor = .clear
        dismissButtonBaseView.backgroundColor = .clear

        topTitleLabel.textColor = UIColor.App.headingMain
        topTitleBaseView.backgroundColor = UIColor.App.mainTint

        topSubtitleLabel.textColor = UIColor.App.headingMain

        titleLabel.textColor = UIColor.App.headingMain
        subtitleLabel.textColor = UIColor.App.headingMain

        visitButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        visitButton.backgroundColor = UIColor.App.primaryButtonNormal

        dismissButton.setTitleColor(UIColor.App.headingMain, for: .normal)

        dismissButton.backgroundColor = UIColor.App.secondaryBackground
        topCornerDismissView.backgroundColor = UIColor.App.secondaryBackground
    }

    @IBAction private func visitAction() {
        self.didTapPromotionButton?(details.linkURL)
    }

    @IBAction private func dismissAction() {
        self.didTapCloseButton?()
    }

    @objc func didTapCloseAction() {
        self.didTapCloseButton?()
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
