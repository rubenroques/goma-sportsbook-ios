//
//  ResponsibleGameInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class ResponsibleGameInfoViewController: UIViewController {

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
    
    private lazy var highlightTextSectionView2: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var highlightTextSectionView3: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.highlightTextSectionViewModel3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statisticsLabel: UILabel = Self.createStatisticsLabel()
    private lazy var informationLabel: UILabel = Self.createInformationLabel()
    private lazy var mottoLabel: UILabel = Self.createMottoLabel()
    
    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var warningSignsButton: UIButton = Self.createWarningSignsButton()
    private lazy var stayInControlButton: UIButton = Self.createStayInControlButton()
    private lazy var needSupportButton: UIButton = Self.createNeedSupportButton()
    
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    // MARK: - ViewModel
    private let viewModel: ResponsibleGameInfoViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: ResponsibleGameInfoViewModel = ResponsibleGameInfoViewModel()) {
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
        
        self.warningSignsButton.addTarget(self, action: #selector(didTapButton1), for: .touchUpInside)
        self.stayInControlButton.addTarget(self, action: #selector(didTapButton2), for: .touchUpInside)
        self.needSupportButton.addTarget(self, action: #selector(didTapButton3), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.resizeBannerImageView()

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

        self.bannerImageView.backgroundColor = .red
        
        self.statisticsLabel.textColor = UIColor.App.highlightPrimary
        
        self.informationLabel.textColor = UIColor.App.textPrimary
        
        self.mottoLabel.textColor = UIColor.App.textPrimary
        
        self.buttonsStackView.backgroundColor = .clear
        
        StyleHelper.styleButton(button: warningSignsButton)
        StyleHelper.styleButton(button: stayInControlButton)
        StyleHelper.styleButton(button: needSupportButton)

    }
    
    // MARK: Functions
    private func resizeBannerImageView() {

        if let bannerImage = self.bannerImageView.image {

            self.viewModel.aspectRatio = bannerImage.size.width/bannerImage.size.height

            self.bannerImageViewFixedHeightConstraint.isActive = false

            self.bannerImageViewDynamicHeightConstraint =
            NSLayoutConstraint(item: self.bannerImageView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.bannerImageView,
                               attribute: .width,
                               multiplier: 1/self.viewModel.aspectRatio,
                               constant: 0)

            self.bannerImageViewDynamicHeightConstraint.isActive = true
        }
    }

    // MARK: - Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapButton1() {
        let warningSignsViewController = WarningSignsViewController()

        self.navigationController?.pushViewController(warningSignsViewController, animated: true)
    }
    
    @objc private func didTapButton2() {
        let stayInControlViewController = StayInControlViewController()

        self.navigationController?.pushViewController(stayInControlViewController, animated: true)
    }
    
    @objc private func didTapButton3() {
        let needSupportViewController = NeedSupportViewController()

        self.navigationController?.pushViewController(needSupportViewController, animated: true)
    }
}

//
// MARK: - Subviews initialization and setup
//
extension ResponsibleGameInfoViewController {

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
        label.text = localized("responsible_game_title")
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
        imageView.image = UIImage(named: "responsible_game_info_banner")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createStatisticsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("responsible_gaming_page_description_3_part_2")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createInformationLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("responsible_gaming_page_description_3_part_3")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createMottoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("responsible_gaming_page_title_4")
        label.font = AppFont.with(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }

    private static func createWarningSignsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("responsible_gaming_page_cta_1"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return button
    }

    private static func createStayInControlButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("responsible_gaming_page_cta_2"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return button
    }

    private static func createNeedSupportButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("responsible_gaming_page_cta_3"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return button
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

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.bannerImageView)
        self.scrollContainerView.addSubview(self.highlightTextSectionView)
        self.scrollContainerView.addSubview(self.highlightTextSectionView2)
        self.scrollContainerView.addSubview(self.highlightTextSectionView3)
        
        self.scrollContainerView.addSubview(self.statisticsLabel)
        self.scrollContainerView.addSubview(self.informationLabel)
        self.scrollContainerView.addSubview(self.mottoLabel)
        
        self.scrollContainerView.addSubview(self.buttonsStackView)
        
        self.buttonsStackView.addArrangedSubview(self.warningSignsButton)
        self.buttonsStackView.addArrangedSubview(self.stayInControlButton)
        self.buttonsStackView.addArrangedSubview(self.needSupportButton)

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

            self.highlightTextSectionView2.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSectionView2.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSectionView2.topAnchor.constraint(equalTo: self.highlightTextSectionView.bottomAnchor),

            self.highlightTextSectionView3.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.highlightTextSectionView3.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.highlightTextSectionView3.topAnchor.constraint(equalTo: self.highlightTextSectionView2.bottomAnchor),

            self.statisticsLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.statisticsLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.statisticsLabel.topAnchor.constraint(equalTo: self.highlightTextSectionView3.bottomAnchor),

            self.informationLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.informationLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.informationLabel.topAnchor.constraint(equalTo: self.statisticsLabel.bottomAnchor, constant: 20),

            self.mottoLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.mottoLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.mottoLabel.topAnchor.constraint(equalTo: self.informationLabel.bottomAnchor, constant: 20),

            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 50),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -50),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.mottoLabel.bottomAnchor, constant: 30),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30),
            
            self.warningSignsButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.stayInControlButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.needSupportButton.heightAnchor.constraint(equalToConstant: 50),

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
                           multiplier: 1/self.viewModel.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
    }
}
