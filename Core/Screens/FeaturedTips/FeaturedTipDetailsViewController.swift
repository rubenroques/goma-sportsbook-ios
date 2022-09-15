//
//  FeaturedTipDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/09/2022.
//

import UIKit
import Combine

class FeaturedTipDetailsViewModel {

    var featuredTip: FeaturedTip

    init(featuredTip: FeaturedTip) {
        self.featuredTip = featuredTip
    }

    func getUsername() -> String {
        //return self.featuredTip.username
        return "USERNAME"
    }

    func getTotalOdds() -> String {
//        let oddFormatted = OddFormatter.formatOdd(withValue: self.featuredTip.totalOdds)
//        return "\(oddFormatted)"
        return "-.--"
    }

    func getNumberSelections() -> String {
        if let numberSelections = self.featuredTip.selections?.count {
            return "\(numberSelections)"
        }

        return ""
    }
}

class FeaturedTipDetailsViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var backgroundContainerView: UIView = Self.createBackgroundContainerView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    private lazy var fullTipContainerView: UIView = Self.createFullTipContainerView()
    private lazy var topInfoStackView: UIStackView = Self.createTopInfoStackView()
    private lazy var counterBaseView: UIView = Self.createCounterBaseView()
    private lazy var counterView: UIView = Self.createCounterView()
    private lazy var counterLabel: UILabel = Self.createCounterLabel()
    private lazy var userImageBaseView: UIView = Self.createUserImageBaseView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var followButton: UIButton = Self.createFollowButton()
    private lazy var tipsScrollView: UIScrollView = Self.createTipsScrollView()
    private lazy var tipsContainerView: UIView = Self.createTipsContainerView()
    private lazy var tipsStackView: UIStackView = Self.createTipsStackView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var totalOddsLabel: UILabel = Self.createTotalOddsLabel()
    private lazy var totalOddsValueLabel: UILabel = Self.createTotalOddsValueLabel()
    private lazy var selectionsLabel: UILabel = Self.createSelectionsLabel()
    private lazy var selectionsValueLabel: UILabel = Self.createSelectionsValueLabel()
    private lazy var betButton: UIButton = Self.createBetButton()

    // MARK: Public properties
    var viewModel: FeaturedTipDetailsViewModel

    var hasCounter: Bool = false {
        didSet {
            self.counterBaseView.isHidden = !hasCounter
        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: FeaturedTipDetailsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.configure()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("FeaturedTipDetailsViewController deinit called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .primaryActionTriggered)

        self.betButton.addTarget(self, action: #selector(didTapBetButton), for: .primaryActionTriggered)

    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.containerView.clipsToBounds = true

        self.fullTipContainerView.layer.cornerRadius = CornerRadius.view
        self.fullTipContainerView.layer.masksToBounds = true

        self.counterView.layer.cornerRadius = self.counterView.frame.height / 2
        self.counterView.layer.masksToBounds = true

        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = .clear

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.backgroundContainerView.backgroundColor = UIColor.App.backgroundSecondary.withAlphaComponent(0.7)

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.backButton.tintColor = UIColor.App.textPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tipsScrollView.backgroundColor = .clear

        self.fullTipContainerView.backgroundColor = UIColor.App.backgroundSecondary

        self.topInfoStackView.backgroundColor = .clear

        self.counterBaseView.backgroundColor = .clear

        self.counterView.backgroundColor = UIColor.App.highlightSecondary

        self.counterLabel.textColor = UIColor.App.buttonTextPrimary

        self.userImageBaseView.backgroundColor = .clear

        self.userImageView.backgroundColor = .clear
        self.userImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.usernameLabel.textColor = UIColor.App.textPrimary

        self.followButton.backgroundColor = .clear
        self.followButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.tipsContainerView.backgroundColor = .clear

        self.tipsStackView.backgroundColor = .clear

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.totalOddsLabel.textColor = UIColor.App.textPrimary

        self.totalOddsValueLabel.textColor = UIColor.App.textPrimary

        self.selectionsLabel.textColor = UIColor.App.textPrimary

        self.selectionsValueLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.betButton)
        self.betButton.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), imageTitlePadding: CGFloat(0))

    }

    // MARK: Functions
    private func configure() {

        // TEMP
        self.backButton.isHidden = true

        self.hasCounter = true

        if let numberTips = self.viewModel.featuredTip.selections?.count {

            for i in (0..<numberTips) {

                let tipView = FeaturedTipView()

                if let featuredTipSelection = self.viewModel.featuredTip.selections?[safe: i] {

                    tipView.configure(featuredTipSelection: featuredTipSelection)

                    self.tipsStackView.addArrangedSubview(tipView)

                    tipView.layoutSubviews()
                    tipView.layoutIfNeeded()

                }

            }

        }

        self.usernameLabel.text = viewModel.getUsername()

        self.totalOddsValueLabel.text = viewModel.getTotalOdds()

        self.selectionsValueLabel.text = viewModel.getNumberSelections()
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }

    @objc func didTapFollowButton() {
        print("TAPPED FOLLOW: \(self.viewModel.getUsername())")
    }

    @objc func didTapBetButton() {
        print("TAPPED BET: \(self.viewModel.featuredTip.betId)")
    }

}

//
// MARK: Subviews initialization and setup
//
extension FeaturedTipDetailsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackgroundContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

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
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("featured_tips")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        return button
    }

    private static func createFullTipContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fillProportionally
        return stackView
    }

    private static func createCounterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }

    private static func createCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createUserImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }

    private static func createUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        return imageView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.font = AppFont.with(type: .semibold, size: 15)
        return label
    }

    private static func createFollowButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("follow"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createTipsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createTipsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTotalOddsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("total_odds")): "
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createTotalOddsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("0.0")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createSelectionsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("number_selections")): "
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createSelectionsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("1")
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createBetButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("bet_same"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.backgroundContainerView)

        self.backgroundContainerView.addSubview(self.containerView)

        self.containerView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

        self.containerView.addSubview(self.fullTipContainerView)

        self.fullTipContainerView.addSubview(self.topInfoStackView)

        self.topInfoStackView.addArrangedSubview(self.counterBaseView)
        self.counterBaseView.addSubview(self.counterView)
        self.counterView.addSubview(self.counterLabel)

        self.topInfoStackView.addArrangedSubview(self.userImageBaseView)
        self.userImageBaseView.addSubview(self.userImageView)

        self.topInfoStackView.addArrangedSubview(self.usernameLabel)

        self.fullTipContainerView.addSubview(self.followButton)

        self.fullTipContainerView.addSubview(self.tipsScrollView)

        self.tipsScrollView.addSubview(self.tipsContainerView)

        self.tipsContainerView.addSubview(self.tipsStackView)

        self.fullTipContainerView.addSubview(self.separatorLineView)

        self.fullTipContainerView.addSubview(self.totalOddsLabel)
        self.fullTipContainerView.addSubview(self.totalOddsValueLabel)

        self.fullTipContainerView.addSubview(self.selectionsLabel)
        self.fullTipContainerView.addSubview(self.selectionsValueLabel)

        self.fullTipContainerView.addSubview(self.betButton)

        self.initConstraints()

        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Container view
        NSLayoutConstraint.activate([
            self.backgroundContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundContainerView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.backgroundContainerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.containerView.leadingAnchor.constraint(equalTo: self.backgroundContainerView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.backgroundContainerView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.backgroundContainerView.topAnchor, constant: 60),
            self.containerView.bottomAnchor.constraint(equalTo: self.backgroundContainerView.bottomAnchor)

        ])

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -20),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalToConstant: 44)

        ])

        // Full tip container view
        NSLayoutConstraint.activate([
            self.fullTipContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.fullTipContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.fullTipContainerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20),
            self.fullTipContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

        ])

        // Full tip top info stackview
        NSLayoutConstraint.activate([
            self.topInfoStackView.leadingAnchor.constraint(equalTo: self.fullTipContainerView.leadingAnchor, constant: 10),
            self.topInfoStackView.topAnchor.constraint(equalTo: self.fullTipContainerView.topAnchor, constant: 5),
            self.topInfoStackView.heightAnchor.constraint(equalToConstant: 40),
            self.topInfoStackView.trailingAnchor.constraint(equalTo: self.fullTipContainerView.trailingAnchor, constant: -60),

            self.counterView.leadingAnchor.constraint(equalTo: self.counterBaseView.leadingAnchor),
            self.counterView.trailingAnchor.constraint(equalTo: self.counterBaseView.trailingAnchor),
            self.counterView.widthAnchor.constraint(equalToConstant: 17),
            self.counterView.heightAnchor.constraint(equalTo: self.counterView.widthAnchor),
            self.counterView.centerYAnchor.constraint(equalTo: self.counterBaseView.centerYAnchor),

            self.counterLabel.leadingAnchor.constraint(equalTo: self.counterView.leadingAnchor, constant: 4),
            self.counterLabel.trailingAnchor.constraint(equalTo: self.counterView.trailingAnchor, constant: -4),
            self.counterLabel.centerYAnchor.constraint(equalTo: self.counterView.centerYAnchor),

            self.userImageView.leadingAnchor.constraint(equalTo: self.userImageBaseView.leadingAnchor),
            self.userImageView.trailingAnchor.constraint(equalTo: self.userImageBaseView.trailingAnchor),
            self.userImageView.widthAnchor.constraint(equalToConstant: 26),
            self.userImageView.heightAnchor.constraint(equalTo: self.userImageView.widthAnchor),
            self.userImageView.centerYAnchor.constraint(equalTo: self.userImageBaseView.centerYAnchor),

            self.usernameLabel.centerYAnchor.constraint(equalTo: self.topInfoStackView.centerYAnchor),

            self.followButton.trailingAnchor.constraint(equalTo: self.fullTipContainerView.trailingAnchor, constant: -10),
            self.followButton.topAnchor.constraint(equalTo: self.fullTipContainerView.topAnchor, constant: 5),
            self.followButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Tips stackview
        NSLayoutConstraint.activate([

            self.tipsScrollView.leadingAnchor.constraint(equalTo: self.fullTipContainerView.leadingAnchor),
            self.tipsScrollView.trailingAnchor.constraint(equalTo: self.fullTipContainerView.trailingAnchor),
            self.tipsScrollView.topAnchor.constraint(equalTo: self.topInfoStackView.bottomAnchor, constant: 10),
            self.tipsScrollView.bottomAnchor.constraint(equalTo: self.separatorLineView.topAnchor, constant: -5),
            self.tipsScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.fullTipContainerView.widthAnchor),

            self.tipsContainerView.leadingAnchor.constraint(equalTo: self.tipsScrollView.leadingAnchor, constant: 10),
            self.tipsContainerView.trailingAnchor.constraint(equalTo: self.tipsScrollView.trailingAnchor, constant: -10),
            self.tipsContainerView.topAnchor.constraint(equalTo: self.tipsScrollView.contentLayoutGuide.topAnchor),
            self.tipsContainerView.bottomAnchor.constraint(equalTo: self.tipsScrollView.contentLayoutGuide.bottomAnchor),

            self.tipsStackView.leadingAnchor.constraint(equalTo: self.tipsContainerView.leadingAnchor),
            self.tipsStackView.trailingAnchor.constraint(equalTo: self.tipsContainerView.trailingAnchor),
            self.tipsStackView.topAnchor.constraint(equalTo: self.tipsContainerView.topAnchor),
            self.tipsStackView.bottomAnchor.constraint(equalTo: self.tipsContainerView.bottomAnchor)
        ])

        // Bottom info
        NSLayoutConstraint.activate([
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.fullTipContainerView.leadingAnchor, constant: 10),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.fullTipContainerView.trailingAnchor, constant: -10),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.totalOddsLabel.topAnchor, constant: -15),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.totalOddsLabel.leadingAnchor.constraint(equalTo: self.fullTipContainerView.leadingAnchor, constant: 10),
            self.totalOddsLabel.bottomAnchor.constraint(equalTo: self.selectionsLabel.topAnchor, constant: -10),

            self.totalOddsValueLabel.leadingAnchor.constraint(equalTo: self.totalOddsLabel.trailingAnchor),
            self.totalOddsValueLabel.centerYAnchor.constraint(equalTo: self.totalOddsLabel.centerYAnchor),

            self.selectionsLabel.leadingAnchor.constraint(equalTo: self.fullTipContainerView.leadingAnchor, constant: 10),
            self.selectionsLabel.bottomAnchor.constraint(equalTo: self.fullTipContainerView.bottomAnchor, constant: -13),

            self.selectionsValueLabel.leadingAnchor.constraint(equalTo: self.selectionsLabel.trailingAnchor),
            self.selectionsValueLabel.centerYAnchor.constraint(equalTo: self.selectionsLabel.centerYAnchor),

            self.betButton.trailingAnchor.constraint(equalTo: self.fullTipContainerView.trailingAnchor, constant: -10),
            self.betButton.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 15),
            self.betButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

}
