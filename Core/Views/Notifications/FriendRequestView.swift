//
//  FriendRequestView.swift
//  MultiBet
//
//  Created by André Lascas on 25/11/2024.
//

import UIKit

class FriendRequestView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var actionButton: UIButton = Self.createActionButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    var hasSeparatorLine: Bool = false {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }
    
    var tappedActionButton: ((Int) -> Void)?
    var tappedCloseButton: ((Int) -> Void)?
    
    var viewModel: UserNotificationInviteCellViewModel?
    
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
        
        self.iconBaseView.layoutIfNeeded()
        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.width / 2
        self.iconBaseView.clipsToBounds = true
        
        self.iconImageView.layoutIfNeeded()
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.width / 2
        self.iconImageView.clipsToBounds = true
    }

    func commonInit() {
        
        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)
        
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.hasSeparatorLine = false
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.iconBaseView.backgroundColor = .clear
        self.iconBaseView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.iconImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButtonWithTheme(button: self.actionButton, titleColor: UIColor.App.buttonTextPrimary, titleDisabledColor: UIColor.App.buttonTextDisablePrimary, backgroundColor: UIColor.App.buttonBackgroundPrimary, backgroundHighlightedColor: UIColor.App.buttonBackgroundPrimary)
        
        self.closeButton.backgroundColor = .clear
        
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }
    
    func configure(viewModel: UserNotificationInviteCellViewModel) {
        
        self.viewModel = viewModel
        
        self.titleLabel.text = viewModel.getFriendRequestUsername()
        
    }
    
    // MARK: Actions
    @objc private func didTapActionButton() {
        print("ACTION!")
        if let userId = viewModel?.getFriendRequestId() {
            self.tappedActionButton?(userId)
        }
    }
    
    @objc private func didTapCloseButton() {
        print("CLOSE!")
        
        if let userId = viewModel?.getFriendRequestId() {
            self.tappedCloseButton?(userId)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension FriendRequestView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar4")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("accept"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
        return button
    }
    
    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close_dark_icon"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.iconBaseView)
        
        self.iconBaseView.addSubview(self.iconImageView)
        
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.actionButton)
        self.containerView.addSubview(self.closeButton)
        
        self.containerView.addSubview(self.separatorLineView)

        self.initConstraints()
        
        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 17),
            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
            self.iconBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 7),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),
            
            self.actionButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 10),
            self.actionButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.actionButton.heightAnchor.constraint(equalToConstant: 30),
            
            self.closeButton.leadingAnchor.constraint(equalTo: self.actionButton.trailingAnchor, constant: 0),
            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.closeButton.centerYAnchor.constraint(equalTo: self.actionButton.centerYAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),
            
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 17),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -17),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

}
