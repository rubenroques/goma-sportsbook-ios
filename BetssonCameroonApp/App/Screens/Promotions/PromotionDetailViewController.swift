//
//  PromotionDetailViewController.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import UIKit
import Combine
import ServicesProvider
import GomaUI
import Kingfisher

class PromotionDetailViewModel {
    
    var promotion: PromotionInfo
    
    var promotionDetailsPublisher: CurrentValueSubject<PromotionInfo?, Never> = .init(nil)
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    private let servicesProvider: ServicesProvider.Client
    
    init(promotion: PromotionInfo, servicesProvider: ServicesProvider.Client) {
        self.promotion = promotion
        self.servicesProvider = servicesProvider
        
        self.getPromotionDetails()
    }
    
    private func getPromotionDetails() {
        self.isLoadingPublisher.send(true)
        
        if let staticPageSlug = promotion.staticPageSlug {
            servicesProvider.getPromotionDetails(promotionSlug: self.promotion.slug, staticPageSlug: staticPageSlug)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        print("FINISHED GET PROMOTION DETAILS")
                    case .failure(let error):
                        print("ERROR GET PROMOTION DETAILS: \(error)")
                    }
                    
                    self?.isLoadingPublisher.send(false)

                }, receiveValue: { [weak self] promotionsInfo in
                    
                    self?.promotionDetailsPublisher.send(promotionsInfo)
                                        
                })
                .store(in: &cancellables)
        }
    }
}

class PromotionDetailViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var gradientHeaderView: GradientHeaderView = Self.createGradientHeaderView()
    private lazy var headerImageView: UIImageView = Self.createHeaderImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var termsContainerView: UIView = Self.createTermsContainerView()
    private lazy var termsView: UIView = Self.createTermsView()
    private lazy var termsTitleLabel: UILabel = Self.createTermsTitleLabel()
    private lazy var termsToggleButton: UIButton = Self.createTermsToggleButton()
    private lazy var termsDescriptionLabel: UILabel = Self.createTermsDescriptionLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
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
                self.termsToggleButton.setImage(UIImage(named: "chevron_down_icon"), for: .normal)

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.termsDescriptionLabel.alpha = 0
                }, completion: { _ in
                    self.termsDescriptionLabel.isHidden = true
                })
                self.termsViewBottomConstraint.isActive = true
                self.termsDescriptionLabelBottomConstraint.isActive = false

            }
            else {
                self.termsToggleButton.setImage(UIImage(named: "chevron_up_icon"), for: .normal)

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
    
    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateBaseView.isHidden = !isEmptyState
        }
    }
    
    var disabledAlpha: CGFloat = 0.7
    var enabledAlpha: CGFloat = 1.0
    
    var cancellables = Set<AnyCancellable>()

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
        
        self.bind(toViewModel: self.viewModel)
        
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = StyleProvider.Color.highlightPrimaryContrast
        
        self.topSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.bottomSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary

        self.navigationView.backgroundColor = StyleProvider.Color.backgroundPrimary

        self.titleLabel.textColor = StyleProvider.Color.allWhite

        self.headerImageView.backgroundColor = .clear
        
        self.stackView.backgroundColor = .clear
        
        self.termsContainerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        
        self.emptyStateBaseView.backgroundColor = StyleProvider.Color.backgroundTertiary

        self.emptyStateLabel.textColor = StyleProvider.Color.textPrimary
        
        self.loadingBaseView.backgroundColor = StyleProvider.Color.backgroundPrimary

    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: PromotionDetailViewModel) {
        
        viewModel.promotionDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] promotionInfo in
                
                if let promotionInfo {
                    
                    self?.setupHeader(promotionInfo: promotionInfo)
                    
                    if let staticPage = promotionInfo.staticPage {
                        self?.setupSections(staticPage: staticPage)
                        
                    }
                    
                    self?.isEmptyState = false
                    
                }
                else {
                    self?.isEmptyState = true
                }
                
            })
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                self?.loadingBaseView.isHidden = !isLoading
            })
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    private func setupHeader(promotionInfo: PromotionInfo) {
        
        self.titleLabel.text = promotionInfo.title
        
        if let headerTitle = promotionInfo.staticPage?.title {
            let mockViewModel = MockGradientHeaderViewModel(title: headerTitle, gradientColors: [(UIColor.App.boostedOddsGradient1, NSNumber(0.0)),
                                                                                                 (UIColor.App.boostedOddsGradient2, NSNumber(1.0))])
            self.gradientHeaderView.configure(viewModel: mockViewModel)
        }
        
        if let headerImageName = promotionInfo.staticPage?.headerImageUrl,
           let headerUrl = URL(string: headerImageName){
            self.headerImageView.kf.setImage(with: headerUrl)
        }
        
        self.gradientHeaderView.isHidden = promotionInfo.staticPage?.title != nil ? false : true
        
        self.headerImageView.isHidden = promotionInfo.staticPage?.headerImageUrl != nil ? false : true

    }
    
    private func setupSections(staticPage: StaticPage) {
        
        for sectionBlock in staticPage.sections {
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.backgroundColor = .clear
            
            if sectionBlock.type == .text {
                
                if let textBlock = sectionBlock.text {
                    
                    var blockViews = [UIView]()
                    
                    for textContentBlock in textBlock.contentBlocks {
                        
                        if textContentBlock.blockType == .title {
                            let mockViewModel = MockTitleBlockViewModel(title: textContentBlock.title ?? "")
                            let titleBlockView = TitleBlockView(viewModel: mockViewModel)
                            titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                            
                            blockViews.append(titleBlockView)
                        }
                        else if textContentBlock.blockType == .description {
                            let mockViewModel = MockDescriptionBlockViewModel(description: textContentBlock.description ?? "")
                            let descriptionBlockView = DescriptionBlockView(viewModel: mockViewModel)
                            descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
                            
                            blockViews.append(descriptionBlockView)

                        }
                        else if textContentBlock.blockType == .image {
                            let mockViewModel = MockImageBlockViewModel(imageUrl: textContentBlock.image ?? "")
                            let imageBlockView = ImageBlockView(viewModel: mockViewModel)
                            imageBlockView.translatesAutoresizingMaskIntoConstraints = false
                            
                            blockViews.append(imageBlockView)

                        }
                        else if textContentBlock.blockType == .video {
                            let mockViewModel = MockVideoBlockViewModel(videoURL: URL(string: textContentBlock.video ?? ""))
                            let videoBlockView = VideoBlockView(viewModel: mockViewModel)
                            videoBlockView.translatesAutoresizingMaskIntoConstraints = false
                            
                            blockViews.append(videoBlockView)
                        }
                        else if textContentBlock.blockType == .button {
                            let mockViewModel = MockActionButtonBlockViewModel(title: textContentBlock.buttonText ?? "", actionName: textContentBlock.buttonURL ?? "")
//                            mockViewModel.didTapActionButton = { [weak self] in
//                                self?.openAction(actionName: textContentBlock.buttonURL ?? "")
//                            }
                            let actionButtonBlockView = ActionButtonBlockView(viewModel: mockViewModel)
                            actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
                            
                            blockViews.append(actionButtonBlockView)
                        }
                        else if textContentBlock.blockType == .bulletedList {
                            
                            if let bulletedListItems = textContentBlock.bulletedListItems {
                                
                                for bulletedListItem in bulletedListItems {
                                    
                                    let mockViewModel = MockBulletItemBlockViewModel(title: bulletedListItem.text)
                                    let bulletedItemBlock = BulletItemBlockView(viewModel: mockViewModel)
                                    bulletedItemBlock.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    blockViews.append(bulletedItemBlock)
                                }
                                
                            }
                        }
                    }
                    
                    let stackViewBlockViewModel = MockStackViewBlockViewModel(views: blockViews)
                    let stackViewBlockView = StackViewBlockView(viewModel: stackViewBlockViewModel)
                    stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
                    
                    stackView.addArrangedSubview(stackViewBlockView)
                }
            }
            else if sectionBlock.type == .list {
                
                if let listBlock = sectionBlock.list {
                    
                    var blockViews = [UIView]()
                    
                    if let title = listBlock.title {
                        let mockViewModel = MockTitleBlockViewModel(title: title, isCentered: false)
                        let titleBlockView = TitleBlockView(viewModel: mockViewModel)
                        titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                        
                        blockViews.append(titleBlockView)
                    }
                    
                    for (index, itemBlock) in listBlock.items.enumerated() {
                        
                        var listItemViews = [UIView]()
                        
                        var itemIconName = listBlock.genericListItemsIcon
                        
                        if let itemBlockIconName = itemBlock.itemIcon {
                            itemIconName = itemBlockIconName
                        }
                        
                        for textContentBlock in itemBlock.contentBlocks {
                            
                            if textContentBlock.blockType == .title {
                                let mockViewModel = MockTitleBlockViewModel(title: textContentBlock.title ?? "", isCentered: false)
                                let titleBlockView = TitleBlockView(viewModel: mockViewModel)
                                titleBlockView.translatesAutoresizingMaskIntoConstraints = false
                                
                                listItemViews.append(titleBlockView)
                            }
                            else if textContentBlock.blockType == .description {
                                let mockViewModel = MockDescriptionBlockViewModel(description: textContentBlock.description ?? "")
                                let descriptionBlockView = DescriptionBlockView(viewModel: mockViewModel)
                                descriptionBlockView.translatesAutoresizingMaskIntoConstraints = false
                                
                                listItemViews.append(descriptionBlockView)

                            }
                            else if textContentBlock.blockType == .image {
                                let mockViewModel = MockImageBlockViewModel(imageUrl: textContentBlock.image ?? "")
                                let imageBlockView = ImageBlockView(viewModel: mockViewModel)
                                imageBlockView.translatesAutoresizingMaskIntoConstraints = false
                                
                                listItemViews.append(imageBlockView)

                            }
                            else if textContentBlock.blockType == .video {
                                let mockViewModel = MockVideoBlockViewModel(videoURL: URL(string: textContentBlock.video ?? ""))
                                let videoBlockView = VideoBlockView(viewModel: mockViewModel)
                                videoBlockView.translatesAutoresizingMaskIntoConstraints = false
                                
                                listItemViews.append(videoBlockView)
                            }
                            else if textContentBlock.blockType == .button {
                                let mockViewModel = MockActionButtonBlockViewModel(title: textContentBlock.buttonText ?? "", actionName: textContentBlock.buttonURL ?? "")
//                                mockViewModel.didTapActionButton = { [weak self] in
//                                    self?.openAction(actionName: textContentBlock.buttonURL ?? "")
//                                }
                                let actionButtonBlockView = ActionButtonBlockView(viewModel: mockViewModel)
                                actionButtonBlockView.translatesAutoresizingMaskIntoConstraints = false
                                
                                listItemViews.append(actionButtonBlockView)
                            }
                            else if textContentBlock.blockType == .bulletedList {
                                
                                if let bulletedListItems = textContentBlock.bulletedListItems {
                                    
                                    for bulletedListItem in bulletedListItems {
                                        
                                        let mockViewModel = MockBulletItemBlockViewModel(title: bulletedListItem.text)
                                        let bulletedItemBlock = BulletItemBlockView(viewModel: mockViewModel)
                                        bulletedItemBlock.translatesAutoresizingMaskIntoConstraints = false
                                        
                                        listItemViews.append(bulletedItemBlock)
                                    }
                                    
                                }
                            }
                        }
                        
                        var counterString = itemIconName != nil ? nil : "\(index + 1)"
                        
                        let listBlockViewModel = MockListBlockViewModel(iconUrl: itemIconName ?? "", counter: counterString, views: listItemViews)
                        let listBlockView = ListBlockView(viewModel: listBlockViewModel)
                        listBlockView.translatesAutoresizingMaskIntoConstraints = false
                        
                        blockViews.append(listBlockView)
                    }
                    
                    let stackViewBlockViewModel = MockStackViewBlockViewModel(views: blockViews)
                    let stackViewBlockView = StackViewBlockView(viewModel: stackViewBlockViewModel)
                    stackViewBlockView.translatesAutoresizingMaskIntoConstraints = false
                    
                    stackView.addArrangedSubview(stackViewBlockView)

                }
            }
            else if sectionBlock.type == .banner {
                
                if let listBlock = sectionBlock.banner {
                    
                    if listBlock.bannerType == .image {
                        let mockViewModel = MockImageSectionViewModel(imageUrl: listBlock.imageUrl ?? "")
                        let imageSectionView = ImageSectionView(viewModel: mockViewModel)
                        imageSectionView.translatesAutoresizingMaskIntoConstraints = false
                        
                        stackView.addArrangedSubview(imageSectionView)
                    }
                    else if listBlock.bannerType == .video {
                        let mockViewModel = MockVideoSectionViewModel(videoURL: URL(string: listBlock.bannerLinkUrl ?? ""))
                        let videoSectionView = VideoSectionView(viewModel: mockViewModel)
                        videoSectionView.translatesAutoresizingMaskIntoConstraints = false
                        
                        stackView.addArrangedSubview(videoSectionView)
                    }
                }
            }
            
            self.stackView.addArrangedSubview(stackView)

        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
        
        if let terms = staticPage.terms {
            self.setupTerms(terms: terms)
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
    
    private func setupTerms(terms: TermItem) {
        
        let label = self.termsDescriptionLabel
        
        if terms.displayType == .bulletedList,
           let listItem = terms.bulletedListItems {
            var termsText = ""
            
            for item in listItem {
                termsText.append("• \(item.text)\n")
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
        else if terms.displayType == .richText {
            self.setupAttributedText(text: terms.richText ?? "", label: label)
        }
    }
    
    private func setupAttributedText(text: String, label: UILabel) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 2
        
        // Apply base attributes
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor.App.textPrimary,
                                    range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font,
                                    value: AppFont.with(type: .regular, size: 14),
                                    range: NSRange(location: 0, length: text.count))
        
        // Find and style links in format [TEXT](URL)
        let pattern = "\\[(.*?)\\]\\((.*?)\\)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Process matches in reverse to avoid invalidating ranges
            for match in matches.reversed() {
                let fullRange = match.range
                let textRange = match.range(at: 1)
                let urlRange = match.range(at: 2)
                
                let linkText = nsString.substring(with: textRange)
                let urlString = nsString.substring(with: urlRange)
                
                // Replace the [TEXT](URL) with just TEXT
                attributedString.replaceCharacters(in: fullRange, with: linkText)
                
                // Style the link text
                let linkRange = NSRange(location: fullRange.location, length: linkText.count)
                attributedString.addAttribute(.foregroundColor,
                                           value: UIColor.App.highlightPrimary,
                                           range: linkRange)
                attributedString.addAttribute(.font,
                                           value: AppFont.with(type: .bold, size: 14),
                                           range: linkRange)
                attributedString.addAttribute(.link,
                                           value: urlString,
                                           range: linkRange)
            }
        }
        
        attributedString.addAttribute(.paragraphStyle,
                                    value: paragraphStyle,
                                    range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer if not already added
        if label.gestureRecognizers?.contains(where: { $0 is UITapGestureRecognizer }) != true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:)))
            label.addGestureRecognizer(tapGesture)
        }
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
    
    @objc private func handleTapOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let attributedText = label.attributedText else { return }
        
        // Create text storage, layout manager, and text container
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure text container
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Get touch location
        let locationOfTouchInLabel = gesture.location(in: label)
        
        // Account for text alignment and line spacing
        let textBoundingRect = layoutManager.usedRect(for: textContainer)
        
        // Calculate vertical offset based on label's content alignment
        var textOffset = CGPoint.zero
        
        // Adjust for vertical alignment
        let labelHeight = label.bounds.height
        if textBoundingRect.height < labelHeight {
            textOffset.y = (labelHeight - textBoundingRect.height) * 0.5
        }
        
        // Adjust for horizontal alignment (text alignment)
        let labelWidth = label.bounds.width
        if textBoundingRect.width < labelWidth {
            switch label.textAlignment {
            case .center:
                textOffset.x = (labelWidth - textBoundingRect.width) * 0.5
            case .right:
                textOffset.x = labelWidth - textBoundingRect.width
            default:
                break
            }
        }
        
        // Apply the offset to get the correct touch location in text container coordinates
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textOffset.x,
            y: locationOfTouchInLabel.y - textOffset.y
        )
        
        // Get the character index at touch location
        let characterIndex = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if the touch is within the bounds of the text
        if characterIndex < textStorage.length {
            // Find URL attribute at the touch location
            attributedText.enumerateAttribute(.link,
                                            in: NSRange(location: 0, length: attributedText.length)) { value, range, stop in
                if NSLocationInRange(characterIndex, range),
                   let urlString = value as? String,
                   let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                    stop.pointee = true
                }
            }
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
        titleLabel.font = AppFont.with(type: .bold, size: 32)
        titleLabel.textAlignment = .center
        titleLabel.text = "Promotion Details"
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
        let mockViewModel = MockGradientHeaderViewModel.defaultMock
        let gradientHeaderView = GradientHeaderView(viewModel: mockViewModel)
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
        label.font = AppFont.with(type: .bold, size: 24)
        label.text = "Terms and Conditions"
        label.textAlignment = .left
        return label
    }

    private static func createTermsToggleButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "chevron_down_icon"), for: .normal)
        button.imageView?.setTintColor(color: StyleProvider.Color.highlightPrimary)
        return button
    }

    private static func createTermsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }
    
    private static func createEmptyStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_tickets_logged_off_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Promotion not found"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
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
        
        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.gradientHeaderView)
        self.containerView.addSubview(self.headerImageView)
        
        self.headerImageView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.stackView)
        
        self.containerView.addSubview(self.termsContainerView)
        
        self.termsContainerView.addSubview(self.termsView)

        self.termsView.addSubview(self.termsTitleLabel)
        self.termsView.addSubview(self.termsToggleButton)

        self.termsContainerView.addSubview(self.termsDescriptionLabel)
        
        self.view.addSubview(self.emptyStateBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

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
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

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
            self.gradientHeaderView.heightAnchor.constraint(equalToConstant: 257),
            
            self.headerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.headerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.headerImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.headerImageView.heightAnchor.constraint(equalToConstant: 257),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.headerImageView.leadingAnchor, constant: 32),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.headerImageView.trailingAnchor, constant: -32),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.headerImageView.centerYAnchor, constant: 25),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.gradientHeaderView.bottomAnchor, constant: -60),
        ])
        
        // Terms
        NSLayoutConstraint.activate([
            self.termsContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.termsContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.termsContainerView.topAnchor.constraint(greaterThanOrEqualTo: self.stackView.bottomAnchor, constant: 20),

            self.termsView.topAnchor.constraint(equalTo: self.termsContainerView.topAnchor),
            self.termsView.leadingAnchor.constraint(equalTo: self.termsContainerView.leadingAnchor, constant: 16),
            self.termsView.trailingAnchor.constraint(equalTo: self.termsContainerView.trailingAnchor, constant: -16),
//            self.termsView.centerXAnchor.constraint(equalTo: self.termsContainerView.centerXAnchor),

            self.termsTitleLabel.leadingAnchor.constraint(equalTo: self.termsView.leadingAnchor),
            self.termsTitleLabel.topAnchor.constraint(equalTo: self.termsView.topAnchor, constant: 10),
            self.termsTitleLabel.bottomAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: -10),

//            self.termsToggleButton.leadingAnchor.constraint(equalTo: self.termsTitleLabel.trailingAnchor, constant: 5),
            self.termsToggleButton.trailingAnchor.constraint(equalTo: self.termsView.trailingAnchor),
            self.termsToggleButton.heightAnchor.constraint(equalToConstant: 20),
            self.termsToggleButton.centerYAnchor.constraint(equalTo: self.termsTitleLabel.centerYAnchor),

            self.termsDescriptionLabel.leadingAnchor.constraint(equalTo: self.termsContainerView.leadingAnchor, constant: 16),
            self.termsDescriptionLabel.trailingAnchor.constraint(equalTo: self.termsContainerView.trailingAnchor, constant: -16),
            self.termsDescriptionLabel.topAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: 5)
        ])
        
        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateBaseView.topAnchor, constant: 45),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateBaseView.leadingAnchor, constant: 35),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateBaseView.trailingAnchor, constant: -35),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24)
        ])
        
        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
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
                           constant: 0)
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
