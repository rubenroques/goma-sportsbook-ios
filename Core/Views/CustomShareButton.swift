//
//  CustomShareButton.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/07/2025.
//

import UIKit

class CustomShareButton: UIView {
    
    // MARK: - Properties
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("pari_bonus")
        label.textColor = UIColor.App.highlightPrimary
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }()
    
    private lazy var shareIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let iconImage = UIImage(named: "icon_share_v3") {
            imageView.image = iconImage.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.App.highlightPrimary
        }
        return imageView
    }()
    
    // MARK: - Callback
    
    var onTap: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Configure main view
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        // Add subviews
        addSubview(containerView)
        containerView.addSubview(label)
        containerView.addSubview(shareIcon)
        
        // Setup styling
        setupStyling()
        
        // Setup constraints
        setupConstraints()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapShareButton))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func setupStyling() {
        // Styling to match Figma design from MyTicketCardView
        containerView.backgroundColor = UIColor.App.backgroundSecondary
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        containerView.layer.cornerRadius = CornerRadius.checkBox
        
        // Inner glow effect
        containerView.layer.shadowColor = UIColor.App.highlightPrimary.cgColor
        containerView.layer.shadowOpacity = 0.8
        containerView.layer.shadowRadius = 2.5
        containerView.layer.shadowOffset = .zero
        containerView.layer.masksToBounds = false
        
        containerView.clipsToBounds = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the custom share button view
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Label positioning (left side)
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Share icon positioning (right side)
            shareIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            shareIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 16),
            shareIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Ensure proper spacing between label and icon
            label.trailingAnchor.constraint(lessThanOrEqualTo: shareIcon.leadingAnchor, constant: -4),
            
            // Minimum height for the container
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapShareButton() {
        onTap?()
    }
}
