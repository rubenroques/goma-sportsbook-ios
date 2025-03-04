//
//  BettingPracticesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 29/01/2025.
//

import UIKit

class BettingPracticesViewController: UIViewController {

    // MARK: Private Properties
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    
    private lazy var actionButton: UIButton = Self.createActionButton()

    // MARK: Lifetime and Cycle
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubviews()
        self.setupWithTheme()
        
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    
    private func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary
        
        self.navigationTitleLabel.textColor = UIColor.App.textPrimary
        
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.titleLabel.textColor = UIColor.App.highlightPrimary
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.actionButton)
    }
    
    // MARK: Actions
    @objc private func didTapBackButton() {
        if self.isRootModal {
            self.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc private func didTapActionButton() {
        
        let bettingPracticesQuestionnaireViewModel = BettingPracticesQuestionnaireViewModel()
        
        let bettingPracticesQuestionnaireViewController = BettingPracticesQuestionnaireViewController(viewModel: bettingPracticesQuestionnaireViewModel)
        
        self.navigationController?.pushViewController(bettingPracticesQuestionnaireViewController, animated: true)
    }
}

extension BettingPracticesViewController {
    
    private static func createNavigationView() -> UIView {
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

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("betting_questionnaire")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betsson_mobile_banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("flat_foot_security")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 16)
        label.text = "\(localized("questionnaire_intro_1"))\n\n\(localized("questionnaire_intro_2"))"
        label.numberOfLines = 0
        return label
    }
    
    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("take_questionnaire"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        return button
    }
    
    private func setupSubviews() {
        
        self.view.addSubview(self.navigationView)
        
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.navigationTitleLabel)
        
        self.view.addSubview(self.containerView)
        
        self.containerView.addSubview(self.bannerImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)
        self.containerView.addSubview(self.actionButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        
        // Navigation bar
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 40),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -40),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

        ])
        
        // Container views
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.bannerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.bannerImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
//            self.bannerImageView.heightAnchor.constraint(equalToConstant: 124),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 44),
            
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),
            
            self.actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.actionButton.heightAnchor.constraint(equalToConstant: 50),
            self.actionButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -40)
            
        ])
    }
}
