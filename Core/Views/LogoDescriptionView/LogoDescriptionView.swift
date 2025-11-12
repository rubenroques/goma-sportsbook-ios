//
//  LogoDescriptionView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class LogoDescriptionView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    
    // Constraints
    private lazy var logoImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createLogoImageViewFixedHeightConstraint()
    private lazy var logoImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createLogoImageViewDynamicHeightConstraint()
    
    private var aspectRatio: CGFloat = 1.0
    
    private let viewModel: LogoDescriptionViewModelProtocol

    // MARK: - Lifetime and Cycle
    init(viewModel: LogoDescriptionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.resizeLogoImageView()
    }
    
    private func commonInit() {
        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.backgroundColor = .clear
        
        self.logoImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: - Functions
    private func bind(toViewModel viewModel: LogoDescriptionViewModelProtocol) {
        self.logoImageView.image = UIImage(named: viewModel.logoImageName)
        
        self.titleLabel.text = viewModel.titleText
        self.titleLabel.font = viewModel.titleFont ?? AppFont.with(type: .bold, size: 16)
        self.titleLabel.textColor = viewModel.titleColor ?? UIColor.App.textPrimary
        
        self.descriptionLabel.text = viewModel.descriptionText
        self.descriptionLabel.font = viewModel.descriptionFont ?? AppFont.with(type: .regular, size: 14)
        self.descriptionLabel.textColor = viewModel.descriptionColor ?? UIColor.App.textSecondary
        
        self.setNeedsLayout()
    }
    
    private func resizeLogoImageView() {
        guard let image = self.logoImageView.image else { return }
        
        let aspectRatio = image.size.width / image.size.height
        
        self.logoImageViewFixedHeightConstraint.isActive = false
        
        self.logoImageViewDynamicHeightConstraint = NSLayoutConstraint(
            item: self.logoImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: self.logoImageView,
            attribute: .width,
            multiplier: 1 / aspectRatio,
            constant: 0
        )
        
        self.logoImageViewDynamicHeightConstraint.isActive = true
    }
}

//
// MARK: - Subviews initialization and setup
//
extension LogoDescriptionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .regular, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .regular, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    // Constraints
    private static func createLogoImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLogoImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.logoImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container view fills the parent
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // Logo image view at the top, centered horizontally
            self.logoImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.logoImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 150),
            
            // Title label below logo
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 15),
            
            // Description label below title
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])
        
        // Set up initial fixed height constraint
        self.logoImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.logoImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 100)
        self.logoImageViewFixedHeightConstraint.isActive = true

        self.logoImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.logoImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.logoImageView,
                           attribute: .width,
                           multiplier: 1 / self.aspectRatio,
                           constant: 0)
        self.logoImageViewDynamicHeightConstraint.isActive = false
    }
}
