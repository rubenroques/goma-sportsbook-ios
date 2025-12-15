//
//  LogoActionDescriptionView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class LogoActionDescriptionView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    
    // Constraints
    private lazy var logoImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createLogoImageViewFixedHeightConstraint()
    private lazy var logoImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createLogoImageViewDynamicHeightConstraint()
    
    private var aspectRatio: CGFloat = 1.0
    
    private let viewModel: LogoActionDescriptionViewModelProtocol
    
    // MARK: - Public Properties
    var didTapLogo: ((String) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: LogoActionDescriptionViewModelProtocol) {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLogoImageView))
        self.logoImageView.isUserInteractionEnabled = true
        self.logoImageView.addGestureRecognizer(tapGesture)
        
        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.backgroundColor = .clear
        
        self.logoImageView.backgroundColor = .clear
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: - Functions
    private func bind(toViewModel viewModel: LogoActionDescriptionViewModelProtocol) {
        self.logoImageView.image = UIImage(named: viewModel.logoImageName)
        
        self.descriptionLabel.text = viewModel.descriptionText
        self.descriptionLabel.font = AppFont.with(type: .regular, size: 16)
        self.descriptionLabel.textColor = UIColor.App.textPrimary
        
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
    
    // MARK: - Actions
    @objc private func didTapLogoImageView() {
        guard let url = self.viewModel.actionUrl else { return }
        self.didTapLogo?(url)
    }
}

//
// MARK: - Subviews initialization and setup
//
extension LogoActionDescriptionView {

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

            // Logo image view on the left
            self.logoImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.logoImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 150),
            
            // Description label to the right of logo, vertically centered
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 15),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10)
        ])
        
        // Set up initial fixed height constraint
        self.logoImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.logoImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 80)
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
