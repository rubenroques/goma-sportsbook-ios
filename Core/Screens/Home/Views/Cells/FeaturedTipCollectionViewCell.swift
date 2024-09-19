//
//  FeaturedTipCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/08/2022.
//

import UIKit
import Combine

class FeaturedTipCollectionViewCell: UICollectionViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var containerBackgroundImageView: UIImageView = Self.createContainerBackgroundImageView()
    private lazy var gradientBorderView: GradientBorderView = Self.createGradientBorderView()
    private lazy var topInfoStackView: UIStackView = Self.createTopInfoStackView()
    private lazy var counterBaseView: UIView = Self.createCounterBaseView()
    private lazy var counterView: UIView = Self.createCounterView()
    private lazy var counterLabel: UILabel = Self.createCounterLabel()
    private lazy var userImageBaseView: UIView = Self.createUserImageBaseView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var followButton: UIButton = Self.createFollowButton()
    private lazy var unfollowButton: UIButton = Self.createUnfollowButton()
    private lazy var tipsBaseScrollView: UIScrollView = Self.createTipsBaseScrollView()
    private lazy var tipsContainerView: UIView = Self.createTipsContainerView()
    private lazy var tipsStackView: UIStackView = Self.createTipsStackView()
    private lazy var fullTipButton: UIButton = Self.createFullTipButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var totalOddsLabel: UILabel = Self.createTotalOddsLabel()
    private lazy var totalOddsValueLabel: UILabel = Self.createTotalOddsValueLabel()
    private lazy var selectionsLabel: UILabel = Self.createSelectionsLabel()
    private lazy var selectionsValueLabel: UILabel = Self.createSelectionsValueLabel()
    private lazy var betButton: UIButton = Self.createBetButton()

    private var topContainerHeightConstraint: NSLayoutConstraint?
    private var topContainerForCenteredConstraint: NSLayoutConstraint?
    private var topContainerForFixedConstraint: NSLayoutConstraint?
    
    // MARK: Public Properties
    var hasCounter: Bool = false {
        didSet {
            self.counterBaseView.isHidden = !hasCounter
        }
    }

    var showFullTipButton: Bool = false {
        didSet {
            self.fullTipButton.isHidden = !showFullTipButton
        }
    }

    var hasFollow: Bool = true {
        didSet {
            self.followButton.isHidden = !hasFollow
            self.unfollowButton.isHidden = hasFollow
        }
    }

    var socialFeaturesEnabled: Bool = false
    
    var viewModel: FeaturedTipCollectionViewModel?

    var openFeaturedTipDetailAction: ((FeaturedTipCollectionViewModel) -> Void) = { _ in }
    var shouldReloadData: (() -> Void)?
    var shouldShowBetslip: (() -> Void)?
    var shouldShowUserProfile: ((UserBasicInfo) -> Void)?

    private var oddCancelable: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        self.hasCounter = false
        self.showFullTipButton = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCellContentView))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)

        self.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .primaryActionTriggered)
        self.unfollowButton.addTarget(self, action: #selector(didTapUnfollowButton), for: .primaryActionTriggered)
        self.betButton.addTarget(self, action: #selector(didTapBetButton), for: .primaryActionTriggered)
        self.fullTipButton.addTarget(self, action: #selector(didTapShowFullTipButton), for: .primaryActionTriggered)

        let userTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        self.topInfoStackView.addGestureRecognizer(userTapGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        
        self.socialFeaturesEnabled = false
        
        self.usernameLabel.text = ""
        self.totalOddsValueLabel.text = ""
        self.selectionsValueLabel.text = ""
        
        self.tipsStackView.removeAllArrangedSubviews()

        self.hasCounter = false
        self.showFullTipButton = false

        self.betButton.isEnabled = true
    }

    // MARK: - Theme and Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.layoutIfNeeded()
        
        self.counterView.layer.cornerRadius = self.counterView.frame.height / 2
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
        self.tipsStackView.arrangedSubviews.forEach { view in
            view.layoutSubviews()
        }
        
        self.topInfoStackView.arrangedSubviews.forEach { view in
            view.layoutSubviews()
        }
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.containerBackgroundImageView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.containerBackgroundImageView.image = UIImage(named: "suggested_bet_background")
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

        self.unfollowButton.backgroundColor = .clear
        self.unfollowButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.tipsContainerView.backgroundColor = .clear
        self.tipsStackView.backgroundColor = .clear

        self.fullTipButton.backgroundColor = .clear
        self.fullTipButton.setTitleColor(UIColor.App.highlightTertiary, for: .normal)
        self.fullTipButton.imageView?.setTintColor(color: UIColor.App.highlightTertiary)
        
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.totalOddsLabel.textColor = UIColor.App.textPrimary
        self.totalOddsValueLabel.textColor = UIColor.App.textPrimary

        self.selectionsLabel.textColor = UIColor.App.textPrimary
        self.selectionsValueLabel.textColor = UIColor.App.textPrimary

        
        StyleHelper.styleButton(button: self.betButton)
        
        self.betButton.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), imageTitlePadding: CGFloat(0))
    }

    // MARK: Function

    func configure(viewModel: FeaturedTipCollectionViewModel, socialFeaturesEnabled: Bool = false, hasCounter: Bool, followingUsers: [Follower]) {

        self.viewModel = viewModel
        self.socialFeaturesEnabled = socialFeaturesEnabled
        
        if socialFeaturesEnabled {
            self.topContainerHeightConstraint?.constant = 40
            self.usernameLabel.isHidden = false
            self.usernameLabel.text = viewModel.getUsername()
            
            self.hasCounter = hasCounter
            
            let tipUserId = viewModel.getUserId()
            
            let followUserId = followingUsers.filter({
                "\($0.id)" == tipUserId
            })
            
            if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
                
                if followUserId.isNotEmpty || tipUserId == "\(loggedUserId)" {
                    self.hasFollow = false
                }
                else {
                    self.hasFollow = true
                }
            }
            else {
                self.hasFollow = false
            }
        }
        else {
            self.topContainerHeightConstraint?.constant = 0
            self.usernameLabel.isHidden = true
            self.hasCounter = false
            self.hasFollow = false
            self.followButton.isHidden = true
            self.unfollowButton.isHidden = true
        }
        
        
        self.totalOddsValueLabel.text = "-"
        self.selectionsValueLabel.text = viewModel.getNumberSelections()
        
        //
        for (i, featuredTipSelection) in viewModel.selectionViewModels.enumerated() {
            if i >= FeaturedTipLineViewModel.maxTicketsBeforeExpand && (self.viewModel?.shouldCropList ?? true) {
                self.showFullTipButton = true
                break
            }
            else {
                let tipView = FeaturedTipView()
                tipView.configure(withFeaturedTipSelectionViewModel: featuredTipSelection)
                self.tipsStackView.addArrangedSubview(tipView)
                
                self.showFullTipButton = false
            }
        }
        
        self.oddCancelable = viewModel.totalOddPulisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newOddString in
                self?.totalOddsValueLabel.text = newOddString
            })
        
        if viewModel.sizeType == .small {
            self.topContainerForFixedConstraint?.isActive = true
            self.topContainerForCenteredConstraint?.isActive = false
        }
        else {
            self.topContainerForFixedConstraint?.isActive = false
            self.topContainerForCenteredConstraint?.isActive = true
        }

        viewModel.shouldShowBetslip = { [weak self] in
            self?.shouldShowBetslip?()
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    // MARK: Actions
    @objc func didTapFollowButton() {
        if let viewModel = self.viewModel,
           let userId = viewModel.getUserId() {
            viewModel.followUser(userId: userId)
        }
    }

    @objc func didTapUnfollowButton() {
        if let viewModel = self.viewModel,
           let userId = viewModel.getUserId() {
            viewModel.unfollowUser(userId: userId)
        }
    }

    @objc func didTapBetButton() {
        self.viewModel?.addTicketBetslip()
    }

    @objc func didTapCellContentView() {
        self.didTapShowFullTipButton()
    }
    
    @objc func didTapShowFullTipButton() {
        
        if let viewModel = self.viewModel {
            self.openFeaturedTipDetailAction(viewModel)
        }
    }

    @objc func didTapUser() {
        if let userId = self.viewModel?.getUserId() {
            let userBasicInfo = UserBasicInfo(userId: userId, username: self.viewModel?.getUsername() ?? "")

            self.shouldShowUserProfile?(userBasicInfo)
        }

    }
    
    func configureAnimationId(_ id: String) {
        self.containerView.shift.id = id
    }
    
}

extension FeaturedTipCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
    
        return view
    }
    
    
    private static func createContainerBackgroundImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }
    
    private static func createGradientBorderView() -> GradientBorderView {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 2
        gradientBorderView.gradientCornerRadius = 8
        
        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]
        
        return gradientBorderView
    }
    
    private static func createTopInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.clipsToBounds = true
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
        view.layer.masksToBounds = true
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
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("username")
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

    private static func createUnfollowButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("unfollow"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createTipsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTipsBaseScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bounces = false
        view.isDirectionalLockEnabled = true
        return view
    }

    private static func createTipsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }

    private static func createFullTipButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("show_full_tip"), for: .normal)
        button.setImage(UIImage(named: "arrow_right_gray_icon"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 12)
        
        // Transform
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        return button
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
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createTotalOddsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("--")
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createSelectionsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("number_of_selections")): "
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
        button.setTitle(localized("bet_now"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.containerBackgroundImageView)

        self.containerView.addSubview(self.gradientBorderView)
        
        self.containerView.addSubview(self.topInfoStackView)

        self.topInfoStackView.addArrangedSubview(self.counterBaseView)
        self.counterBaseView.addSubview(self.counterView)
        self.counterView.addSubview(self.counterLabel)

        self.topInfoStackView.addArrangedSubview(self.userImageBaseView)
        self.userImageBaseView.addSubview(self.userImageView)

        self.topInfoStackView.addArrangedSubview(self.usernameLabel)

        self.containerView.addSubview(self.followButton)

        self.containerView.addSubview(self.unfollowButton)

        self.containerView.addSubview(self.tipsBaseScrollView)

        self.tipsBaseScrollView.addSubview(self.tipsContainerView)
        
        self.tipsContainerView.addSubview(self.tipsStackView)

        self.containerView.addSubview(self.fullTipButton)
        
        // self.containerView.addSubview(self.separatorLineView)

        self.containerView.addSubview(self.totalOddsLabel)
        self.containerView.addSubview(self.totalOddsValueLabel)

//        self.containerView.addSubview(self.selectionsLabel)
//        self.containerView.addSubview(self.selectionsValueLabel)

        self.containerView.addSubview(self.betButton)

        self.initConstraints()
    }

    private func initConstraints() {

        self.topContainerHeightConstraint = self.topInfoStackView.heightAnchor.constraint(equalToConstant: 40)
        self.topContainerForCenteredConstraint = self.containerView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 1)
        self.topContainerForFixedConstraint = self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor)
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.topContainerForCenteredConstraint!,
            self.containerView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.gradientBorderView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.gradientBorderView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.gradientBorderView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.gradientBorderView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            
            self.containerBackgroundImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerBackgroundImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.containerBackgroundImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.containerBackgroundImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
        ])

        // Top Info stackview
        NSLayoutConstraint.activate([
            self.topInfoStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.topInfoStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.topContainerHeightConstraint!,
            self.topInfoStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -60),

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

            self.followButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.followButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.followButton.heightAnchor.constraint(equalToConstant: 40),

            self.unfollowButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.unfollowButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.unfollowButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Tips stackview
        let equalityConstraint = self.tipsBaseScrollView.heightAnchor.constraint(equalTo: self.tipsContainerView.heightAnchor)
        equalityConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
        
            equalityConstraint,
            
            self.tipsBaseScrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8.5),
            self.tipsBaseScrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8.5),
            self.tipsBaseScrollView.topAnchor.constraint(equalTo: self.topInfoStackView.bottomAnchor, constant: 3),
            self.tipsBaseScrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -52),
        
            self.tipsContainerView.topAnchor.constraint(equalTo: self.tipsBaseScrollView.contentLayoutGuide.topAnchor),
            self.tipsContainerView.bottomAnchor.constraint(equalTo: self.tipsBaseScrollView.contentLayoutGuide.bottomAnchor),
            self.tipsContainerView.leadingAnchor.constraint(equalTo: self.tipsBaseScrollView.contentLayoutGuide.leadingAnchor),
            self.tipsContainerView.trailingAnchor.constraint(equalTo: self.tipsBaseScrollView.contentLayoutGuide.trailingAnchor),
            
            self.tipsContainerView.widthAnchor.constraint(equalTo: self.tipsBaseScrollView.frameLayoutGuide.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.tipsStackView.leadingAnchor.constraint(equalTo: self.tipsContainerView.leadingAnchor),
            self.tipsStackView.trailingAnchor.constraint(equalTo: self.tipsContainerView.trailingAnchor),
            self.tipsStackView.topAnchor.constraint(equalTo: self.tipsContainerView.topAnchor),
            self.tipsStackView.bottomAnchor.constraint(equalTo: self.tipsContainerView.bottomAnchor),

            self.fullTipButton.bottomAnchor.constraint(equalTo: self.betButton.topAnchor, constant: -2),
            self.fullTipButton.heightAnchor.constraint(equalToConstant: 25),
            self.fullTipButton.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor)
        ])

        // Bottom info
        NSLayoutConstraint.activate([
//            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
//            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
//            self.separatorLineView.bottomAnchor.constraint(equalTo: self.totalOddsLabel.topAnchor, constant: -15),
//            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.totalOddsLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 13),
            self.totalOddsLabel.centerYAnchor.constraint(equalTo: self.betButton.centerYAnchor),

            self.totalOddsValueLabel.leadingAnchor.constraint(equalTo: self.totalOddsLabel.trailingAnchor),
            self.totalOddsValueLabel.centerYAnchor.constraint(equalTo: self.totalOddsLabel.centerYAnchor),

//            self.selectionsLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
//            self.selectionsLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -13),
//
//            self.selectionsValueLabel.leadingAnchor.constraint(equalTo: self.selectionsLabel.trailingAnchor),
//            self.selectionsValueLabel.centerYAnchor.constraint(equalTo: self.selectionsLabel.centerYAnchor),

            self.betButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.betButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),
            self.betButton.heightAnchor.constraint(equalToConstant: 35),
            self.betButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 118)
        ])
    }
}

struct UserBasicInfo {
    var userId: String
    var username: String
}
