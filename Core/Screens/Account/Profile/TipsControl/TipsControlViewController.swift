//
//  TipsControlViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import UIKit
import OptimoveSDK
import Adjust

class TipsControlViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var textLabel: UILabel = Self.createTextLabel()
    private lazy var accordionView: UIView = Self.createAccordionView()
    
    private lazy var accordionFirstSectionBaseView: UIView = Self.createAccordionFirstSectionBaseView()
    private lazy var accordionFirstTextSectionView: TextSectionView = Self.createAccordionFirstTextSectionView()
    private lazy var accordionFirstSectionDescriptionView: UIView = Self.createAccordionFirstSectionDescriptionView()
    private lazy var accordionFirstSectionDescriptionLabel1: UILabel = Self.createAccordionFirstSectionDescriptionLabel1()
    private lazy var accordionFirstSectionDescriptionListLabel: UILabel = Self.createAccordionFirstSectionDescriptionListLabel()
    private lazy var accordionFirstSectionDescriptionLabel2: UILabel = Self.createAccordionFirstSectionDescriptionLabel2()
    
    private lazy var accordionSecondSectionBaseView: UIView = Self.createAccordionSecondSectionBaseView()
    private lazy var accordionSecondTextSectionView: TextSectionView = Self.createAccordionSecondTextSectionView()
    private lazy var accordionSecondSectionDescriptionView: UIView = Self.createAccordionSecondSectionDescriptionView()
    private lazy var accordionSecondSectionSubsectionView1: TextSubsectionView = Self.createAccordionSecondSectionSubsectionView1()
    private lazy var accordionSecondSectionDescriptionLabel1: UILabel = Self.createAccordionSecondSectionDescriptionLabel1()
    private lazy var accordionSecondSectionDescriptionListLabel: UILabel = Self.createAccordionSecondSectionDescriptionListLabel()
    private lazy var accordionSecondSectionSubsectionView2: TextSubsectionView = Self.createAccordionSecondSectionSubsectionView2()
    private lazy var accordionSecondSectionDescriptionLabel2: UILabel = Self.createAccordionSecondSectionDescriptionLabel2()

    private lazy var accordionThirdSectionBaseView: UIView = Self.createAccordionThirdSectionBaseView()
    private lazy var accordionThirdTextSectionView: TextSectionView = Self.createAccordionThirdTextSectionView()
    private lazy var accordionThirdSectionDescriptionView: UIView = Self.createAccordionThirdSectionDescriptionView()
    private lazy var accordionThirdSectionDescriptionLabel: UILabel = Self.createAccordionThirdSectionDescriptionLabel()
    private lazy var accordionThirdSectionDescriptionListLabel: UILabel = Self.createAccordionThirdSectionDescriptionListLabel()
    
    private lazy var accordionFourthSectionBaseView: UIView = Self.createAccordionFourthSectionBaseView()
    private lazy var accordionFourthTextSectionView: TextSectionView = Self.createAccordionFourthTextSectionView()
    private lazy var accordionFourthSectionDescriptionView: UIView = Self.createAccordionFourthSectionDescriptionView()
    private lazy var accordionFourthSectionDescriptionLabel1: UILabel = Self.createAccordionFourthSectionDescriptionLabel1()
    private lazy var accordionFourthSectionDescriptionListLabel: UILabel = Self.createAccordionFourthSectionDescriptionListLabel()
    private lazy var accordionFourthSectionDescriptionLabel2: UILabel = Self.createAccordionFourthSectionDescriptionLabel2()

    //private lazy var tipButton: UIButton = Self.createTipButton()
    private lazy var logo1ImageView: UIImageView = Self.createLogo1ImageView()
    private lazy var logo2ImageView: UIImageView = Self.createLogo2ImageView()
    private lazy var logo3ImageView: UIImageView = Self.createLogo3ImageView()
    
    // Constraints
    private lazy var firstSectionDescriptionHeightConstraint: NSLayoutConstraint = Self.createFirstSectionDescriptionHeightConstraint()
    private lazy var secondSectionDescriptionHeightConstraint: NSLayoutConstraint = Self.createSecondSectionDescriptionHeightConstraint()
    private lazy var thirdSectionDescriptionHeightConstraint: NSLayoutConstraint = Self.createThirdSectionDescriptionHeightConstraint()
    private lazy var fourthSectionDescriptionHeightConstraint: NSLayoutConstraint = Self.createFourthSectionDescriptionHeightConstraint()
    
    // MARK: Lifetime and Cycle
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

//        self.tipButton.addTarget(self, action: #selector(didTapTipButton), for: .touchUpInside)
        
        self.setupCallbacks()
        
        self.accordionFirstSectionDescriptionLabel2.isUserInteractionEnabled = true
        self.accordionFirstSectionDescriptionLabel2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapFirstSectionLabel(_:))))
        
        self.accordionSecondSectionDescriptionLabel2.isUserInteractionEnabled = true
        self.accordionSecondSectionDescriptionLabel2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapSecondSectionLabel(_:))))
        
        self.accordionThirdSectionDescriptionListLabel.isUserInteractionEnabled = true
        self.accordionThirdSectionDescriptionListLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapThirdSectionLabel(_:))))
        
        self.accordionFourthSectionDescriptionLabel2.isUserInteractionEnabled = true
        self.accordionFourthSectionDescriptionLabel2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapFourthSectionLabel(_:))))
        
        let logo1Gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapLogo1(_:)))
        self.logo1ImageView.isUserInteractionEnabled = true
        self.logo1ImageView.addGestureRecognizer(logo1Gesture)
        
        let logo2Gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapLogo2(_:)))
        self.logo2ImageView.isUserInteractionEnabled = true
        self.logo2ImageView.addGestureRecognizer(logo2Gesture)
        
        let logo3Gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapLogo3(_:)))
        self.logo3ImageView.isUserInteractionEnabled = true
        self.logo3ImageView.addGestureRecognizer(logo3Gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.accordionView.layer.cornerRadius = CornerRadius.view

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.textLabel.textColor = UIColor.App.textPrimary

        self.accordionView.backgroundColor = .clear
        
        self.accordionView.layer.borderColor = UIColor.App.textPrimary.cgColor
        
        self.accordionFirstSectionBaseView.backgroundColor = .clear
        
        self.accordionFirstSectionDescriptionView.backgroundColor = .clear
                
        self.accordionSecondSectionBaseView.backgroundColor = .clear
        
        self.accordionSecondSectionDescriptionView.backgroundColor = .clear
        
        self.accordionThirdSectionBaseView.backgroundColor = .clear
        
        self.accordionThirdSectionDescriptionView.backgroundColor = .clear
        
        self.accordionFourthSectionBaseView.backgroundColor = .clear
        
        self.accordionFourthSectionDescriptionView.backgroundColor = .clear
        
        self.logo1ImageView.backgroundColor = .clear
        self.logo2ImageView.backgroundColor = .clear
        self.logo3ImageView.backgroundColor = .clear
        
//        self.tipButton.backgroundColor = .clear
//        self.tipButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
    }
    
    // MARK: Functions
    private func setupCallbacks() {
        
        self.accordionFirstTextSectionView.didTappedArrow = { [weak self] isCollapsed in
                        
            UIView.animate(withDuration: 0.5) {
                self?.firstSectionDescriptionHeightConstraint.isActive = isCollapsed ? false : true
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            
        }
        
        self.accordionSecondTextSectionView.didTappedArrow = { [weak self] isCollapsed in
                        
            UIView.animate(withDuration: 0.5) {
                self?.secondSectionDescriptionHeightConstraint.isActive = isCollapsed ? false : true
                
                self?.accordionSecondSectionSubsectionView1.isHidden = isCollapsed ? false : true
                self?.accordionSecondSectionSubsectionView2.isHidden = isCollapsed ? false : true
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            
        }
        
        self.accordionThirdTextSectionView.didTappedArrow = { [weak self] isCollapsed in
                        
            UIView.animate(withDuration: 0.5) {
                self?.thirdSectionDescriptionHeightConstraint.isActive = isCollapsed ? false : true

                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            
        }
        
        self.accordionFourthTextSectionView.didTappedArrow = { [weak self] isCollapsed in
                        
            UIView.animate(withDuration: 0.5) {
                self?.fourthSectionDescriptionHeightConstraint.isActive = isCollapsed ? false : true

                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            
        }
    }
    
    @objc private func didTapFirstSectionLabel(_ sender: UITapGestureRecognizer) {
        let link1Range = (localized("tips_control_first_section_text_2") as NSString).range(of: "Evalujeu")
        
        if sender.didTapAttributedTextInLabel(label: self.accordionFirstSectionDescriptionLabel2, inRange: link1Range, alignment: .left) {
            print("TAPPED FIRST SECTION 1")
            if let url = URL(string: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent") {
                UIApplication.shared.open(url)
            }
        
        }
       
    }
    
    @objc private func didTapSecondSectionLabel(_ sender: UITapGestureRecognizer) {
        let link1Range = (localized("responsible_gaming_second_section_text_2") as NSString).range(of: "SOS joueur")
                
        if sender.didTapAttributedTextInLabel(label: self.accordionSecondSectionDescriptionLabel2, inRange: link1Range, alignment: .left) {
            if let url = URL(string: "https://sosjoueurs.org/") {
                UIApplication.shared.open(url)
            }
        }

    }
    
    @objc private func didTapThirdSectionLabel(_ sender: UITapGestureRecognizer) {
        let link1Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://sosjoueurs.org/")
        let link2Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://gamban.com/fr/")
        let link3Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent")
        let link4Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1")
        let link5Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html")
        let link6Range = (localized("tips_control_third_section_list") as NSString).range(of: "https://www.joueurs-info-service.fr/")
        
        if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link1Range, alignment: .left) {
            if let url = URL(string: "https://sosjoueurs.org/") {
                // Firebase Analytics
                AnalyticsClient.sendEvent(event: .sosPlayers)

                // Optimove
                Optimove.shared.reportEvent(name: "sos_joueur_click")

                // Adjust
                let event = ADJEvent(eventToken: "9t3uav")
                Adjust.trackEvent(event)
                
                UIApplication.shared.open(url)
            }
        }
        else if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link2Range, alignment: .left) {
            if let url = URL(string: "https://gamban.com/fr/") {
                UIApplication.shared.open(url)
            }
        }
        else if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link3Range, alignment: .left) {
            if let url = URL(string: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent") {
                UIApplication.shared.open(url)
            }
        }
        else if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link4Range, alignment: .left) {
            if let url = URL(string: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1") {
                UIApplication.shared.open(url)
            }
        }
        else if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link5Range, alignment: .left) {
            if let url = URL(string: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html") {
                UIApplication.shared.open(url)
            }
        }
        else if sender.didTapAttributedTextInLabel(label: self.accordionThirdSectionDescriptionListLabel, inRange: link6Range, alignment: .left) {
            if let url = URL(string: "https://www.joueurs-info-service.fr/") {
                
                // Firebase Analytics
                AnalyticsClient.sendEvent(event: .playersInfo)

                // Optimove
                Optimove.shared.reportEvent(name: "joueurs_info_service_click")

                // Adjust
                let event = ADJEvent(eventToken: "piroso")
                Adjust.trackEvent(event)
                
                UIApplication.shared.open(url)
            }
        }

    }
    
    @objc private func didTapFourthSectionLabel(_ sender: UITapGestureRecognizer) {
        let link1Range = (localized("tips_control_fourth_section_text_2") as NSString).range(of: "ANJ")
                
        if sender.didTapAttributedTextInLabel(label: self.accordionFourthSectionDescriptionLabel2, inRange: link1Range, alignment: .left) {
            if let url = URL(string: "https://anj.fr/") {
                UIApplication.shared.open(url)
            }
        }

    }
    
    @objc private func didTapLogo1(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://sosjoueurs.org/") {
            
            // Firebase Analytics
            AnalyticsClient.sendEvent(event: .sosPlayers)

            // Optimove
            Optimove.shared.reportEvent(name: "sos_joueur_click")

            // Adjust
            let event = ADJEvent(eventToken: "9t3uav")
            Adjust.trackEvent(event)
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapLogo2(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://www.evalujeu.fr/") {
            
            // Firebase Analytics
            AnalyticsClient.sendEvent(event: .evaluejeu)

            // Optimove
            Optimove.shared.reportEvent(name: "evalujeu_click")

            // Adjust
            let event = ADJEvent(eventToken: "43y8ai")
            Adjust.trackEvent(event)
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapLogo3(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://anj.fr/") {
            UIApplication.shared.open(url)
        }
    }
}

//
// MARK: - Actions
//
extension TipsControlViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTipButton() {
        if let url = URL(string: "https://www.evalujeu.fr/") {
            UIApplication.shared.open(url)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension TipsControlViewController {

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
        label.text = localized("tips_to_keep_control")
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tips_control_title")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tips_control_description")
        label.font = AppFont.with(type: .semibold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_description")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_description"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 16), range: fullRange)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        return label
    }
    
    private static func createAccordionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }
    
    private static func createAccordionFirstSectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionFirstTextSectionView() -> TextSectionView {
        let view = TextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_first_section_title"), icon: "roman_1_icon")
        
        return view
    }
    
    private static func createAccordionFirstSectionDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionFirstSectionDescriptionLabel1() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_first_section_text_1")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_first_section_text_1"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        return label
    }
    
    private static func createAccordionFirstSectionDescriptionListLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_first_section_list")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_first_section_list"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 15
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionFirstSectionDescriptionLabel2() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_first_section_text_2")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_first_section_text_2"))
        
        let range1 = (fullText as NSString).range(of: "Evalujeu")
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionSecondSectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionSecondTextSectionView() -> TextSectionView {
        let view = TextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_second_section_title"), icon: "roman_2_icon")
        
        return view
    }
    
    private static func createAccordionSecondSectionDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionSecondSectionSubsectionView1() -> TextSubsectionView {
        let view = TextSubsectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_second_subsection_title_1"), icon: "arrow_section_icon")
        view.isHidden = true
        return view
    }
    
    private static func createAccordionSecondSectionDescriptionLabel1() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_second_section_text_1")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_second_section_text_1"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        return label
    }
    
    private static func createAccordionSecondSectionDescriptionListLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_second_section_list")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_second_section_list"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 15
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionSecondSectionSubsectionView2() -> TextSubsectionView {
        let view = TextSubsectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_second_subsection_title_2"), icon: "arrow_section_icon")
        view.isHidden = true
        return view
    }
    
    private static func createAccordionSecondSectionDescriptionLabel2() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_second_section_text_2")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_second_section_text_2"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionThirdSectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionThirdTextSectionView() -> TextSectionView {
        let view = TextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_third_section_title"), icon: "roman_3_icon")
        
        return view
    }
    
    private static func createAccordionThirdSectionDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionThirdSectionDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_third_section_text")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_third_section_text"))
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        return label
    }
    
    private static func createAccordionThirdSectionDescriptionListLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_third_section_list")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_third_section_list"))
        
        let range1 = (fullText as NSString).range(of: "https://sosjoueurs.org/")
        let range2 = (fullText as NSString).range(of: "https://gamban.com/fr/")
        let range3 = (fullText as NSString).range(of: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent")
        let range4 = (fullText as NSString).range(of: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1")
        let range5 = (fullText as NSString).range(of: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html")
        let range6 = (fullText as NSString).range(of: "https://www.joueurs-info-service.fr/")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 15
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range2)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range3)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range4)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range5)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range6)

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionFourthSectionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionFourthTextSectionView() -> TextSectionView {
        let view = TextSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("tips_control_fourth_section_title"), icon: "roman_4_icon")
        
        return view
    }
    
    private static func createAccordionFourthSectionDescriptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAccordionFourthSectionDescriptionLabel1() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_fourth_section_text_1")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_fourth_section_text_1"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionFourthSectionDescriptionListLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_fourth_section_list")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_fourth_section_list"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        paragraphStyle.headIndent = 15
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createAccordionFourthSectionDescriptionLabel2() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = localized("tips_control_fourth_section_text_2")
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = (fullText as NSString).range(of: localized("tips_control_fourth_section_text_2"))

        let range1 = (fullText as NSString).range(of: "ANJ")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        label.attributedText = attributedString
        
        return label
    }
    
    private static func createLogo1ImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sos_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createLogo2ImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "evalujeu_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createLogo3ImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "anj_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createTipButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "evalujeu_logo"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        button.contentMode = .scaleAspectFit
        return button
    }
    
    // Constraints
    private static func createFirstSectionDescriptionHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createSecondSectionDescriptionHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createThirdSectionDescriptionHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createFourthSectionDescriptionHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.titleLabel)
        self.scrollContainerView.addSubview(self.textLabel)
        self.scrollContainerView.addSubview(self.accordionView)
        
        self.accordionView.addSubview(self.accordionFirstSectionBaseView)
        
        self.accordionFirstSectionBaseView.addSubview(self.accordionFirstTextSectionView)
        self.accordionFirstSectionBaseView.addSubview(self.accordionFirstSectionDescriptionView)
        
        self.accordionFirstSectionDescriptionView.addSubview(self.accordionFirstSectionDescriptionLabel1)
        self.accordionFirstSectionDescriptionView.addSubview(self.accordionFirstSectionDescriptionListLabel)
        self.accordionFirstSectionDescriptionView.addSubview(self.accordionFirstSectionDescriptionLabel2)
        
        self.accordionView.addSubview(self.accordionSecondSectionBaseView)
        
        self.accordionSecondSectionBaseView.addSubview(self.accordionSecondTextSectionView)
        self.accordionSecondSectionBaseView.addSubview(self.accordionSecondSectionDescriptionView)
        
        self.accordionSecondSectionDescriptionView.addSubview(self.accordionSecondSectionSubsectionView1)
        self.accordionSecondSectionDescriptionView.addSubview(self.accordionSecondSectionDescriptionLabel1)
        self.accordionSecondSectionDescriptionView.addSubview(self.accordionSecondSectionDescriptionListLabel)
        self.accordionSecondSectionDescriptionView.addSubview(self.accordionSecondSectionSubsectionView2)
        self.accordionSecondSectionDescriptionView.addSubview(self.accordionSecondSectionDescriptionLabel2)

        self.accordionView.addSubview(self.accordionThirdSectionBaseView)
        
        self.accordionThirdSectionBaseView.addSubview(self.accordionThirdTextSectionView)
        self.accordionThirdSectionBaseView.addSubview(self.accordionThirdSectionDescriptionView)
        
        self.accordionThirdSectionDescriptionView.addSubview(self.accordionThirdSectionDescriptionLabel)
        self.accordionThirdSectionDescriptionView.addSubview(self.accordionThirdSectionDescriptionListLabel)
        
        self.accordionView.addSubview(self.accordionFourthSectionBaseView)
        
        self.accordionFourthSectionBaseView.addSubview(self.accordionFourthTextSectionView)
        self.accordionFourthSectionBaseView.addSubview(self.accordionFourthSectionDescriptionView)
        self.accordionFourthSectionDescriptionView.addSubview(self.accordionFourthSectionDescriptionLabel1)
        self.accordionFourthSectionDescriptionView.addSubview(self.accordionFourthSectionDescriptionListLabel)
        self.accordionFourthSectionDescriptionView.addSubview(self.accordionFourthSectionDescriptionLabel2)

        self.scrollContainerView.addSubview(self.logo1ImageView)
        self.scrollContainerView.addSubview(self.logo2ImageView)
        self.scrollContainerView.addSubview(self.logo3ImageView)
        
        //self.scrollContainerView.addSubview(self.tipButton)

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

        // Content labels
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 30),

            self.textLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.textLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.textLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15)

        ])
        
        // Accordion
        NSLayoutConstraint.activate([
        
            self.accordionView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.accordionView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.accordionView.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 30),
            
            // First
            self.accordionFirstSectionBaseView.leadingAnchor.constraint(equalTo: self.accordionView.leadingAnchor),
            self.accordionFirstSectionBaseView.trailingAnchor.constraint(equalTo: self.accordionView.trailingAnchor),
            self.accordionFirstSectionBaseView.topAnchor.constraint(equalTo: self.accordionView.topAnchor),
            
            self.accordionFirstTextSectionView.leadingAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.leadingAnchor),
            self.accordionFirstTextSectionView.trailingAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.trailingAnchor),
            self.accordionFirstTextSectionView.topAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.topAnchor),
            
            self.accordionFirstSectionDescriptionView.leadingAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.leadingAnchor),
            self.accordionFirstSectionDescriptionView.trailingAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.trailingAnchor),
            self.accordionFirstSectionDescriptionView.topAnchor.constraint(equalTo: self.accordionFirstTextSectionView.bottomAnchor, constant: 5),
            self.accordionFirstSectionDescriptionView.bottomAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.bottomAnchor, constant: -5),
            
            self.accordionFirstSectionDescriptionLabel1.leadingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFirstSectionDescriptionLabel1.trailingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFirstSectionDescriptionLabel1.topAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.topAnchor, constant: 5),
            
            self.accordionFirstSectionDescriptionListLabel.leadingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFirstSectionDescriptionListLabel.trailingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFirstSectionDescriptionListLabel.topAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionLabel1.bottomAnchor, constant: 10),
            
            self.accordionFirstSectionDescriptionLabel2.leadingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFirstSectionDescriptionLabel2.trailingAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFirstSectionDescriptionLabel2.topAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionListLabel.bottomAnchor, constant: 20),
            self.accordionFirstSectionDescriptionLabel2.bottomAnchor.constraint(equalTo: self.accordionFirstSectionDescriptionView.bottomAnchor, constant: -5),
            
            // Second
            self.accordionSecondSectionBaseView.leadingAnchor.constraint(equalTo: self.accordionView.leadingAnchor),
            self.accordionSecondSectionBaseView.trailingAnchor.constraint(equalTo: self.accordionView.trailingAnchor),
            self.accordionSecondSectionBaseView.topAnchor.constraint(equalTo: self.accordionFirstSectionBaseView.bottomAnchor),
            
            self.accordionSecondTextSectionView.leadingAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.leadingAnchor),
            self.accordionSecondTextSectionView.trailingAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.trailingAnchor),
            self.accordionSecondTextSectionView.topAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.topAnchor),
            
            self.accordionSecondSectionDescriptionView.leadingAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.leadingAnchor),
            self.accordionSecondSectionDescriptionView.trailingAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.trailingAnchor),
            self.accordionSecondSectionDescriptionView.topAnchor.constraint(equalTo: self.accordionSecondTextSectionView.bottomAnchor, constant: 5),
            self.accordionSecondSectionDescriptionView.bottomAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.bottomAnchor, constant: -5),
            
            self.accordionSecondSectionSubsectionView1.leadingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionSecondSectionSubsectionView1.trailingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionSecondSectionSubsectionView1.topAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.topAnchor, constant: 5),
            
            self.accordionSecondSectionDescriptionLabel1.leadingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.leadingAnchor, constant: 60),
            self.accordionSecondSectionDescriptionLabel1.trailingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionSecondSectionDescriptionLabel1.topAnchor.constraint(equalTo: self.accordionSecondSectionSubsectionView1.bottomAnchor, constant: 10),
            
            self.accordionSecondSectionDescriptionListLabel.leadingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.leadingAnchor, constant: 60),
            self.accordionSecondSectionDescriptionListLabel.trailingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionSecondSectionDescriptionListLabel.topAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionLabel1.bottomAnchor, constant: 10),
            
            self.accordionSecondSectionSubsectionView2.leadingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.leadingAnchor, constant: 5),
            self.accordionSecondSectionSubsectionView2.trailingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.trailingAnchor, constant: -5),
            self.accordionSecondSectionSubsectionView2.topAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionListLabel.bottomAnchor, constant: 20),
            
            self.accordionSecondSectionDescriptionLabel2.leadingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.leadingAnchor, constant: 60),
            self.accordionSecondSectionDescriptionLabel2.trailingAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionSecondSectionDescriptionLabel2.topAnchor.constraint(equalTo: self.accordionSecondSectionSubsectionView2.bottomAnchor, constant: 10),
            self.accordionSecondSectionDescriptionLabel2.bottomAnchor.constraint(equalTo: self.accordionSecondSectionDescriptionView.bottomAnchor, constant: -5),
            
            // Third
            self.accordionThirdSectionBaseView.leadingAnchor.constraint(equalTo: self.accordionView.leadingAnchor),
            self.accordionThirdSectionBaseView.trailingAnchor.constraint(equalTo: self.accordionView.trailingAnchor),
            self.accordionThirdSectionBaseView.topAnchor.constraint(equalTo: self.accordionSecondSectionBaseView.bottomAnchor),
            
            self.accordionThirdTextSectionView.leadingAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.leadingAnchor),
            self.accordionThirdTextSectionView.trailingAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.trailingAnchor),
            self.accordionThirdTextSectionView.topAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.topAnchor),
            
            self.accordionThirdSectionDescriptionView.leadingAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.leadingAnchor),
            self.accordionThirdSectionDescriptionView.trailingAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.trailingAnchor),
            self.accordionThirdSectionDescriptionView.topAnchor.constraint(equalTo: self.accordionThirdTextSectionView.bottomAnchor, constant: 5),
            self.accordionThirdSectionDescriptionView.bottomAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.bottomAnchor, constant: -5),
            
            self.accordionThirdSectionDescriptionLabel.leadingAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionThirdSectionDescriptionLabel.trailingAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionThirdSectionDescriptionLabel.topAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.topAnchor, constant: 5),
            
            self.accordionThirdSectionDescriptionListLabel.leadingAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionThirdSectionDescriptionListLabel.trailingAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionThirdSectionDescriptionListLabel.topAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionLabel.bottomAnchor, constant: 10),
            self.accordionThirdSectionDescriptionListLabel.bottomAnchor.constraint(equalTo: self.accordionThirdSectionDescriptionView.bottomAnchor, constant: -5),
            
            // Fourth
            self.accordionFourthSectionBaseView.leadingAnchor.constraint(equalTo: self.accordionView.leadingAnchor),
            self.accordionFourthSectionBaseView.trailingAnchor.constraint(equalTo: self.accordionView.trailingAnchor),
            self.accordionFourthSectionBaseView.topAnchor.constraint(equalTo: self.accordionThirdSectionBaseView.bottomAnchor),
            self.accordionFourthSectionBaseView.bottomAnchor.constraint(equalTo: self.accordionView.bottomAnchor),
            
            self.accordionFourthTextSectionView.leadingAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.leadingAnchor),
            self.accordionFourthTextSectionView.trailingAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.trailingAnchor),
            self.accordionFourthTextSectionView.topAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.topAnchor),
            
            self.accordionFourthSectionDescriptionView.leadingAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.leadingAnchor),
            self.accordionFourthSectionDescriptionView.trailingAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.trailingAnchor),
            self.accordionFourthSectionDescriptionView.topAnchor.constraint(equalTo: self.accordionFourthTextSectionView.bottomAnchor, constant: 5),
            self.accordionFourthSectionDescriptionView.bottomAnchor.constraint(equalTo: self.accordionFourthSectionBaseView.bottomAnchor, constant: -5),
            
            self.accordionFourthSectionDescriptionLabel1.leadingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFourthSectionDescriptionLabel1.trailingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFourthSectionDescriptionLabel1.topAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.topAnchor, constant: 5),
            
            self.accordionFourthSectionDescriptionListLabel.leadingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFourthSectionDescriptionListLabel.trailingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFourthSectionDescriptionListLabel.topAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionLabel1.bottomAnchor, constant: 10),
            
            self.accordionFourthSectionDescriptionLabel2.leadingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.leadingAnchor, constant: 10),
            self.accordionFourthSectionDescriptionLabel2.trailingAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.trailingAnchor, constant: -10),
            self.accordionFourthSectionDescriptionLabel2.topAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionListLabel.bottomAnchor, constant: 20),
            self.accordionFourthSectionDescriptionLabel2.bottomAnchor.constraint(equalTo: self.accordionFourthSectionDescriptionView.bottomAnchor, constant: -5),
        ])
        
        // Bottom icons
        NSLayoutConstraint.activate([
            
            self.logo1ImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.scrollContainerView.leadingAnchor, constant: 15),
            self.logo1ImageView.trailingAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor, constant: -10),
            self.logo1ImageView.topAnchor.constraint(equalTo: self.accordionView.bottomAnchor, constant: 50),
            self.logo1ImageView.heightAnchor.constraint(equalToConstant: 140),
            
            self.logo2ImageView.leadingAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor, constant: 10),
            self.logo2ImageView.trailingAnchor.constraint(lessThanOrEqualTo: self.scrollContainerView.trailingAnchor, constant: -15),
            self.logo2ImageView.centerYAnchor.constraint(equalTo: self.logo1ImageView.centerYAnchor),
            self.logo2ImageView.heightAnchor.constraint(equalToConstant: 140),

            self.logo3ImageView.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.logo3ImageView.heightAnchor.constraint(equalToConstant: 140),
            self.logo3ImageView.topAnchor.constraint(equalTo: self.logo1ImageView.bottomAnchor, constant: 15),
            self.logo3ImageView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -20)
//            self.tipButton.widthAnchor.constraint(equalToConstant: 205),
//            self.tipButton.heightAnchor.constraint(equalToConstant: 50),
//            self.tipButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
//            self.tipButton.topAnchor.constraint(equalTo: self.accordionView.bottomAnchor, constant: 70),
//            self.tipButton.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -20)
        ])
        
        // Constraints
        self.firstSectionDescriptionHeightConstraint =
        NSLayoutConstraint(item: self.accordionFirstSectionDescriptionView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 0)
        self.firstSectionDescriptionHeightConstraint.isActive = true
        
        self.secondSectionDescriptionHeightConstraint =
        NSLayoutConstraint(item: self.accordionSecondSectionDescriptionView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 0)
        self.secondSectionDescriptionHeightConstraint.isActive = true
        
        self.thirdSectionDescriptionHeightConstraint =
        NSLayoutConstraint(item: self.accordionThirdSectionDescriptionView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 0)
        self.thirdSectionDescriptionHeightConstraint.isActive = true
        
        self.fourthSectionDescriptionHeightConstraint =
        NSLayoutConstraint(item: self.accordionFourthSectionDescriptionView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 0)
        self.fourthSectionDescriptionHeightConstraint.isActive = true
    }

}
