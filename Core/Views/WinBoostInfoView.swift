//
//  WinBoostInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/05/2025.
//

import UIKit

class WinBoostInfoView: UIView {

    private lazy var containerGradientView: GradientView = Self.createContainerGradientView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    
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

        self.containerGradientView.layer.cornerRadius = CornerRadius.button
        self.containerGradientView.clipsToBounds = true
        
        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.containerGradientView.endPoint = CGPoint(x: 1.0, y: 0.0)

        self.containerView.layer.cornerRadius = CornerRadius.button
        self.containerView.clipsToBounds = true
    }
    
    func commonInit() {
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.containerGradientView.colors = [(UIColor.App.cardBorderLineGradient1, NSNumber(0.0)),
                                             (UIColor.App.cardBorderLineGradient2, NSNumber(0.5)),
                                             (UIColor.App.cardBorderLineGradient3, NSNumber(1.0))]

        self.containerView.backgroundColor = UIColor.App.backgroundBorder
        
        self.iconImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.subtitleLabel.textColor = UIColor.App.highlightPrimary
        
        self.valueLabel.textColor = UIColor.App.textPrimary

    }
    
    func configure(title: String, subtitle: String, value: String) {
        self.titleLabel.text = title
        
        self.subtitleLabel.text = subtitle
        
        self.valueLabel.text = value
    }
}

extension WinBoostInfoView {
    
    private static func createContainerGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "rocket_wheel_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        return label
    }
    
    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0€"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .right
        return label
    }
    
    private func setupSubviews() {
        
        self.addSubview(self.containerGradientView)
        
        self.containerGradientView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)
        
        self.containerView.addSubview(self.subtitleLabel)

        self.containerView.addSubview(self.valueLabel)

        self.initConstraints()
    }
    
    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerGradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerGradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerGradientView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerGradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 1),
            self.containerView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -1),
            self.containerView.topAnchor.constraint(equalTo: self.containerGradientView.topAnchor, constant: 1),
            self.containerView.bottomAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor, constant: -1),
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 4),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 4),
            self.subtitleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            
            self.valueLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.iconImageView.trailingAnchor, constant: 4),
            self.valueLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor)

        ])

    }
}
