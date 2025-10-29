//
//  StayInControlViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class StayInControlViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var highlightTextSectionView: HighlightTextSectionView = Self.createHighlightTextSectionView()
    
    private lazy var advicesImageView: UIImageView = Self.createAdvicesImageView()
    private lazy var gameModeratorsImageView: UIImageView = Self.createGameModeratorsImageView()
    private lazy var actsImageView: UIImageView = Self.createActsImageView()
    
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private lazy var advicesImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var advicesImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var gameModeratorsImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var gameModeratorsImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var actsImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var actsImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    // MARK: - ViewModel
    private let viewModel: StayInControlViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: StayInControlViewModel = StayInControlViewModel()) {
        self.viewModel = viewModel
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
        
        if let bannerImage = self.bannerImageView.image {
            self.viewModel.aspectRatio = bannerImage.size.width / bannerImage.size.height
        }
        
        self.resizeImageView(
            imageView: self.bannerImageView,
            fixedHeightConstraint: &self.bannerImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.bannerImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.advicesImageView,
            fixedHeightConstraint: &self.advicesImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.advicesImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.gameModeratorsImageView,
            fixedHeightConstraint: &self.gameModeratorsImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.gameModeratorsImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.actsImageView,
            fixedHeightConstraint: &self.actsImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.actsImageViewDynamicHeightConstraint
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
        
        self.advicesImageView.backgroundColor = .clear
        
        self.gameModeratorsImageView.backgroundColor = .clear
        
        self.actsImageView.backgroundColor = .clear
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
extension StayInControlViewController {

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
        label.text = localized("responsible_gaming_page_cta_2")
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
        imageView.image = UIImage(named: "stay_in_control_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createHighlightTextSectionView() -> HighlightTextSectionView {
        let view = HighlightTextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(
            title: localized("stay_in_control_page_title_1"),
            description: localized("stay_in_control_page_description_1")
        )
        return view
    }

    private static func createAdvicesImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "advices_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createGameModeratorsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "game_moderators_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createActsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "acts_image")
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
        
        self.scrollContainerView.addSubview(self.advicesImageView)
        self.scrollContainerView.addSubview(self.gameModeratorsImageView)
        self.scrollContainerView.addSubview(self.actsImageView)

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

            self.advicesImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.advicesImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.advicesImageView.topAnchor.constraint(equalTo: self.highlightTextSectionView.bottomAnchor, constant: 10),

            self.gameModeratorsImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.gameModeratorsImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.gameModeratorsImageView.topAnchor.constraint(equalTo: self.advicesImageView.bottomAnchor, constant: 30),

            self.actsImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.actsImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.actsImageView.topAnchor.constraint(equalTo: self.gameModeratorsImageView.bottomAnchor, constant: 30),
            self.actsImageView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30)
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
                           multiplier: 1 / self.viewModel.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
        
        // Advices ImageView constraints
        self.advicesImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.advicesImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.advicesImageViewFixedHeightConstraint.isActive = true
        
        self.advicesImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.advicesImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.advicesImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.advicesImageViewDynamicHeightConstraint.isActive = false
        
        // Game Moderators ImageView constraints
        self.gameModeratorsImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.gameModeratorsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.gameModeratorsImageViewFixedHeightConstraint.isActive = true
        
        self.gameModeratorsImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.gameModeratorsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.gameModeratorsImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.gameModeratorsImageViewDynamicHeightConstraint.isActive = false
        
        // Acts ImageView constraints
        self.actsImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.actsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.actsImageViewFixedHeightConstraint.isActive = true
        
        self.actsImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.actsImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.actsImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.actsImageViewDynamicHeightConstraint.isActive = false
    }
}
