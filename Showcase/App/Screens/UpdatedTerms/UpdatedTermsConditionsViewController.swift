//
//  UpdatedTermsConditionsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/04/2024.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

class UpdatedTermsConditionsViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var contentScrollView: UIScrollView = Self.createScrollBaseView()
    
    private lazy var introTextLabel: UILabel = Self.createIntroTextLabel()
    private lazy var descriptionTextLabel: UILabel = Self.createDescriptionLabel()
    
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()
    
    private lazy var continueButton: UIButton = Self.createContinueButton()
    
    var userAccepedtedTermsAction: () -> Void = { }
    
    private var cancellables = Set<AnyCancellable>()
    
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
        self.commonInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    func commonInit() {

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
        
        self.titleLabel.text = localized("terms_and_conditions")
        self.introTextLabel.text = localized("terms_consent_popup_description")
        // self.descriptionTextLabel.text = localized("terms_consent_popup_items_list")
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
        self.introTextLabel.textColor = UIColor.App.textPrimary
        //self.descriptionTextLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButton(button: self.continueButton)
    }

    // MARK: - Actions
    @objc func didTapContinueButton() {
        Env.userSessionStore.didAcceptedTermsUpdate()
        
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension UpdatedTermsConditionsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("terms_and_conditions")
        titleLabel.font = AppFont.with(type: .bold, size: 30)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollBaseView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createIntroTextLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = AppFont.with(type: .semibold, size: 16)
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createDescriptionLabelOld() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("terms_consent_popup_items_list")
        label.textAlignment = .left
        label.numberOfLines = 0

        let text = localized("terms_consent_popup_items_list")
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: localized("terms_consent_popup_items_list"))
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

        return label
    }
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0

        let text = localized("terms_consent_popup_items_list")
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: text)

        // Common styling
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 18
        paragraphStyle.alignment = .left

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .medium, size: 14), range: fullRange)

        // Bullet point styling
        var range = (text as NSString).range(of: "•")
        while range.location != NSNotFound {
            // Orange color for bullet "•"
            attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
            
            // Finding the end of the bullet point text
            let nextRange = NSRange(location: range.location + 1, length: text.count - range.location - 1)
            let endOfLineRange = (text as NSString).rangeOfCharacter(from: .newlines, options: [], range: nextRange)
            let textRange = endOfLineRange.location != NSNotFound ? NSRange(location: range.location, length: endOfLineRange.location - range.location) : nextRange

            // Prepare for next bullet point
            range = (text as NSString).range(of: "•", range: NSRange(location: range.location + 1, length: text.count - range.location - 1))
        }

        label.attributedText = attributedString

        return label
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 28
        return stackView
    }

    private static func createContinueButton() -> UIButton {
        let continueButton = UIButton()
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(localized("accept_all_cookies"), for: .normal)
        StyleHelper.styleButton(button: continueButton)
        continueButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        return continueButton
    }

    private func setupSubviews() {
        self.navigationBaseView.addSubview(self.titleLabel)
        
        self.contentBaseView.addSubview(self.introTextLabel)
        self.contentBaseView.addSubview(self.descriptionTextLabel)

        self.buttonsStackView.addArrangedSubview(self.continueButton)

        self.bottomBaseView.addSubview(self.separatorLineView)
        self.bottomBaseView.addSubview(self.buttonsStackView)
        self.contentScrollView.addSubview(self.contentBaseView)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.contentScrollView)
        self.view.addSubview(self.bottomBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 100),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 34),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.contentScrollView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: -8),

            self.contentBaseView.topAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.contentScrollView.frameLayoutGuide.widthAnchor),

            self.introTextLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 12),
            self.introTextLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.introTextLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -34),
            
            self.descriptionTextLabel.topAnchor.constraint(equalTo: self.introTextLabel.bottomAnchor, constant: 12),
            
            self.descriptionTextLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.descriptionTextLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -34),
            self.descriptionTextLabel.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -12),
        ])

        NSLayoutConstraint.activate([
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),

            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 34),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -34),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: -40),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 40),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),
            
            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
        ])

    }

}
