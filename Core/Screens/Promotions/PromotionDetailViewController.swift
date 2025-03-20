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
    private lazy var termsContainerView: UIView = Self.createTermsContainerView()
    private lazy var termsView: UIView = Self.createTermsView()
    private lazy var termsTitleLabel: UILabel = Self.createTermsTitleLabel()
    private lazy var termsToggleButton: UIButton = Self.createTermsToggleButton()
    private lazy var termsDescriptionLabel: UILabel = Self.createTermsDescriptionLabel()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    
    // Constraints
    private lazy var stackViewBottomConstraint: NSLayoutConstraint = Self.createStackViewBottomConstraint()
    private lazy var termsContainerBottomConstraint: NSLayoutConstraint = Self.createTermsContainerBottomConstraint()
    private lazy var termsViewBottomConstraint: NSLayoutConstraint = Self.createTermsViewBottomConstraint()
    private lazy var termsDescriptionLabelBottomConstraint: NSLayoutConstraint = Self.createTermsDescriptionLabelBottomConstraint()
    
    private let viewModel: PromotionDetailViewModel
    
    // MARK: Public properties
    var isTermsCollapsed = true {
        didSet {
            if isTermsCollapsed {
                self.termsToggleButton.setImage(UIImage(named: "arrow_down_icon"), for: .normal)

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.termsDescriptionLabel.alpha = 0
                }, completion: { _ in
                    self.termsDescriptionLabel.isHidden = true
                })
                self.termsViewBottomConstraint.isActive = true
                self.termsDescriptionLabelBottomConstraint.isActive = false

            }
            else {
                self.termsToggleButton.setImage(UIImage(named: "arrow_up_icon"), for: .normal)

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    if self.termsDescriptionLabel.alpha != self.enabledAlpha && self.termsDescriptionLabel.alpha != 0 {
                        self.termsDescriptionLabel.alpha = self.disabledAlpha
                    }
                    else {
                        self.termsDescriptionLabel.alpha = self.enabledAlpha
                    }
                    self.termsDescriptionLabel.isHidden = false
                }, completion: { _ in
                })
                self.termsViewBottomConstraint.isActive = false
                self.termsDescriptionLabelBottomConstraint.isActive = true

            }
        }
    }
    
    var disabledAlpha: CGFloat = 0.7
    var enabledAlpha: CGFloat = 1.0

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
        
        if self.viewModel.promotion.staticPage.terms.isNotEmpty {
            self.setupTerms()
            self.stackViewBottomConstraint.isActive = false
            self.termsContainerBottomConstraint.isActive = true

            let termsToggleTap = UITapGestureRecognizer(target: self, action: #selector(didTapToggleButton))
            self.termsView.addGestureRecognizer(termsToggleTap)
            
            self.isTermsCollapsed = true
        }
        else {
            self.termsContainerView.isHidden = true
            self.stackViewBottomConstraint.isActive = true
            self.termsContainerBottomConstraint.isActive = false
        }
        
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
        
        if let headerImageName = self.viewModel.promotion.staticPage.headerImageUrl,
           let headerUrl = URL(string: headerImageName){
            self.headerImageView.kf.setImage(with: headerUrl)
        }
        
        self.gradientHeaderView.isHidden = self.viewModel.promotion.staticPage.headerTitle != nil ? false : true
        
        self.headerImageView.isHidden = self.viewModel.promotion.staticPage.headerImageUrl != nil ? false : true

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
                            let videoBlockView = VideoBlockView()
                            videoBlockView.translatesAutoresizingMaskIntoConstraints = false
                            if let url = URL(string: textContentBlock.video ?? "") {
                                videoBlockView.configure(videoURL: url)
                            }
                            
                            blockViews.append(videoBlockView)
                        }
                        else if textContentBlock.blockType == "button" {
                            let actionButtonBlockView = ActionButtonBlockView()
                            actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
                            actionButtonBlockView.configure(title: textContentBlock.buttonText ?? "", actionName: textContentBlock.buttonURL ?? "")
                            
                            actionButtonBlockView.tappedActionButtonAction = { [weak self] actionName in
                                
                                self?.openAction(actionName: actionName)
                            }
                            
                            blockViews.append(actionButtonBlockView)
                        }
                        else if textContentBlock.blockType == "bulleted_list" {
                            
                            if let bulletedListItems = textContentBlock.bulletedListItems {
                                
                                for bulletedListItem in bulletedListItems {
                                    
                                    let bulletedItemBlock = BulletItemBlockView()
                                    bulletedItemBlock.translatesAutoresizingMaskIntoConstraints = false
                                    bulletedItemBlock.configure(title: bulletedListItem.text)
                                    
                                    blockViews.append(bulletedItemBlock)
                                }
                                
                            }
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
                    
                    if let title = listBlock.title {
                        let titleBlockView = TitleBlockView()
                        titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                        titleBlockView.configure(title: title)
                        
                        blockViews.append(titleBlockView)
                    }
                    
                    for itemBlock in listBlock.items {
                        
                        var listItemViews = [UIView]()
                        
                        let listBlockView = ListBlockView()
                        listBlockView.translatesAutoresizingMaskIntoConstraints = false
                        
                        var itemIconName = listBlock.genericListItemsIcon
                        
                        if let itemBlockIconName = itemBlock.itemIcon {
                            itemIconName = itemBlockIconName
                        }
                        
                        for textContentBlock in itemBlock.contentBlocks {
                            
                            if textContentBlock.blockType == "title" {
                                let titleBlockView = TitleBlockView()
                                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                                titleBlockView.configure(title: textContentBlock.title ?? "")
                                titleBlockView.isCentered = false
                                
                                listItemViews.append(titleBlockView)
                            }
                            else if textContentBlock.blockType == "description" {
                                let descriptionBlockView = DescriptionBlockView()
                                descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
                                descriptionBlockView.configure(description: textContentBlock.description ?? "")
                                
                                listItemViews.append(descriptionBlockView)

                            }
                            else if textContentBlock.blockType == "image" {
                                let imageBlockView = ImageBlockView()
                                imageBlockView.translatesAutoresizingMaskIntoConstraints = false
                                imageBlockView.configure(imageName: textContentBlock.image ?? "")
                                
                                listItemViews.append(imageBlockView)

                            }
                            else if textContentBlock.blockType == "video" {
                                let videoBlockView = VideoBlockView()
                                videoBlockView.translatesAutoresizingMaskIntoConstraints = false
                                if let url = URL(string: textContentBlock.video ?? "") {
                                    videoBlockView.configure(videoURL: url)
                                }
                                
                                listItemViews.append(videoBlockView)
                            }
                            else if textContentBlock.blockType == "button" {
                                let actionButtonBlockView = ActionButtonBlockView()
                                actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
                                actionButtonBlockView.configure(title: textContentBlock.buttonText ?? "", actionName: textContentBlock.buttonURL ?? "")
                                
                                actionButtonBlockView.tappedActionButtonAction = { [weak self] actionName in
                                    
                                    self?.openAction(actionName: actionName)
                                }
                                
                                listItemViews.append(actionButtonBlockView)
                            }
                            else if textContentBlock.blockType == "bulleted_list" {
                                
                                if let bulletedListItems = textContentBlock.bulletedListItems {
                                    
                                    for bulletedListItem in bulletedListItems {
                                        
                                        let bulletedItemBlock = BulletItemBlockView()
                                        bulletedItemBlock.translatesAutoresizingMaskIntoConstraints = false
                                        bulletedItemBlock.configure(title: bulletedListItem.text)
                                        
                                        listItemViews.append(bulletedItemBlock)
                                    }
                                    
                                }
                            }
                        }
                        
                        listBlockView.configure(iconName: itemIconName ?? "", views: listItemViews)
                        
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
                        imageSectionView.configure(imageName: listBlock.imageUrl ?? "")
                        
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
    
    private func setupTerms() {
        
        let label = self.termsDescriptionLabel
        
        var termsText = ""
        
        for term in self.viewModel.promotion.staticPage.terms {
            termsText.append("• \(term.label)\n")
        }
        
        label.text = termsText
        label.textAlignment = .left
        label.numberOfLines = 0

        let text = termsText
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: termsText)
        var range = (text as NSString).range(of: "•")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .left

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .bold, size: 14), range: fullRange)

        while range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)
            range = (text as NSString).range(of: "•", range: NSRange(location: range.location + 1, length: text.count - range.location - 1))
        }

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
    }
    
    private func openAction(actionName: String) {
        if let url = URL(string: actionName) {
            UIApplication.shared.open(url)
        }
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
    
    @objc private func didTapToggleButton() {
        self.isTermsCollapsed = !self.isTermsCollapsed
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
    
    private static func createTermsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTermsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTermsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.text = localized("terms_and_conditions")
        label.textAlignment = .center
        return label
    }

    private static func createTermsToggleButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_down_icon"), for: .normal)
        return button
    }

    private static func createTermsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // Constraint
    private static func createStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createTermsContainerBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createTermsViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createTermsDescriptionLabelBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
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
        
        self.containerView.addSubview(self.termsContainerView)
        
        self.termsContainerView.addSubview(self.termsView)

        self.termsView.addSubview(self.termsTitleLabel)
        self.termsView.addSubview(self.termsToggleButton)

        self.termsContainerView.addSubview(self.termsDescriptionLabel)

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
//            self.stackView.bottomAnchor.constraint(lessThanOrEqualTo: self.containerView.bottomAnchor, constant: -30)
        ])
        
        // Terms
        NSLayoutConstraint.activate([
            self.termsContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.termsContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.termsContainerView.topAnchor.constraint(greaterThanOrEqualTo: self.stackView.bottomAnchor, constant: 20),
//            self.termsContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.termsView.topAnchor.constraint(equalTo: self.termsContainerView.topAnchor),
            self.termsView.centerXAnchor.constraint(equalTo: self.termsContainerView.centerXAnchor),

            self.termsTitleLabel.leadingAnchor.constraint(equalTo: self.termsView.leadingAnchor),
            self.termsTitleLabel.topAnchor.constraint(equalTo: self.termsView.topAnchor, constant: 10),
            self.termsTitleLabel.bottomAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: -10),

            self.termsToggleButton.leadingAnchor.constraint(equalTo: self.termsTitleLabel.trailingAnchor, constant: 5),
            self.termsToggleButton.trailingAnchor.constraint(equalTo: self.termsView.trailingAnchor),
            self.termsToggleButton.heightAnchor.constraint(equalToConstant: 20),
            self.termsToggleButton.centerYAnchor.constraint(equalTo: self.termsTitleLabel.centerYAnchor),

            self.termsDescriptionLabel.leadingAnchor.constraint(equalTo: self.termsContainerView.leadingAnchor),
            self.termsDescriptionLabel.trailingAnchor.constraint(equalTo: self.termsContainerView.trailingAnchor),
            self.termsDescriptionLabel.topAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: 5)
        ])
        
        self.stackViewBottomConstraint =
        NSLayoutConstraint(item: self.stackView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.containerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -20)
        self.stackViewBottomConstraint.isActive = true
        
        self.termsContainerBottomConstraint =
        NSLayoutConstraint(item: self.termsContainerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.containerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -20)
        self.termsContainerBottomConstraint.isActive = false

        self.termsViewBottomConstraint =
        NSLayoutConstraint(item: self.termsView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.termsContainerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        self.termsViewBottomConstraint.isActive = true

        self.termsDescriptionLabelBottomConstraint =
        NSLayoutConstraint(item: self.termsDescriptionLabel,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.termsContainerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        self.termsDescriptionLabelBottomConstraint.isActive = false
    }

}
