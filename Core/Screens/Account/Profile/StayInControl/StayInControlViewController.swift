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
    
    private lazy var highlightTextSectionView: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var advicesImageView: UIImageView = Self.createAdvicesImageView()
    
    private lazy var highlightTextSection2View: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sosButton: UIButton = Self.createSOSButton()
    private lazy var gamersInfoButton: UIButton = Self.creategamersInfoButton()
        
    private lazy var budgetImageView: UIImageView = Self.createBudgetImageView()
    private lazy var section1TitleLabel: UILabel = Self.createSection1TitleLabel()
    private lazy var section1DescriptionLabel: UILabel = Self.createSection1DescriptionLabel()
    
    private lazy var gameModeratorsImageView: UIImageView = Self.createGameModeratorsImageView()
    private lazy var section2TitleLabel: UILabel = Self.createSection2TitleLabel()
    private lazy var section2DescriptionLabel: UILabel = Self.createSection2DescriptionLabel()

    private lazy var bellImageView: UIImageView = Self.createBellImageView()
    private lazy var section3TitleLabel: UILabel = Self.createSection3TitleLabel()
    private lazy var section3SubtitleLabel: UILabel = Self.createSection3SubtitleLabel()
    
    private lazy var section3Title2Label: UILabel = Self.createSection3Title2Label()
    private lazy var section3DescriptionLabel: UILabel = Self.createSection3DescriptionLabel()
    
    private lazy var needSupportButton: UIButton = Self.createNeedSupportButton()
    
    private lazy var helpImageView: UIImageView = Self.createHelpImageView()
    private lazy var section4TitleLabel: UILabel = Self.createSection4TitleLabel()
    private lazy var section4DescriptionLabel: UILabel = Self.createSection4DescriptionLabel()

    private lazy var actsImageView: UIImageView = Self.createActsImageView()
    
    private lazy var section5TitleLabel: UILabel = Self.createSection5TitleLabel()
    private lazy var section5DescriptionLabel: UILabel = Self.createSection5DescriptionLabel()
    private lazy var section5Description2Label: UILabel = Self.createSection5Description2Label()
        
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private lazy var advicesImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var advicesImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
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

    private static func createAdvicesImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "advices_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSOSButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "sos_logo"), for: .normal)
        return button
    }
    
    private static func creategamersInfoButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "player_info_logo"), for: .normal)
        return button
    }
    
    private static func createBudgetImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "budget_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSection1TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_title_3")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_3")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createGameModeratorsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "game_moderators_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSection2TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_title_5")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection2DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_5")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createBellImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bell_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSection3TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_5_subtitle_1")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3SubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_5_subtitle_2")
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3Title2Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_title_4")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_4")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createNeedSupportButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("need_support"), for: .normal)
        return button
    }
    
    private static func createHelpImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "help_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSection4TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_6")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection4DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_6_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createActsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "acts_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSection5TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_6")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection5DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_7_part_1")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection5Description2Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("stay_in_control_page_description_7_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
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
        
        self.scrollContainerView.addSubview(self.highlightTextSection2View)
        
        self.scrollContainerView.addSubview(self.sosButton)
        self.scrollContainerView.addSubview(self.gamersInfoButton)

        self.scrollContainerView.addSubview(self.budgetImageView)
        self.scrollContainerView.addSubview(self.section1TitleLabel)
        self.scrollContainerView.addSubview(self.section1DescriptionLabel)

        self.scrollContainerView.addSubview(self.gameModeratorsImageView)
        self.scrollContainerView.addSubview(self.section2TitleLabel)
        self.scrollContainerView.addSubview(self.section2DescriptionLabel)
        
        self.scrollContainerView.addSubview(self.bellImageView)
        self.scrollContainerView.addSubview(self.section3TitleLabel)
        self.scrollContainerView.addSubview(self.section3SubtitleLabel)
        self.scrollContainerView.addSubview(self.section3Title2Label)
        self.scrollContainerView.addSubview(self.section3DescriptionLabel)
        self.scrollContainerView.addSubview(self.needSupportButton)

        self.scrollContainerView.addSubview(self.helpImageView)
        self.scrollContainerView.addSubview(self.section4TitleLabel)
        self.scrollContainerView.addSubview(self.section4DescriptionLabel)
        
        self.scrollContainerView.addSubview(self.actsImageView)
        self.scrollContainerView.addSubview(self.section5TitleLabel)
        self.scrollContainerView.addSubview(self.section5DescriptionLabel)
        self.scrollContainerView.addSubview(self.section5Description2Label)

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
            
            self.highlightTextSection2View.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSection2View.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSection2View.topAnchor.constraint(equalTo: self.advicesImageView.bottomAnchor, constant: 20),
            
            self.sosButton.trailingAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor, constant: -10),
            self.sosButton.topAnchor.constraint(equalTo: self.highlightTextSection2View.bottomAnchor, constant: 10),
            self.sosButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.gamersInfoButton.leadingAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor, constant: 10),
            self.gamersInfoButton.topAnchor.constraint(equalTo: self.highlightTextSection2View.bottomAnchor, constant: 10),
            self.gamersInfoButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.budgetImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.budgetImageView.topAnchor.constraint(equalTo: self.sosButton.bottomAnchor, constant: 20),
            self.budgetImageView.heightAnchor.constraint(equalToConstant: 150),
            self.budgetImageView.widthAnchor.constraint(equalToConstant: 150),

            self.section1TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section1TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section1TitleLabel.topAnchor.constraint(equalTo: self.budgetImageView.bottomAnchor, constant: 20),
            
            self.section1DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section1DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section1DescriptionLabel.topAnchor.constraint(equalTo: self.section1TitleLabel.bottomAnchor, constant: 10),
            
            self.gameModeratorsImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.gameModeratorsImageView.topAnchor.constraint(equalTo: self.section1DescriptionLabel.bottomAnchor, constant: 20),
            self.gameModeratorsImageView.heightAnchor.constraint(equalToConstant: 100),
            self.gameModeratorsImageView.widthAnchor.constraint(equalToConstant: 250),
            
            self.section2TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section2TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section2TitleLabel.topAnchor.constraint(equalTo: self.gameModeratorsImageView.bottomAnchor, constant: 20),
            
            self.section2DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section2DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section2DescriptionLabel.topAnchor.constraint(equalTo: self.section2TitleLabel.bottomAnchor, constant: 10),
            
            self.bellImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.bellImageView.topAnchor.constraint(equalTo: self.section2DescriptionLabel.bottomAnchor, constant: 20),
            self.bellImageView.heightAnchor.constraint(equalToConstant: 150),
            self.bellImageView.widthAnchor.constraint(equalToConstant: 150),
            
            self.section3TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section3TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section3TitleLabel.topAnchor.constraint(equalTo: self.bellImageView.bottomAnchor, constant: 20),
            
            self.section3SubtitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section3SubtitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section3SubtitleLabel.topAnchor.constraint(equalTo: self.section3TitleLabel.bottomAnchor, constant: 10),
            
            self.section3Title2Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section3Title2Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section3Title2Label.topAnchor.constraint(equalTo: self.section3SubtitleLabel.bottomAnchor, constant: 10),
            
            self.section3DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section3DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section3DescriptionLabel.topAnchor.constraint(equalTo: self.section3Title2Label.bottomAnchor, constant: 10),
            
            self.needSupportButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.needSupportButton.topAnchor.constraint(equalTo: self.section3DescriptionLabel.bottomAnchor, constant: 10),
            self.needSupportButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.helpImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.helpImageView.topAnchor.constraint(equalTo: self.needSupportButton.bottomAnchor, constant: 20),
            self.helpImageView.heightAnchor.constraint(equalToConstant: 100),
            self.helpImageView.widthAnchor.constraint(equalToConstant: 250),
            
            self.section4TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section4TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section4TitleLabel.topAnchor.constraint(equalTo: self.helpImageView.bottomAnchor, constant: 20),
            
            self.section4DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section4DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section4DescriptionLabel.topAnchor.constraint(equalTo: self.section4TitleLabel.bottomAnchor, constant: 10),
            
            self.actsImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.actsImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.actsImageView.topAnchor.constraint(equalTo: self.section4DescriptionLabel.bottomAnchor, constant: 20),
            
            self.section5TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section5TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section5TitleLabel.topAnchor.constraint(equalTo: self.actsImageView.bottomAnchor, constant: 20),
            
            self.section5DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section5DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section5DescriptionLabel.topAnchor.constraint(equalTo: self.section5TitleLabel.bottomAnchor, constant: 10),
            
            self.section5Description2Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.section5Description2Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.section5Description2Label.topAnchor.constraint(equalTo: self.section5DescriptionLabel.bottomAnchor, constant: 10),
            self.section5Description2Label.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30)
            
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
