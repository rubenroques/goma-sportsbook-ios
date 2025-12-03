//
//  WarningSignsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit
import Combine

class WarningSignsViewController: UIViewController {

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
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
    
    private lazy var warningSignsDescriptionLabel: UILabel = Self.createWarningSignsDescriptionLabel()
    
    private lazy var topic1Label: UILabel = Self.createTopic1Label()
//    private lazy var topic1Button: UIButton = Self.createTopic1Button()
    
    private lazy var topic2Label: UILabel = Self.createTopic2Label()

    private lazy var topic3Label: UILabel = Self.createTopic3Label()

    private lazy var topic4Label: UILabel = Self.createTopic4Label()

    private lazy var topic5Label: UILabel = Self.createTopic5Label()

    private lazy var mottoLabel: UILabel = Self.createMottoLabel()
    
    private lazy var excessiveGamingImageView: UIImageView = Self.createExcessiveGamingImageView()
    private lazy var evalujeuIconImageView: UIImageView = Self.createEvalujeuIconImageView()
    private lazy var minorsImageView: UIImageView = Self.createMinorsImageView()
    private lazy var parentalControlImageView: UIImageView = Self.createParentalControlImageView()
    
    private lazy var parentalControlHighlightTextSectionView: HighlightTextSectionView = {
        let view = HighlightTextSectionView(viewModel: self.viewModel.parentalControlHighlightTextSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var section1TitleLabel: UILabel = Self.createSection1TitleLabel()
    
    private lazy var section1Description1UrlLabel: UILabel = Self.createSection1Description1UrlLabel()
    private lazy var section1Description1Label: UILabel = Self.createSection1Description1Label()

    private lazy var section1Description2UrlLabel: UILabel = Self.createSection1Description2UrlLabel()
    private lazy var section1Description2Label: UILabel = Self.createSection1Description2Label()
    
    private lazy var section1Description3UrlLabel: UILabel = Self.createSection1Description3UrlLabel()
    private lazy var section1Description3Label: UILabel = Self.createSection1Description3Label()

    private lazy var section2TitleLabel: UILabel = Self.createSection2TitleLabel()
    
    private lazy var iosTitleLabel: UILabel = Self.createIosTitleLabel()
    private lazy var iosSubtitleLabel: UILabel = Self.createIosSubtitleLabel()
    
    private lazy var androidTitleLabel: UILabel = Self.createAndroidTitleLabel()
    private lazy var androidSubtitleLabel: UILabel = Self.createAndroidSubtitleLabel()
    
    private lazy var microsoftTitleLabel: UILabel = Self.createMicrosoftTitleLabel()
    private lazy var microsoftSubtitleLabel: UILabel = Self.createMicrosoftSubtitleLabel()
    
    private lazy var macTitleLabel: UILabel = Self.createMacTitleLabel()
    private lazy var macSubtitleLabel: UILabel = Self.createMacSubtitleLabel()
    
    private lazy var section2DescriptionLabel: UILabel = Self.createSection2DescriptionLabel()

    private lazy var section3Title1Label: UILabel = Self.createSection3Title1Label()
    private lazy var section3Title2Label: UILabel = Self.createSection3Title2Label()
    private lazy var section3Title3Label: UILabel = Self.createSection3Title3Label()
    private lazy var section3Title4Label: UILabel = Self.createSection3Title4Label()

    private lazy var section4TitleLabel: UILabel = Self.createSection4TitleLabel()
    private lazy var section4DescriptionLabel: UILabel = Self.createSection4DescriptionLabel()

    private lazy var section5TitleLabel: UILabel = Self.createSection5TitleLabel()

    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private lazy var excessiveGamingImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var excessiveGamingImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var minorsImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var minorsImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    private lazy var parentalControlImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createImageViewFixedHeightConstraint()
    private lazy var parentalControlImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createImageViewDynamicHeightConstraint()
    
    // MARK: - ViewModel
    private let viewModel: WarningSignsViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: WarningSignsViewModel = WarningSignsViewModel()) {
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
        self.setupViewModel()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let evalujeuTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEvalujeuImageView))
        self.evalujeuIconImageView.isUserInteractionEnabled = true
        self.evalujeuIconImageView.addGestureRecognizer(evalujeuTapGesture)
        
        // String links
        let historyTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHistoryLink))
        self.topic1Label.isUserInteractionEnabled = true
        self.topic1Label.addGestureRecognizer(historyTapGesture)
        
        let responsibleGamingTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapResponsibleGamingLink))
        self.topic2Label.isUserInteractionEnabled = true
        self.topic2Label.addGestureRecognizer(responsibleGamingTapGesture)
        
        let limitsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLimitsLink))
        self.topic3Label.isUserInteractionEnabled = true
        self.topic3Label.addGestureRecognizer(limitsTapGesture)
        
        let selfExclusionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelfExclusionLink))
        self.topic4Label.isUserInteractionEnabled = true
        self.topic4Label.addGestureRecognizer(selfExclusionTapGesture)
        
        let gameInterdictionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGameInterdictionLink))
        self.topic5Label.isUserInteractionEnabled = true
        self.topic5Label.addGestureRecognizer(gameInterdictionTapGesture)
        
        let childProtectionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChildProtectionLink))
        self.section1Description1UrlLabel.isUserInteractionEnabled = true
        self.section1Description1UrlLabel.addGestureRecognizer(childProtectionTapGesture)
        
        let eEnfanceTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEEnfanceLink))
        self.section1Description2UrlLabel.isUserInteractionEnabled = true
        self.section1Description2UrlLabel.addGestureRecognizer(eEnfanceTapGesture)
        
        let minorsProtectionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMinorsProtectionLink))
        self.section1Description3UrlLabel.isUserInteractionEnabled = true
        self.section1Description3UrlLabel.addGestureRecognizer(minorsProtectionTapGesture)
        
        let iosTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapIosLink))
        self.iosTitleLabel.isUserInteractionEnabled = true
        self.iosTitleLabel.addGestureRecognizer(iosTapGesture)
        
        let androidTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAndroidLink))
        self.androidTitleLabel.isUserInteractionEnabled = true
        self.androidTitleLabel.addGestureRecognizer(androidTapGesture)
        
        let microsoftTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMicrosoftLink))
        self.microsoftTitleLabel.isUserInteractionEnabled = true
        self.microsoftTitleLabel.addGestureRecognizer(microsoftTapGesture)
        
        let macTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMacLink))
        self.macTitleLabel.isUserInteractionEnabled = true
        self.macTitleLabel.addGestureRecognizer(macTapGesture)
        
        let orangeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOrangeLink))
        self.section3Title1Label.isUserInteractionEnabled = true
        self.section3Title1Label.addGestureRecognizer(orangeTapGesture)
        
        let bouyguesTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBouyguesLink))
        self.section3Title2Label.isUserInteractionEnabled = true
        self.section3Title2Label.addGestureRecognizer(bouyguesTapGesture)
        
        let sfrTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSfrLink))
        self.section3Title3Label.isUserInteractionEnabled = true
        self.section3Title3Label.addGestureRecognizer(sfrTapGesture)
        
        let freeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFreeLink))
        self.section3Title4Label.isUserInteractionEnabled = true
        self.section3Title4Label.addGestureRecognizer(freeTapGesture)
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
    
    func setupViewModel() {
        self.viewModel.onInternalLinkTapped = { [weak self] linkType in
            self?.handleInternalLink(linkType)
        }
    }
    
    // MARK: - Functions
    private func handleInternalLink(_ linkType: InternalLinkType) {
        if self.viewModel.requiresLogin(for: linkType) {
            self.handleInternalLinkWithLoginCheck(linkType)
        } else {
            self.navigateToInternalLink(linkType)
        }
    }
    
    private func handleInternalLinkWithLoginCheck(_ linkType: InternalLinkType) {
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    self?.navigateToInternalLink(linkType)
                }
                else {
                    let loginViewController = LoginViewController()
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.viewModel.handleInternalLink(linkType)
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &self.cancellables)
    }
    
    private func navigateToInternalLink(_ linkType: InternalLinkType) {
        switch linkType {
        case .history:
            let historyViewController = HistoryRootViewController()
            self.navigationController?.pushViewController(historyViewController, animated: true)
            
        case .responsibleGaming:
            let responsibleGameViewController = ResponsibleGameInfoViewController()
            self.navigationController?.pushViewController(responsibleGameViewController, animated: true)
            
        case .limits:
            let limitsViewController = ProfileLimitsManagementViewController()
            self.navigationController?.pushViewController(limitsViewController, animated: true)
            
        case .selfExclusion:
            let selfExclusionViewModel = SelfExclusionViewModel()
            let selfExclusionViewController = SelfExclusionViewController(viewModel: selfExclusionViewModel)
            self.navigationController?.pushViewController(selfExclusionViewController, animated: true)
        }
    }
    
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
    
    @objc private func didTapEvalujeuImageView() {
        if let url = URL(string: self.viewModel.evalujeuImageViewUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapHistoryLink() {
        self.viewModel.handleInternalLink(.history)
    }
    
    @objc private func didTapResponsibleGamingLink() {
        self.viewModel.handleInternalLink(.responsibleGaming)
    }
    
    @objc private func didTapLimitsLink() {
        self.viewModel.handleInternalLink(.limits)
    }
    
    @objc private func didTapSelfExclusionLink() {
        self.viewModel.handleInternalLink(.selfExclusion)
    }
    
    @objc private func didTapGameInterdictionLink() {
        if let url = URL(string: self.viewModel.gameInterdictionLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapChildProtectionLink() {
        if let url = URL(string: self.viewModel.childProtectionLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapEEnfanceLink() {
        if let url = URL(string: self.viewModel.eEnfanceLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapMinorsProtectionLink() {
        if let url = URL(string: self.viewModel.minorsProtectionLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapIosLink() {
        if let url = URL(string: self.viewModel.iosLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapAndroidLink() {
        if let url = URL(string: self.viewModel.androidLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapMicrosoftLink() {
        if let url = URL(string: self.viewModel.microsoftLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapMacLink() {
        if let url = URL(string: self.viewModel.macLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapOrangeLink() {
        if let url = URL(string: self.viewModel.orangeLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapBouyguesLink() {
        if let url = URL(string: self.viewModel.bouyguesLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapSfrLink() {
        if let url = URL(string: self.viewModel.sfrLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapFreeLink() {
        if let url = URL(string: self.viewModel.freeLink) {
            UIApplication.shared.open(url)
        }
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

    private static func createWarningSignsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_1")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createTopic1Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_1_topic_1")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .regular, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createTopic2Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_1_topic_2")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .regular, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createTopic3Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_1_topic_3")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .regular, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createTopic4Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_1_topic_4")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .regular, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createTopic5Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_1_topic_5")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .regular, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
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
    
    private static func createEvalujeuIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "evalujeu_icon")
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
    
    private static func createSection1TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_title_3")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description1UrlLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_3_part_1_url")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description1Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_3_part_1_description")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description2UrlLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_3_part_2_url")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description2Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_3_part_2_description")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description3UrlLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_description_3_part_3_url")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection1Description3Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_3_part_3_description")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection2TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_title_4")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.App.highlightPrimary
        return label
    }
    
    private static func createIosTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_5")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createIosSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_5")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createAndroidTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_6")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createAndroidSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_6")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createMicrosoftTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_7")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createMicrosoftSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_7")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createMacTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_8")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createMacSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_8")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection2DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_9")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3Title1Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_9")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3Title2Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_10")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3Title3Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_11")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection3Title4Label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = localized("warning_signs_page_title_12")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 14),
            .foregroundColor: UIColor.App.highlightPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection4TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_title_13")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection4DescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_description_10")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSection5TitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("warning_signs_page_title_14")
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.App.highlightPrimary
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
        
        self.scrollContainerView.addSubview(self.warningSignsDescriptionLabel)
        
        self.scrollContainerView.addSubview(self.topic1Label)
        self.scrollContainerView.addSubview(self.topic2Label)
        self.scrollContainerView.addSubview(self.topic3Label)
        self.scrollContainerView.addSubview(self.topic4Label)
        self.scrollContainerView.addSubview(self.topic5Label)
        
        self.scrollContainerView.addSubview(self.mottoLabel)
        
        self.scrollContainerView.addSubview(self.excessiveGamingImageView)
        self.scrollContainerView.addSubview(self.evalujeuIconImageView)
        self.scrollContainerView.addSubview(self.minorsImageView)
        self.scrollContainerView.addSubview(self.parentalControlImageView)
        
        self.scrollContainerView.addSubview(self.parentalControlHighlightTextSectionView)
        
        self.scrollContainerView.addSubview(self.section1TitleLabel)

        self.scrollContainerView.addSubview(self.section1Description1UrlLabel)
        self.scrollContainerView.addSubview(self.section1Description1Label)

        self.scrollContainerView.addSubview(self.section1Description2UrlLabel)
        self.scrollContainerView.addSubview(self.section1Description2Label)
        
        self.scrollContainerView.addSubview(self.section1Description3UrlLabel)
        self.scrollContainerView.addSubview(self.section1Description3Label)
        
        self.scrollContainerView.addSubview(self.section2TitleLabel)
        
        self.scrollContainerView.addSubview(self.iosTitleLabel)
        self.scrollContainerView.addSubview(self.iosSubtitleLabel)

        self.scrollContainerView.addSubview(self.androidTitleLabel)
        self.scrollContainerView.addSubview(self.androidSubtitleLabel)

        self.scrollContainerView.addSubview(self.microsoftTitleLabel)
        self.scrollContainerView.addSubview(self.microsoftSubtitleLabel)
        
        self.scrollContainerView.addSubview(self.macTitleLabel)
        self.scrollContainerView.addSubview(self.macSubtitleLabel)
        
        self.scrollContainerView.addSubview(self.section2DescriptionLabel)

        self.scrollContainerView.addSubview(self.section3Title1Label)
        self.scrollContainerView.addSubview(self.section3Title2Label)
        self.scrollContainerView.addSubview(self.section3Title3Label)
        self.scrollContainerView.addSubview(self.section3Title4Label)

        self.scrollContainerView.addSubview(self.section4TitleLabel)
        self.scrollContainerView.addSubview(self.section4DescriptionLabel)

        self.scrollContainerView.addSubview(self.section5TitleLabel)

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
            
            self.topic1Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.topic1Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.topic1Label.topAnchor.constraint(equalTo: self.warningSignsDescriptionLabel.bottomAnchor, constant: 20),
            
            self.topic2Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.topic2Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.topic2Label.topAnchor.constraint(equalTo: self.topic1Label.bottomAnchor, constant: 5),

            self.topic3Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.topic3Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.topic3Label.topAnchor.constraint(equalTo: self.topic2Label.bottomAnchor, constant: 5),
                        
            self.topic4Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.topic4Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.topic4Label.topAnchor.constraint(equalTo: self.topic3Label.bottomAnchor, constant: 5),
            
            self.topic5Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.topic5Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.topic5Label.topAnchor.constraint(equalTo: self.topic4Label.bottomAnchor, constant: 5),
            
            self.mottoLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.mottoLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.mottoLabel.topAnchor.constraint(equalTo: self.topic5Label.bottomAnchor, constant: 20),

            self.excessiveGamingImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.excessiveGamingImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.excessiveGamingImageView.topAnchor.constraint(equalTo: self.mottoLabel.bottomAnchor, constant: 30),
            
            self.evalujeuIconImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.evalujeuIconImageView.topAnchor.constraint(equalTo: self.excessiveGamingImageView.bottomAnchor, constant: 30),

            self.minorsImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.minorsImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.minorsImageView.topAnchor.constraint(equalTo: self.evalujeuIconImageView.bottomAnchor, constant: 30),

            self.parentalControlImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.parentalControlImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.parentalControlImageView.topAnchor.constraint(equalTo: self.minorsImageView.bottomAnchor, constant: 30),
            
            self.parentalControlHighlightTextSectionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor),
            self.parentalControlHighlightTextSectionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor),
            self.parentalControlHighlightTextSectionView.topAnchor.constraint(equalTo: self.parentalControlImageView.bottomAnchor, constant: 10),
//            self.parentalControlHighlightTextSectionView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30),
            
            self.section1TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1TitleLabel.topAnchor.constraint(equalTo: self.parentalControlHighlightTextSectionView.bottomAnchor, constant: 0),
            
            self.section1Description1UrlLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description1UrlLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description1UrlLabel.topAnchor.constraint(equalTo: self.section1TitleLabel.bottomAnchor, constant: 20),
            
            self.section1Description1Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description1Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description1Label.topAnchor.constraint(equalTo: self.section1Description1UrlLabel.bottomAnchor, constant: 10),
            
            self.section1Description2UrlLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description2UrlLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description2UrlLabel.topAnchor.constraint(equalTo: self.section1Description1Label.bottomAnchor, constant: 20),
            
            self.section1Description2Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description2Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description2Label.topAnchor.constraint(equalTo: self.section1Description2UrlLabel.bottomAnchor, constant: 10),
            
            self.section1Description3UrlLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description3UrlLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description3UrlLabel.topAnchor.constraint(equalTo: self.section1Description2Label.bottomAnchor, constant: 20),
            
            self.section1Description3Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section1Description3Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section1Description3Label.topAnchor.constraint(equalTo: self.section1Description3UrlLabel.bottomAnchor, constant: 10),
            
            self.section2TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section2TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section2TitleLabel.topAnchor.constraint(equalTo: self.section1Description3Label.bottomAnchor, constant: 20),
        
            self.iosTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.iosTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.iosTitleLabel.topAnchor.constraint(equalTo: self.section2TitleLabel.bottomAnchor, constant: 20),
            
            self.iosSubtitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.iosSubtitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.iosSubtitleLabel.topAnchor.constraint(equalTo: self.iosTitleLabel.bottomAnchor, constant: 10),
            
            self.androidTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.androidTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.androidTitleLabel.topAnchor.constraint(equalTo: self.iosSubtitleLabel.bottomAnchor, constant: 20),
            
            self.androidSubtitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.androidSubtitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.androidSubtitleLabel.topAnchor.constraint(equalTo: self.androidTitleLabel.bottomAnchor, constant: 10),
            
            self.microsoftTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.microsoftTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.microsoftTitleLabel.topAnchor.constraint(equalTo: self.androidSubtitleLabel.bottomAnchor, constant: 20),
            
            self.microsoftSubtitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.microsoftSubtitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.microsoftSubtitleLabel.topAnchor.constraint(equalTo: self.microsoftTitleLabel.bottomAnchor, constant: 10),
            
            self.macTitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.macTitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.macTitleLabel.topAnchor.constraint(equalTo: self.microsoftSubtitleLabel.bottomAnchor, constant: 20),
            
            self.macSubtitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.macSubtitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.macSubtitleLabel.topAnchor.constraint(equalTo: self.macTitleLabel.bottomAnchor, constant: 10),
            
            self.section2DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section2DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section2DescriptionLabel.topAnchor.constraint(equalTo: self.macSubtitleLabel.bottomAnchor, constant: 20),
            
            self.section3Title1Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section3Title1Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section3Title1Label.topAnchor.constraint(equalTo: self.section2DescriptionLabel.bottomAnchor, constant: 20),
            
            self.section3Title2Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section3Title2Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section3Title2Label.topAnchor.constraint(equalTo: self.section3Title1Label.bottomAnchor, constant: 10),
            
            self.section3Title3Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section3Title3Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section3Title3Label.topAnchor.constraint(equalTo: self.section3Title2Label.bottomAnchor, constant: 10),
            
            self.section3Title4Label.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section3Title4Label.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section3Title4Label.topAnchor.constraint(equalTo: self.section3Title3Label.bottomAnchor, constant: 10),
            
            self.section4TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section4TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section4TitleLabel.topAnchor.constraint(equalTo: self.section3Title4Label.bottomAnchor, constant: 20),
            
            self.section4DescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section4DescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section4DescriptionLabel.topAnchor.constraint(equalTo: self.section4TitleLabel.bottomAnchor, constant: 20),
            
            self.section5TitleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 30),
            self.section5TitleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -30),
            self.section5TitleLabel.topAnchor.constraint(equalTo: self.section4DescriptionLabel.bottomAnchor, constant: 20),
            self.section5TitleLabel.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -30)
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
