//
//  BonusDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 04/03/2022.
//

import UIKit
import Combine

class BonusDetailViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var termsTitleLabel: UILabel = Self.createTermsTitleLabel()
    private lazy var termsLinkLabel: UILabel = Self.createTermsLinkLabel()
    private lazy var bonusImageView: UIImageView = Self.createBonusImageView()
    private lazy var bonusImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createbonusImageViewFixedHeightConstraint()
    private lazy var bonusImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createbonusImageViewDynamicHeightConstraint()
    private lazy var bonusStackView: UIStackView = Self.createBonusStackView()
    
    private var aspectRatio: CGFloat = 1.0
    private var cancellables = Set<AnyCancellable>()

    private var hasBonusImage: Bool = false {
        didSet {
            if hasBonusImage {
                self.bonusImageView.isHidden = false
            }
            else {
                self.bonusImageView.isHidden = true
            }
        }
    }

    private var viewModel: BonusDetailViewModel

    // MARK: Lifetime and Cycle
    init(viewModel: BonusDetailViewModel) {
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

        let termsLinktap = UITapGestureRecognizer(target: self, action: #selector(didTapTermsLinkLabel))

        self.termsLinkLabel.isUserInteractionEnabled = true
        self.termsLinkLabel.addGestureRecognizer(termsLinktap)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.descriptionLabel.textColor = UIColor.App.textPrimary

        self.termsTitleLabel.textColor = UIColor.App.textPrimary

        self.termsLinkLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: BonusDetailViewModel) {

        viewModel.titlePublisher
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.descriptionPublisher
            .sink(receiveValue: { [weak self] description in
                self?.descriptionLabel.text = description
            })
            .store(in: &cancellables)

        viewModel.termsTitlePublisher
            .sink(receiveValue: { [weak self] termsTitle in
                self?.termsTitleLabel.text = termsTitle
            })
            .store(in: &cancellables)

        viewModel.termsLinkStringPublisher
            .sink(receiveValue: { [weak self] termsLinkString in
                self?.termsLinkLabel.text = termsLinkString
            })
            .store(in: &cancellables)

        viewModel.bonusBannerPublisher
            .sink(receiveValue: { [weak self] bonusBannerUrl in
                if let bonusBannerUrl = bonusBannerUrl {
                    self?.bonusImageView.kf.setImage(with: bonusBannerUrl)

                    if let bonusBannerImage = self?.bonusImageView.image {
                        self?.resizeBonusImageView(bonusBanner: bonusBannerImage)
                    }
                    self?.hasBonusImage = true
                }
                else {
                    self?.hasBonusImage = false
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func resizeBonusImageView(bonusBanner: UIImage) {
        self.aspectRatio = bonusBanner.size.width/bonusBanner.size.height

        self.bonusImageViewFixedHeightConstraint.isActive = false

        self.bonusImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bonusImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bonusImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)

        self.bonusImageViewDynamicHeightConstraint.isActive = true
    }

}

//
// MARK: - Actions
//
extension BonusDetailViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTermsLinkLabel() {
        if let url = URL(string: self.viewModel.termsLinkStringPublisher.value) {
            UIApplication.shared.open(url)
        }
    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusDetailViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

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
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bonus")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTermsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Terms"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTermsLinkLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Terms Link"
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createBonusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo_horizontal_large")
        imageView.isHidden = true
        return imageView
    }

    private static func createBonusStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }

    private static func createbonusImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createbonusImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.bonusStackView)

        self.bonusStackView.addArrangedSubview(self.bonusImageView)
        self.bonusStackView.addArrangedSubview(self.titleLabel)

        self.containerView.addSubview(self.descriptionLabel)
        self.containerView.addSubview(self.termsTitleLabel)
        self.containerView.addSubview(self.termsLinkLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top safe area view
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)

        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.bonusStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.bonusStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.bonusStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),

//            self.bonusImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
//            self.bonusImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
//            self.bonusImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
//
//            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
//            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
//            self.titleLabel.topAnchor.constraint(equalTo: self.bonusImageView.bottomAnchor, constant: 15),

            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.bonusStackView.bottomAnchor, constant: 20),

            self.termsTitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.termsTitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.termsTitleLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 30),

            self.termsLinkLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.termsLinkLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.termsLinkLabel.topAnchor.constraint(equalTo: self.termsTitleLabel.bottomAnchor, constant: 20),
        ])

        self.bonusImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bonusImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 150)
        self.bonusImageViewFixedHeightConstraint.isActive = true

        self.bonusImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bonusImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bonusImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bonusImageViewDynamicHeightConstraint.isActive = false
    }

}
