//
//  NeedSupportViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class NeedSupportViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var mainTitleLabel: UILabel = Self.createMainTitleLabel()
    private lazy var mainDescriptionLabel: UILabel = Self.createMainDescriptionLabel()
    
    private lazy var highlightDescriptionView: HighlightDescriptionView = {
        let view = HighlightDescriptionView(viewModel: self.viewModel.highlightDescriptionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sosButton: UIButton = Self.createSOSButton()
    
    private lazy var arpejLogoActionDescriptionView: LogoActionDescriptionView = {
        let view = LogoActionDescriptionView(viewModel: self.viewModel.arpejLogoActionDescriptionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var highlightTextSectionView: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contactButton: UIButton = Self.createContactButton()
    private lazy var contactMottoLabel: UILabel = Self.createContactMottoLabel()
    
    private lazy var highlightTextSectionView2: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contactFinalDescriptionLabel: UILabel = Self.createContactFinalDescriptionLabel()
    private lazy var aidOrganisationTitleLabel: UILabel = Self.createAidOrganisationTitleLabel()
    
    private lazy var sosLogoActionDescriptionView: LogoActionDescriptionView = {
        let view = LogoActionDescriptionView(viewModel: self.viewModel.sosLogoViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playerInfoLogoActionDescriptionView: LogoActionDescriptionView = {
        let view = LogoActionDescriptionView(viewModel: self.viewModel.playerInfoLogoViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gambanLogoActionDescriptionView: LogoActionDescriptionView = {
        let view = LogoActionDescriptionView(viewModel: self.viewModel.gambanLogoViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gameInterdictionImageView: UIImageView = Self.createGameInterdictionImageView()
    private lazy var gameInterdictionDescriptionLabel: UILabel = Self.createGameInterdictionDescriptionLabel()
    private lazy var gameInterdictionStepsLabel: UILabel = Self.createGameInterdictionStepsLabel()
    
    private lazy var anjButton: UIButton = Self.createAnjButton()
    
    private lazy var anjLabel: UILabel = Self.createAnjLabel()
    private lazy var anjImageView: UIImageView = Self.createAnjImageView()
    
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private lazy var gameInterdictionImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var gameInterdictionImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var anjImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var anjImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    // MARK: - ViewModel
    private let viewModel: NeedSupportViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: NeedSupportViewModel = NeedSupportViewModel()) {
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
        self.sosButton.addTarget(self, action: #selector(didTapSOSButton), for: .touchUpInside)
        self.contactButton.addTarget(self, action: #selector(didTapContactButton), for: .touchUpInside)
        self.anjButton.addTarget(self, action: #selector(didTapANJButton), for: .touchUpInside)
        self.setupCallbacks()
        
        let anjTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnjImageView))
        self.anjImageView.isUserInteractionEnabled = true
        self.anjImageView.addGestureRecognizer(anjTapGesture)
    }
    
    private func setupCallbacks() {
        
        self.arpejLogoActionDescriptionView.didTapLogo = { [weak self] url in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
        
        self.sosLogoActionDescriptionView.didTapLogo = { [weak self] url in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
        
        self.playerInfoLogoActionDescriptionView.didTapLogo = { [weak self] url in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
        
        self.gambanLogoActionDescriptionView.didTapLogo = { [weak self] url in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
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
            imageView: self.gameInterdictionImageView,
            fixedHeightConstraint: &self.gameInterdictionImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.gameInterdictionImageViewDynamicHeightConstraint
        )
        
        self.resizeImageView(
            imageView: self.anjImageView,
            fixedHeightConstraint: &self.anjImageViewFixedHeightConstraint,
            dynamicHeightConstraint: &self.anjImageViewDynamicHeightConstraint
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
        
        self.mainTitleLabel.textColor = UIColor.App.highlightPrimary
        
        self.mainDescriptionLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButton(button: self.contactButton)
        
        self.contactMottoLabel.textColor = UIColor.App.textPrimary
        
        self.contactFinalDescriptionLabel.textColor = UIColor.App.textPrimary
        
        self.aidOrganisationTitleLabel.textColor = UIColor.App.highlightPrimary
        
        self.gameInterdictionImageView.backgroundColor = .clear
        
        self.gameInterdictionDescriptionLabel.textColor = UIColor.App.textPrimary
        
        self.gameInterdictionStepsLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButton(button: self.anjButton)

        self.anjLabel.textColor = UIColor.App.textPrimary
        
        self.anjImageView.backgroundColor = .clear
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
    
    @objc private func didTapContactButton() {
        if let url = URL(string: self.viewModel.contactButtonUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapSOSButton() {
        if let url = URL(string: self.viewModel.sosButtonUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapANJButton() {
        if let url = URL(string: self.viewModel.anjButtonUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapAnjImageView() {
        if let url = URL(string: self.viewModel.anjImageViewUrl) {
            UIApplication.shared.open(url)
        }
    }
}

//
// MARK: - Subviews initialization and setup
//
extension NeedSupportViewController {

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
        label.text = localized("responsible_gaming_page_cta_3")
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
        imageView.image = UIImage(named: "need_support_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createMainDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_description_1")
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createMainTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_title_1")
        label.font = AppFont.with(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSOSButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "sos_logo"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createContactButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("need_support_page_cta_1"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }

    private static func createContactMottoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_description_3_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createContactFinalDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_description_4_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createAidOrganisationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_title_5")
        label.font = AppFont.with(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createGameInterdictionImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "game_interdiction_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createGameInterdictionDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_description_6")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createGameInterdictionStepsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_description_6_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createAnjButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("demande_interdiction"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }

    private static func createAnjLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_support_page_title_6")
        label.font = AppFont.with(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createAnjImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "anj_logo")
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
        self.scrollContainerView.addSubview(self.mainTitleLabel)
        self.scrollContainerView.addSubview(self.mainDescriptionLabel)
        self.scrollContainerView.addSubview(self.highlightDescriptionView)
        
        self.scrollContainerView.addSubview(self.sosButton)
        
        self.scrollContainerView.addSubview(self.arpejLogoActionDescriptionView)
        self.scrollContainerView.addSubview(self.highlightTextSectionView)
        
        self.scrollContainerView.addSubview(self.contactButton)
        self.scrollContainerView.addSubview(self.contactMottoLabel)
        self.scrollContainerView.addSubview(self.highlightTextSectionView2)
        
        self.scrollContainerView.addSubview(self.contactFinalDescriptionLabel)
        self.scrollContainerView.addSubview(self.aidOrganisationTitleLabel)
        
        self.scrollContainerView.addSubview(self.sosLogoActionDescriptionView)
        self.scrollContainerView.addSubview(self.playerInfoLogoActionDescriptionView)
        self.scrollContainerView.addSubview(self.gambanLogoActionDescriptionView)
        
        self.scrollContainerView.addSubview(self.gameInterdictionImageView)
        self.scrollContainerView.addSubview(self.gameInterdictionDescriptionLabel)
        self.scrollContainerView.addSubview(self.gameInterdictionStepsLabel)
        
        self.scrollContainerView.addSubview(self.anjButton)
        
        self.scrollContainerView.addSubview(self.anjLabel)
        self.scrollContainerView.addSubview(self.anjImageView)

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

            self.mainDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.mainDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.mainDescriptionLabel.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 20),

            self.mainTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.mainTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.mainTitleLabel.topAnchor.constraint(equalTo: self.mainDescriptionLabel.bottomAnchor, constant: 20),

            self.arpejLogoActionDescriptionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.arpejLogoActionDescriptionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.arpejLogoActionDescriptionView.topAnchor.constraint(equalTo: self.mainTitleLabel.bottomAnchor, constant: 20),

            self.highlightDescriptionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightDescriptionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightDescriptionView.topAnchor.constraint(equalTo: self.arpejLogoActionDescriptionView.bottomAnchor),
            
            self.sosButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.sosButton.topAnchor.constraint(equalTo: self.highlightDescriptionView.bottomAnchor, constant: 10),
            self.sosButton.widthAnchor.constraint(equalToConstant: 150),
            self.sosButton.heightAnchor.constraint(equalToConstant: 100),

            self.highlightTextSectionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSectionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSectionView.topAnchor.constraint(equalTo: self.sosButton.bottomAnchor),

            self.contactButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.contactButton.topAnchor.constraint(equalTo: self.highlightTextSectionView.bottomAnchor, constant: 10),
            self.contactButton.heightAnchor.constraint(equalToConstant: 50),

            self.contactMottoLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.contactMottoLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.contactMottoLabel.topAnchor.constraint(equalTo: self.contactButton.bottomAnchor, constant: 20),

            self.highlightTextSectionView2.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSectionView2.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSectionView2.topAnchor.constraint(equalTo: self.contactMottoLabel.bottomAnchor, constant: 0),

            self.contactFinalDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.contactFinalDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.contactFinalDescriptionLabel.topAnchor.constraint(equalTo: self.highlightTextSectionView2.bottomAnchor, constant: 0),

            self.aidOrganisationTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.aidOrganisationTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.aidOrganisationTitleLabel.topAnchor.constraint(equalTo: self.contactFinalDescriptionLabel.bottomAnchor, constant: 30),

            self.sosLogoActionDescriptionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.sosLogoActionDescriptionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.sosLogoActionDescriptionView.topAnchor.constraint(equalTo: self.aidOrganisationTitleLabel.bottomAnchor),

            self.playerInfoLogoActionDescriptionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.playerInfoLogoActionDescriptionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.playerInfoLogoActionDescriptionView.topAnchor.constraint(equalTo: self.sosLogoActionDescriptionView.bottomAnchor, constant: 20),

            self.gambanLogoActionDescriptionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.gambanLogoActionDescriptionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.gambanLogoActionDescriptionView.topAnchor.constraint(equalTo: self.playerInfoLogoActionDescriptionView.bottomAnchor, constant: 20),

            self.gameInterdictionImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.gameInterdictionImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.gameInterdictionImageView.topAnchor.constraint(equalTo: self.gambanLogoActionDescriptionView.bottomAnchor, constant: 30),

            self.gameInterdictionDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.gameInterdictionDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.gameInterdictionDescriptionLabel.topAnchor.constraint(equalTo: self.gameInterdictionImageView.bottomAnchor, constant: 20),

            self.gameInterdictionStepsLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.gameInterdictionStepsLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.gameInterdictionStepsLabel.topAnchor.constraint(equalTo: self.gameInterdictionDescriptionLabel.bottomAnchor, constant: 30),
            
            self.anjButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.anjButton.topAnchor.constraint(equalTo: self.gameInterdictionStepsLabel.bottomAnchor, constant: 10),
            self.anjButton.heightAnchor.constraint(equalToConstant: 50),

            self.anjLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.anjLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.anjLabel.topAnchor.constraint(equalTo: self.anjButton.bottomAnchor, constant: 20),

            self.anjImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.anjImageView.topAnchor.constraint(equalTo: self.anjLabel.bottomAnchor, constant: 20),
            self.anjImageView.widthAnchor.constraint(equalToConstant: 160),
            self.anjImageView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30)
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
        
        // Game Interdiction ImageView constraints
        self.gameInterdictionImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.gameInterdictionImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.gameInterdictionImageViewFixedHeightConstraint.isActive = true
        
        self.gameInterdictionImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.gameInterdictionImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.gameInterdictionImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.gameInterdictionImageViewDynamicHeightConstraint.isActive = false
        
        // ANJ ImageView constraints
        self.anjImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.anjImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 160)
        self.anjImageViewFixedHeightConstraint.isActive = true
        
        self.anjImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.anjImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.anjImageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0)
        self.anjImageViewDynamicHeightConstraint.isActive = false
    }
}
