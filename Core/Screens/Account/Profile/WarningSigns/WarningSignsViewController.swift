//
//  WarningSignsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class WarningSignsViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var highlightTextSectionView: HighlightTextSectionView = Self.createHighlightTextSectionView()
    
    private lazy var warningSignsDescriptionLabel: UILabel = Self.createWarningSignsDescriptionLabel()
    private lazy var mottoLabel: UILabel = Self.createMottoLabel()
    
    private lazy var excessiveGamingImageView: UIImageView = Self.createExcessiveGamingImageView()
    private lazy var minorsImageView: UIImageView = Self.createMinorsImageView()
    private lazy var parentalControlImageView: UIImageView = Self.createParentalControlImageView()
    
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private lazy var excessiveGamingImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var excessiveGamingImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var minorsImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var minorsImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var parentalControlImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var parentalControlImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private var aspectRatio: CGFloat = 1.0

    // MARK: - Lifetime and Cycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.resizeImageView(
            imageView: self.bannerImageView,
            fixedHeightConstraint: &self.bannerImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.bannerImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.excessiveGamingImageView,
            fixedHeightConstraint: &self.excessiveGamingImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.excessiveGamingImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.minorsImageView,
            fixedHeightConstraint: &self.minorsImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.minorsImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.parentalControlImageView,
            fixedHeightConstraint: &self.parentalControlImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.parentalControlImageViewDynamicHeightConstraint
        )
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.bannerImageView.backgroundColor = .clear
        
        self.warningSignsDescriptionLabel.textColor = UIColor.App.textPrimary
        
        self.mottoLabel.textColor = UIColor.App.textPrimary
        
        self.excessiveGamingImageView.backgroundColor = .clear
        
        self.minorsImageView.backgroundColor = .clear
        
        self.parentalControlImageView.backgroundColor = .clear
    }
    
    // MARK: - Functions
    private func resizeImageView(
        imageView: UIImageView,
        fixedHeightConstraint: inout NSLayoutConstraint,
        dynamicHeightConstraint: inout NSLayoutConstraint
    ) {
        guard let image = imageView.image else { return }
        
        let aspectRatio = image.size.width / image.size.height
        
        fixedHeightConstraint.isActive = false
        
        dynamicHeightConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .width,
            multiplier: 1 / aspectRatio,
            constant: 0
        )
        
        dynamicHeightConstraint.isActive = true
    }

    // MARK: - Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

//
// MARK: - Subviews initialization and setup
//
extension WarningSignsViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_title")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "warning_signs_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createHighlightTextSectionView() -> HighlightTextSectionView {
        let view = HighlightTextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(
            title: localized("warning_signs_page_title_1"),
            description: localized("warning_signs_page_subtitle_1")
        )
        return view
    }

    private static func createWarningSignsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_1")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }

    private static func createMottoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_1_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createExcessiveGamingImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "excessive_gaming_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createMinorsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "minors_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createParentalControlImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "parental_control_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    // Constraints
    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.bannerImageView)
        self.scrollContainerView.addSubview(self.highlightTextSectionView)
        
        self.scrollContainerView.addSubview(self.warningSignsDescriptionLabel)
        self.scrollContainerView.addSubview(self.mottoLabel)
        
        self.scrollContainerView.addSubview(self.excessiveGamingImageView)
        self.scrollContainerView.addSubview(self.minorsImageView)
        self.scrollContainerView.addSubview(self.parentalControlImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
        ])

        // Scroll view
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Content
        NSLayoutConstraint.activate([
            self.bannerImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.bannerImageView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor),

            self.highlightTextSectionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSectionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSectionView.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 20),

            self.warningSignsDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.warningSignsDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.warningSignsDescriptionLabel.topAnchor.constraint(equalTo: self.highlightTextSectionView.bottomAnchor),

            self.mottoLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.mottoLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.mottoLabel.topAnchor.constraint(equalTo: self.warningSignsDescriptionLabel.bottomAnchor, constant: 20),

            self.excessiveGamingImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.excessiveGamingImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.excessiveGamingImageView.topAnchor.constraint(equalTo: self.mottoLabel.bottomAnchor, constant: 30),

            self.minorsImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.minorsImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.minorsImageView.topAnchor.constraint(equalTo: self.excessiveGamingImageView.bottomAnchor, constant: 20),

            self.parentalControlImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.parentalControlImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.parentalControlImageView.topAnchor.constraint(equalTo: self.minorsImageView.bottomAnchor, constant: 20),
            self.parentalControlImageView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30)
        ])
        
        self.bannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.bannerImageViewFixedHeightConstraint.isActive = true

        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1 / self.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
        
        // Excessive Gaming ImageView constraints
        self.excessiveGamingImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.excessiveGamingImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.excessiveGamingImageViewFixedHeightConstraint.isActive = true
        
        self.excessiveGamingImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.excessiveGamingImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.excessiveGamingImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.excessiveGamingImageViewDynamicHeightConstraint.isActive = false
        
        // Minors ImageView constraints
        self.minorsImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.minorsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.minorsImageViewFixedHeightConstraint.isActive = true
        
        self.minorsImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.minorsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.minorsImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.minorsImageViewDynamicHeightConstraint.isActive = false
        
        // Parental Control ImageView constraints
        self.parentalControlImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.parentalControlImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.parentalControlImageViewFixedHeightConstraint.isActive = true
        
        self.parentalControlImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.parentalControlImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.parentalControlImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.parentalControlImageViewDynamicHeightConstraint.isActive = false
    }
}
