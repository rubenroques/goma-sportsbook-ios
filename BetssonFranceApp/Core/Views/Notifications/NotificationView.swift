//
//  NotificationView.swift
//  MultiBet
//
//  Created by André Lascas on 22/11/2024.
//

import UIKit

class NotificationView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var innerContainerView: UIView = Self.createInnerContainerView()
    private lazy var stateView: UIView = Self.createStateView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    
    var isRead: Bool = false {
        didSet {
            self.stateView.isHidden = isRead
            
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
        }
    }
    
    var hasSeparatorLine: Bool = false {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }

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
        self.isRead = false
        
        self.hasSeparatorLine = false
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.innerContainerView.backgroundColor = UIColor.App.backgroundSecondary

        self.stateView.backgroundColor = UIColor.App.highlightPrimary
        
        self.iconBaseView.backgroundColor = .clear
        self.iconBaseView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.iconImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }
    
    func configure(viewModel: UserNotificationCellViewModel) {
        self.titleLabel.text = viewModel.getNotificationText()
        
        let isRead = viewModel.getNotificationReadState() == 0 ? false : true
        self.isRead = isRead
        
    }
    
}

//
// MARK: Subviews initialization and setup
//
extension NotificationView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createInnerContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.label
        view.clipsToBounds = true
        return view
    }

    private static func createStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.2
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
    
    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.innerContainerView)

        self.innerContainerView.addSubview(self.stateView)
        self.innerContainerView.addSubview(self.iconBaseView)
        
        self.iconBaseView.addSubview(self.iconImageView)
        
        self.innerContainerView.addSubview(self.titleLabel)
        
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
            
            self.innerContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 7),
            self.innerContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -7),
            self.innerContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.innerContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),

            self.stateView.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor),
            self.stateView.topAnchor.constraint(equalTo: self.innerContainerView.topAnchor),
            self.stateView.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor),
            self.stateView.widthAnchor.constraint(equalToConstant: 4),
            
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.stateView.trailingAnchor, constant: 5),
            self.iconBaseView.topAnchor.constraint(equalTo: self.innerContainerView.topAnchor, constant: 10),
            self.iconBaseView.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor, constant: -10),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 24),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 7),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -12),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),
            
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

}
