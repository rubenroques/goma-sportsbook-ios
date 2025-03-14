//
//  PromotionDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

class PromotionDetailViewModel {
    
    var promotion: PromotionInfo
    
    init(promotion: PromotionInfo) {
        self.promotion = promotion
    }
}

class PromotionDetailViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var gradientHeaderView: GradientHeaderView = Self.createGradientHeaderView()
    private lazy var headerImageView: UIImageView = Self.createHeaderImageView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    
    private let viewModel: PromotionDetailViewModel

    // MARK: Lifetime and cycle
    init(viewModel: PromotionDetailViewModel) {

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        
        self.setupHeader()
        
        self.setupSections()
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.headerImageView.backgroundColor = .clear
        
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func setupHeader() {
        
        if let headerTitle = self.viewModel.promotion.staticPage.headerTitle {
            self.gradientHeaderView.configure(title: headerTitle)

        }
        
        if let headerImageName = self.viewModel.promotion.staticPage.headerImage {
            self.headerImageView.image = UIImage(named: "betsson_mobile_banner")
        }
        
        self.gradientHeaderView.isHidden = self.viewModel.promotion.staticPage.headerTitle != nil ? false : true
        
        self.headerImageView.isHidden = self.viewModel.promotion.staticPage.headerImage != nil ? false : true

    }
    
    private func setupSections() {
        
        for sectionBlock in self.viewModel.promotion.staticPage.sections {
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.layer.cornerRadius = CornerRadius.button
            stackView.backgroundColor = UIColor.App.backgroundSecondary
            
            if sectionBlock.type == "text" {
                
                if let textBlock = sectionBlock.text {
                    
                    let stackViewBlockView = StackViewBlockView()
                    stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
                    
                    var blockViews = [UIView]()
                    
                    for textContentBlock in textBlock.contentBlocks {
                        
                        if textContentBlock.blockType == "title" {
                            let titleBlockView = TitleBlockView()
                            titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                            titleBlockView.configure(title: textContentBlock.title ?? "")
                            
                            blockViews.append(titleBlockView)
                        }
                        else if textContentBlock.blockType == "description" {
                            let descriptionBlockView = DescriptionBlockView()
                            descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
                            descriptionBlockView.configure(description: textContentBlock.description ?? "")
                            
                            blockViews.append(descriptionBlockView)

                        }
                        else if textContentBlock.blockType == "image" {
                            let imageBlockView = ImageBlockView()
                            imageBlockView.translatesAutoresizingMaskIntoConstraints = false
                            imageBlockView.configure(imageName: textContentBlock.image ?? "")
                            
                            blockViews.append(imageBlockView)

                        }
                        else if textContentBlock.blockType == "video" {
                            let videoSectionView = VideoSectionView()
                            videoSectionView.translatesAutoresizingMaskIntoConstraints = false
                            if let url = URL(string: textContentBlock.video ?? "") {
                                videoSectionView.configure(videoURL: url)
                            }
                            
                            blockViews.append(videoSectionView)
                        }
                        else if textContentBlock.blockType == "button" {
                            let actionButtonBlockView = ActionButtonBlockView()
                            actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
                            actionButtonBlockView.configure(title: textContentBlock.buttonText ?? "", actionName: textContentBlock.buttonURL ?? "")
                            
                            actionButtonBlockView.tappedActionButtonAction = { [weak self] actionName in
                                print("CTA ACTION: \(actionName)")
                            }
                            
                            blockViews.append(actionButtonBlockView)
                        }
                    }
                    
                    stackViewBlockView.configure(views: blockViews)
                    
                    stackView.addArrangedSubview(stackViewBlockView)
                }
            }
            else if sectionBlock.type == "list" {
                
                if let listBlock = sectionBlock.list {
                    
                    let stackViewBlockView = StackViewBlockView()
                    stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
                    
                    var blockViews = [UIView]()
                    
                    for itemBlock in listBlock.items {
                        
                        let listBlockView = ListBlockView()
                        listBlockView.translatesAutoresizingMaskIntoConstraints = false
                        
                        var listBlockTitle = ""
                        var listBlockSubtitle = ""
                        var listBlockIconName = ""
                        
                        for itemContentBlock in itemBlock.contentBlocks {
                            
                            if itemContentBlock.blockType == "title" {
                                listBlockTitle = itemContentBlock.title ?? ""
                            }
                            else if itemContentBlock.blockType == "description" {
                                listBlockSubtitle = itemContentBlock.description ?? ""
                            }
                            else if itemContentBlock.blockType == "image" {
                                listBlockIconName = itemContentBlock.image ?? ""
                            }
                        }
                        
                        listBlockView.configure(iconName: listBlockIconName, title: listBlockTitle, subtitle: listBlockSubtitle)
                        
                        blockViews.append(listBlockView)
                    }
                    
                    stackViewBlockView.configure(views: blockViews)
                    
                    stackView.addArrangedSubview(stackViewBlockView)

                }
            }
            else if sectionBlock.type == "banner" {
                
                if let listBlock = sectionBlock.banner {
                    
                    if listBlock.bannerType == "image" {
                        let imageSectionView = ImageSectionView()
                        imageSectionView.translatesAutoresizingMaskIntoConstraints = false
                        imageSectionView.configure(imageName: listBlock.bannerLinkUrl ?? "")
                        
                        stackView.addArrangedSubview(imageSectionView)
                    }
                    else if listBlock.bannerType == "video" {
                        let videoSectionView = VideoSectionView()
                        videoSectionView.translatesAutoresizingMaskIntoConstraints = false
                        if let videoUrl = URL(string: listBlock.bannerLinkUrl ?? "") {
                            videoSectionView.configure(videoURL: videoUrl)
                        }
                        
                        stackView.addArrangedSubview(videoSectionView)
                    }
                }
            }
            
            self.stackView.addArrangedSubview(stackView)

        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
        
//        for i in 1...5 {
//            
//            let stackView = UIStackView()
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//            stackView.axis = .vertical
//            stackView.spacing = 0
//            stackView.layer.cornerRadius = CornerRadius.button
//            stackView.backgroundColor = UIColor.App.backgroundSecondary
//            
//            if i == 1 {
//                
//                let stackViewBlockView = StackViewBlockView()
//                stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
//                
//                let titleBlockView = TitleBlockView()
//                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
//                titleBlockView.configure(title: "Section \(i)")
//                
//                let imageBlockView = ImageBlockView()
//                imageBlockView.translatesAutoresizingMaskIntoConstraints = false
//                imageBlockView.configure(imageName: "betsson_mobile_banner")
//                
//                let descriptionBlockView = DescriptionBlockView()
//                descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
//                descriptionBlockView.configure(description: "A little setback? No worries. If your bet doesn't go as planned, our Replay feature is here to give you a second chance! Enjoy 10% of your stake back as soon as all selections on your ticket are closed, directly added as game credit.")
//                
//                let actionButtonBlockView = ActionButtonBlockView()
//                actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
//                actionButtonBlockView.configure(title: "Action", actionName: "openAction")
//                
//                actionButtonBlockView.tappedActionButtonAction = { [weak self] actionName in
//                    print("CTA ACTION: \(actionName)")
//                }
//                
//                stackViewBlockView.configure(views: [titleBlockView, descriptionBlockView, imageBlockView, actionButtonBlockView])
//                
//                stackView.addArrangedSubview(stackViewBlockView)
//
//            }
//            else if i == 2 {
//                let stackViewBlockView = StackViewBlockView()
//                stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
//                
//                let titleBlockView = TitleBlockView()
//                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
//                titleBlockView.configure(title: "Section \(i)")
//                
//                let listBlockView1 = ListBlockView()
//                listBlockView1.translatesAutoresizingMaskIntoConstraints = false
//                listBlockView1.configure(iconName: "active_toggle_icon", title: "Title 1", subtitle: "Subtitle 1")
//                
//                let listBlockView2 = ListBlockView()
//                listBlockView2.translatesAutoresizingMaskIntoConstraints = false
//                listBlockView2.configure(iconName: "active_toggle_icon", title: "Title 2", subtitle: "Subtitle 2")
//                
//                let listBlockView3 = ListBlockView()
//                listBlockView3.translatesAutoresizingMaskIntoConstraints = false
//                listBlockView3.configure(iconName: "active_toggle_icon", title: "Title 3", subtitle: "Subtitle 3 Subtitle 3 Subtitle 3 Subtitle 3 Subtitle 3")
//                
//                stackViewBlockView.configure(views: [titleBlockView, listBlockView1, listBlockView2, listBlockView3])
//                
//                stackView.addArrangedSubview(stackViewBlockView)
//
//            }
//            else if i == 3 {
//                
//                let stackViewBlockView = StackViewBlockView()
//                stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
//                
//                let titleBlockView = TitleBlockView()
//                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
//                titleBlockView.configure(title: "Section \(i)")
//                
//                let descriptionBlockView = DescriptionBlockView()
//                descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
//                descriptionBlockView.configure(description: "A little setback? No worries. If your bet doesn't go as planned, our Replay feature is here to give you a second chance! Enjoy 10% of your stake back as soon as all selections on your ticket are closed, directly added as game credit.")
//                
//                stackViewBlockView.configure(views: [titleBlockView, descriptionBlockView])
//                
//                stackView.addArrangedSubview(stackViewBlockView)
//                
//            }
//            else if i == 4 {
//                let videoSectionView = VideoSectionView()
//                videoSectionView.translatesAutoresizingMaskIntoConstraints = false
//                if let url = URL(string: "https://cms.gomademo.com/storage/169/01JNRDMSE04BYQ3RV9N4F8K2N2.mp4") {
//                    videoSectionView.configure(videoURL: url)
//                }
//                
//                stackView.addArrangedSubview(videoSectionView)
//
//            }
//            else {
//                let stackViewBlockView = StackViewBlockView()
//                stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
//                
//                let titleBlockView = TitleBlockView()
//                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
//                titleBlockView.configure(title: "Section \(i)")
//                
//                let descriptionBlockView = DescriptionBlockView()
//                descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
//                descriptionBlockView.configure(description: "A little setback? No worries. If your bet doesn't go as planned, our Replay feature is here to give you a second chance! Enjoy 10% of your stake back as soon as all selections on your ticket are closed, directly added as game credit.")
//                
//                let imageBlockView = ImageBlockView()
//                imageBlockView.translatesAutoresizingMaskIntoConstraints = false
//                imageBlockView.configure(imageName: "betsson_mobile_banner")
//                
//                let actionButtonBlockView = ActionButtonBlockView()
//                actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
//                actionButtonBlockView.configure(title: "Action", actionName: "openAction2")
//                
//                actionButtonBlockView.tappedActionButtonAction = { [weak self] actionName in
//                    print("CTA ACTION: \(actionName)")
//                }
//                
//                stackViewBlockView.configure(views: [imageBlockView, titleBlockView, descriptionBlockView, actionButtonBlockView])
//                       
//                stackView.addArrangedSubview(stackViewBlockView)
//            }
//            
//            self.stackView.addArrangedSubview(stackView)
//        }
    }
    
    // MARK: Actions
    @objc private func didTapBackButton() {
        
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PromotionDetailViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .center
        titleLabel.text = localized("promotions")
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView

    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createGradientHeaderView() -> GradientHeaderView {
        let gradientHeaderView = GradientHeaderView()
        gradientHeaderView.translatesAutoresizingMaskIntoConstraints = false
        return gradientHeaderView
    }
    
    private static func createHeaderImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        
        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.gradientHeaderView)
        self.containerView.addSubview(self.headerImageView)
        
        self.containerView.addSubview(self.stackView)

        self.view.addSubview(self.bottomSafeAreaView)
        

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 46),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 44),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),
            
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),
        ])
        
        NSLayoutConstraint.activate([
            
            self.gradientHeaderView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.gradientHeaderView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.gradientHeaderView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.gradientHeaderView.heightAnchor.constraint(equalToConstant: 208),
            
            self.headerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.headerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.headerImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.headerImageView.heightAnchor.constraint(equalToConstant: 208),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.gradientHeaderView.bottomAnchor, constant: -30),
            self.stackView.bottomAnchor.constraint(lessThanOrEqualTo: self.containerView.bottomAnchor, constant: -30)
        ])

    }

}
