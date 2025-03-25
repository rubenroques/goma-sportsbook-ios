//
//  PopUpPromotionView.swift
//  ShowcaseProd
//
//  Created by André Lascas on 21/09/2021.
//

import UIKit
import Kingfisher

class PopUpPromotionView: UIView {

    // MARK: - Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private lazy var imageBaseView: UIView = Self.createImageBaseView()
    private lazy var imageView: UIImageView = Self.createImageView()
    private lazy var gradientView: UIView = Self.createGradientView()

    private lazy var topTitleBaseView: UIView = Self.createTopTitleBaseView()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topSubtitleLabel: UILabel = Self.createTopSubtitleLabel()

    private lazy var titleBaseView: UIView = Self.createTitleBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabelBaseView: UIView = Self.createSubtitleLabelBaseView()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var spacerView: UIView = Self.createSpacerView()

    private lazy var visitButtonBaseView: UIView = Self.createVisitButtonBaseView()
    private lazy var visitButton: UIButton = Self.createVisitButton()
    private lazy var dismissButtonBaseView: UIView = Self.createDismissButtonBaseView()
    private lazy var dismissButton: UIButton = Self.createDismissButton()

    private lazy var topCornerDismissView: UIView = Self.createTopCornerDismissView()
    private lazy var closeImageView: UIImageView = Self.createCloseImageView()

    // Variables
    var details: PopUpDetails
    private let leftGradientMaskLayer = CAGradientLayer()

    var didTapPromotionButton: ((String?) -> Void)?
    var didTapCloseButton: (() -> Void)?

    convenience init(_ details: PopUpDetails) {
        self.init(frame: .zero, details: details)
    }

    init(frame: CGRect, details: PopUpDetails) {
        self.details = details
        super.init(frame: frame)
        setupSubviews()
        setupWithTheme()
        configureWithDetails()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.topCornerDismissView.layer.cornerRadius = self.topCornerDismissView.frame.size.width / 2
        self.leftGradientMaskLayer.frame = gradientView.bounds
    }

    private func setupSubviews() {
        self.addSubview(baseView)
        self.addSubview(topCornerDismissView)

        baseView.addSubview(stackView)

        stackView.addArrangedSubview(imageBaseView)
        stackView.addArrangedSubview(titleBaseView)
        stackView.addArrangedSubview(subtitleLabelBaseView)
        stackView.addArrangedSubview(spacerView)
        stackView.addArrangedSubview(visitButtonBaseView)
        stackView.addArrangedSubview(dismissButtonBaseView)

        imageBaseView.addSubview(imageView)
        imageBaseView.addSubview(gradientView)
        imageBaseView.addSubview(topTitleBaseView)
        imageBaseView.addSubview(topSubtitleLabel)

        topTitleBaseView.addSubview(topTitleLabel)

        titleBaseView.addSubview(titleLabel)

        subtitleLabelBaseView.addSubview(subtitleLabel)

        visitButtonBaseView.addSubview(visitButton)

        dismissButtonBaseView.addSubview(dismissButton)

        topCornerDismissView.addSubview(closeImageView)

        // Setup gradient mask
        leftGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        leftGradientMaskLayer.locations = [0, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        leftGradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientView.layer.mask = leftGradientMaskLayer

        topCornerDismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCloseAction)))

        if dismissButtonBaseView.isHidden &&
            visitButtonBaseView.isHidden &&
            topCornerDismissView.isHidden {
            baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCloseAction)))
        }

        initConstraints()
    }

    private func setupWithTheme() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = CornerRadius.modal
        self.clipsToBounds = true

        imageBaseView.backgroundColor = UIColor.clear
        baseView.backgroundColor = UIColor.App.backgroundSecondary
        baseView.clipsToBounds = true

        spacerView.backgroundColor = .clear
        stackView.backgroundColor = .clear
        topTitleBaseView.backgroundColor = .clear
        titleBaseView.backgroundColor = .clear
        subtitleLabelBaseView.backgroundColor = .clear
        visitButtonBaseView.backgroundColor = .clear
        dismissButtonBaseView.backgroundColor = .clear

        topTitleLabel.textColor = UIColor.App.buttonTextPrimary
        topTitleBaseView.backgroundColor = UIColor.App.highlightPrimary

        topSubtitleLabel.textColor = UIColor.App.buttonTextPrimary

        titleLabel.textColor = UIColor.App.textPrimary
        subtitleLabel.textColor = UIColor.App.textPrimary

        visitButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        visitButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        dismissButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        dismissButton.backgroundColor = UIColor.App.backgroundSecondary
        topCornerDismissView.backgroundColor = UIColor.App.backgroundSecondary
    }

    private func configureWithDetails() {
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
        }
        else {
            visitButtonBaseView.isHidden = true
        }

        if let closeText = details.closeButtonText {
            dismissButton.setTitle(closeText, for: .normal)
        }
        else {
            dismissButtonBaseView.isHidden = true
        }

        if details.type == "bottom_dismiss" {
            self.dismissButtonBaseView.isHidden = false
            self.topCornerDismissView.isHidden = true
        }
        else if details.type == "top_dismiss" {
            self.dismissButtonBaseView.isHidden = true
            self.topCornerDismissView.isHidden = false
        }
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // baseView constraints
            baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),

            // stackView constraints
            stackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: baseView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: baseView.bottomAnchor, constant: -16),

            // imageView constraints
            imageView.leadingAnchor.constraint(equalTo: imageBaseView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: imageBaseView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageBaseView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageBaseView.bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            // gradientView constraints
            gradientView.leadingAnchor.constraint(equalTo: imageBaseView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageBaseView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageBaseView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 50),

            // topTitleBaseView constraints
            topTitleBaseView.leadingAnchor.constraint(equalTo: imageBaseView.leadingAnchor, constant: 16),
            topTitleBaseView.trailingAnchor.constraint(greaterThanOrEqualTo: imageBaseView.trailingAnchor, constant: -16),
            topTitleBaseView.bottomAnchor.constraint(equalTo: imageBaseView.bottomAnchor, constant: -16).with(priority: .defaultLow),

            // topTitleLabel constraints
            topTitleLabel.leadingAnchor.constraint(equalTo: topTitleBaseView.leadingAnchor, constant: 10),
            topTitleLabel.topAnchor.constraint(equalTo: topTitleBaseView.topAnchor, constant: 10),
            topTitleLabel.trailingAnchor.constraint(equalTo: topTitleBaseView.trailingAnchor, constant: -10),
            topTitleLabel.bottomAnchor.constraint(equalTo: topTitleBaseView.bottomAnchor, constant: -10),

            // topSubtitleLabel constraints
            topSubtitleLabel.leadingAnchor.constraint(equalTo: imageBaseView.leadingAnchor, constant: 16),
            topSubtitleLabel.topAnchor.constraint(equalTo: topTitleBaseView.bottomAnchor, constant: 8),
            topSubtitleLabel.bottomAnchor.constraint(equalTo: imageBaseView.bottomAnchor, constant: -14),

            // titleBaseView constraints
            titleBaseView.heightAnchor.constraint(equalToConstant: 60),

            // titleLabel constraints
            titleLabel.leadingAnchor.constraint(equalTo: titleBaseView.leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: titleBaseView.topAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: titleBaseView.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: titleBaseView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: titleBaseView.centerXAnchor),

            // subtitleLabel constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: subtitleLabelBaseView.leadingAnchor, constant: 8),
            subtitleLabel.topAnchor.constraint(equalTo: subtitleLabelBaseView.topAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: subtitleLabelBaseView.trailingAnchor, constant: -8),
            subtitleLabel.centerYAnchor.constraint(equalTo: subtitleLabelBaseView.centerYAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: subtitleLabelBaseView.centerXAnchor),

            // spacerView constraints
            spacerView.heightAnchor.constraint(equalToConstant: 32),

            // visitButton constraints
            visitButton.widthAnchor.constraint(equalToConstant: 270),
            visitButton.heightAnchor.constraint(equalToConstant: 50),
            visitButton.centerXAnchor.constraint(equalTo: visitButtonBaseView.centerXAnchor),
            visitButton.centerYAnchor.constraint(equalTo: visitButtonBaseView.centerYAnchor),
            visitButton.topAnchor.constraint(equalTo: visitButtonBaseView.topAnchor, constant: 8),

            // dismissButton constraints
            dismissButton.widthAnchor.constraint(equalToConstant: 270),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.centerXAnchor.constraint(equalTo: dismissButtonBaseView.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: dismissButtonBaseView.centerYAnchor),
            dismissButton.topAnchor.constraint(equalTo: dismissButtonBaseView.topAnchor, constant: 1),

            // topCornerDismissView constraints
            topCornerDismissView.widthAnchor.constraint(equalToConstant: 29),
            topCornerDismissView.heightAnchor.constraint(equalTo: topCornerDismissView.widthAnchor),
            topCornerDismissView.topAnchor.constraint(equalTo: self.topAnchor),
            topCornerDismissView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            // closeImageView constraints
            closeImageView.widthAnchor.constraint(equalToConstant: 13),
            closeImageView.heightAnchor.constraint(equalToConstant: 13),
            closeImageView.centerXAnchor.constraint(equalTo: topCornerDismissView.centerXAnchor),
            closeImageView.centerYAnchor.constraint(equalTo: topCornerDismissView.centerYAnchor)
        ])
    }

    @objc private func visitAction() {
        self.didTapPromotionButton?(details.linkURL)
    }

    @objc private func dismissAction() {
        self.didTapCloseButton?()
    }

    @objc func didTapCloseAction() {
        self.didTapCloseButton?()
    }
}

// MARK: - Factory Methods
private extension PopUpPromotionView {

    static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0
        return view
    }

    static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }

    static func createImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    static func createGradientView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }

    static func createTopTitleBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 19)
        label.numberOfLines = 2
        return label
    }

    static func createTopSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 12)
        label.numberOfLines = 3
        return label
    }

    static func createTitleBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .clear
        return view
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    static func createSubtitleLabelBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    static func createSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createVisitButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createVisitButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        button.addTarget(self, action: #selector(PopUpPromotionView.visitAction), for: .touchUpInside)
        return button
    }

    static func createDismissButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createDismissButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 14)
        button.addTarget(self, action: #selector(PopUpPromotionView.dismissAction), for: .touchUpInside)
        return button
    }

    static func createTopCornerDismissView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func createCloseImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "small_close_cross_light_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}

// MARK: - UIKit Preview Support
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("PopUpPromotion - Bottom Dismiss") {
    PreviewUIView {
        let mockDetails = PopUpDetails(
            id: "preview_promo",
            type: "bottom_dismiss",
            title: "PROMO",
            subtitle: "Limited time only",
            textTile: "Special Offer",
            text: "Get 50% off your next purchase when you sign up today!",
            promoButtonText: "Claim Now",
            closeButtonText: "No Thanks",
            coverImage: nil,
            linkURL: "https://example.com",
            intervalMinutes: 60
        )
        
        let view = PopUpPromotionView(mockDetails)
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 614)
        return view
    }
    .frame(width: 338, height: 470)
}

@available(iOS 17.0, *)
#Preview("PopUpPromotion - Top Dismiss") {
    PreviewUIView {
        let mockDetails = PopUpDetails(
            id: "preview_promo",
            type: "top_dismiss",
            title: "PROMO",
            subtitle: "Limited time only",
            textTile: "Special Offer",
            text: "Get 50% off your next purchase when you sign up today!",
            promoButtonText: "Claim Now",
            closeButtonText: "No Thanks",
            coverImage: nil,
            linkURL: "https://example.com",
            intervalMinutes: 60
        )
        
        let view = PopUpPromotionView(mockDetails)
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 614)
        return view
    }
    .preferredColorScheme(.dark)
    .frame(width: 338, height: 470)
}

@available(iOS 17.0, *)
#Preview("PopUpPromotion - With Image") {
    PreviewUIView {
        let mockDetails = PopUpDetails(
            id: "preview_promo",
            type: "bottom_dismiss",
            title: "PROMO",
            subtitle: "Limited time only",
            textTile: "Special Offer",
            text: "Get 50% off your next purchase when you sign up today!",
            promoButtonText: "Claim Now",
            closeButtonText: "No Thanks",
            coverImage: "https://picsum.photos/400/200",
            linkURL: "https://example.com",
            intervalMinutes: 60
        )
        
        let view = PopUpPromotionView(mockDetails)
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 450)
        return view
    }
    .frame(width: 338, height: 470)
}
#endif
