//
//  InfoActionDialogView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/05/2025.
//

import UIKit

class InfoActionDialogView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var linkLabel: UILabel = Self.createLinkLabel()
    
    var actionLink: String?
    var shouldOpenActionLink: ((String) -> Void)?
    var shouldCloseDialog: (() -> Void)?

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.headerInput

        // Create the triangle shape layer
        let triangleLayer = CAShapeLayer()
        triangleLayer.fillColor = UIColor.App.backgroundBorder.cgColor

        // Create the path for the triangle shape
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: 0 + 80, y: self.containerView.bounds.height))
        trianglePath.addLine(to: CGPoint(x: 0 + 76, y: self.containerView.bounds.height + 10))
        trianglePath.addLine(to: CGPoint(x: 0 + 70, y: self.containerView.bounds.height))
        trianglePath.close()

        // Set the path to the triangle layer
        triangleLayer.path = trianglePath.cgPath

        // Add the triangle layer to the view's layer
        self.containerView.layer.addSublayer(triangleLayer)

        self.containerView.layer.shadowColor = UIColor(red: 3.0 / 255.0, green: 6.0 / 255.0, blue: 27.0 / 255.0, alpha: 1).cgColor

        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowOffset = .zero
        self.containerView.layer.shadowRadius = 10
        self.containerView.layer.shouldRasterize = true
        self.containerView.layer.rasterizationScale = UIScreen.main.scale

    }

    func commonInit() {
        
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapActionLink))
        self.linkLabel.isUserInteractionEnabled = true
        self.linkLabel.addGestureRecognizer(tapGesture)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundBorder
        
        self.closeButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary
        
        self.linkLabel.textColor = UIColor.App.highlightPrimary

    }

    func configure(title: String, description: String, linkText: String, actionLink: String) {
        self.titleLabel.text = title
        
        self.descriptionLabel.text = description
        
        self.linkLabel.text = linkText
        
        self.actionLink = actionLink
        
        let attributedString = NSMutableAttributedString(string: linkText)
        
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.App.highlightPrimary,
                                      range: NSRange(location: 0, length: linkText.count))
        
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: linkText.count))
        
        self.linkLabel.attributedText = attributedString
    }
    
    @objc private func didTapCloseButton() {
        
        self.shouldCloseDialog?()
    }
    
    @objc private func didTapActionLink() {
        if let actionLink {
            self.shouldOpenActionLink?(actionLink)
        }
    }
    
}

extension InfoActionDialogView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "small_close_cross_icon"), for: .normal)
        if let buttonImage = UIImage(named: "small_close_cross_icon") {
            let templateImage = buttonImage.withRenderingMode(.alwaysTemplate)
            button.setImage(templateImage, for: .normal)
            
            button.tintColor = UIColor.App.iconSecondary
        }
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
        label.font = AppFont.with(type: .regular, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    private static func createLinkLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.closeButton)

        self.containerView.addSubview(self.titleLabel)
        
        self.containerView.addSubview(self.descriptionLabel)

        self.containerView.addSubview(self.linkLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -7),
            self.closeButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 7),
            self.closeButton.widthAnchor.constraint(equalToConstant: 17),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.heightAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.titleLabel.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 5),
            
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5),
            
            self.linkLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.linkLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.linkLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10),
            self.linkLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15)

        ])

    }

}
