//
//  TipsTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 06/09/2022.
//

import UIKit
import Combine

class TipsTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topInfoStackView: UIStackView = Self.createTopInfoStackView()
    private lazy var counterBaseView: UIView = Self.createCounterBaseView()
    private lazy var counterView: UIView = Self.createCounterView()
    private lazy var counterLabel: UILabel = Self.createCounterLabel()
    private lazy var userImageBaseView: UIView = Self.createUserImageBaseView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var followButton: UIButton = Self.createFollowButton()
    private lazy var tipsStackView: UIStackView = Self.createTipsStackView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var totalOddsLabel: UILabel = Self.createTotalOddsLabel()
    private lazy var totalOddsValueLabel: UILabel = Self.createTotalOddsValueLabel()
    private lazy var selectionsLabel: UILabel = Self.createSelectionsLabel()
    private lazy var selectionsValueLabel: UILabel = Self.createSelectionsValueLabel()
    private lazy var betButton: UIButton = Self.createBetButton()

    // MARK: Public Properties
    var hasCounter: Bool = false {
        didSet {
            self.counterBaseView.isHidden = !hasCounter
        }
    }

    var hasFollow: Bool = false {
        didSet {
            self.followButton.isHidden = !hasFollow
        }
    }

    var viewModel: TipsCellViewModel?

    var shouldShowBetslip: (() -> Void)?

    // MARK: - Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.hasCounter = false

        self.hasFollow = false

        self.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .primaryActionTriggered)

        self.betButton.addTarget(self, action: #selector(didTapBetButton), for: .primaryActionTriggered)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.tipsStackView.removeAllArrangedSubviews()

        self.hasCounter = false

        self.hasFollow = false

    }

    // MARK: - Layout and Theme
    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.counterView.layer.cornerRadius = self.counterView.frame.height / 2
        self.counterView.layer.masksToBounds = true

        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

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

        self.tipsStackView.backgroundColor = .clear

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.totalOddsLabel.textColor = UIColor.App.textPrimary

        self.totalOddsValueLabel.textColor = UIColor.App.textPrimary

        self.selectionsLabel.textColor = UIColor.App.textPrimary

        self.selectionsValueLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.betButton)
        self.betButton.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), imageTitlePadding: CGFloat(0))
    }

    // MARK: Function
    func configure(viewModel: TipsCellViewModel, followingUsers: [Follower]) {

        self.viewModel = viewModel

        self.hasCounter = false

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

        if let numberTips = viewModel.featuredTip.selections?.count {

            for i in (0..<numberTips) {

                let tipView = FeaturedTipView()

                if let featuredTipSelection = self.viewModel?.featuredTip.selections?[safe: i] {

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

        viewModel.shouldShowBetslip = { [weak self] in
            self?.shouldShowBetslip?()
        }

    }

    // MARK: Actions
    @objc func didTapFollowButton() {
        if let viewModel = self.viewModel {
            let userId = viewModel.getUserId()

            print("TAPPED FOLLOW: \(viewModel.getUsername()) - \(viewModel.getUserId())")

            viewModel.followUser(userId: userId)
        }
    }

    @objc func didTapBetButton() {
        if let viewModel = self.viewModel {
            let betId = viewModel.getBetId()
            print("TAPPED BET: \(betId)")

            viewModel.createBetslipTicket()
        }
    }

}

extension TipsTableViewCell {

    private static func createContainerView() -> UIView {
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

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topInfoStackView)

        self.topInfoStackView.addArrangedSubview(self.counterBaseView)
        self.counterBaseView.addSubview(self.counterView)
        self.counterView.addSubview(self.counterLabel)

        self.topInfoStackView.addArrangedSubview(self.userImageBaseView)
        self.userImageBaseView.addSubview(self.userImageView)

        self.topInfoStackView.addArrangedSubview(self.usernameLabel)

        self.containerView.addSubview(self.followButton)

        self.containerView.addSubview(self.tipsStackView)

        self.containerView.addSubview(self.separatorLineView)

        self.containerView.addSubview(self.totalOddsLabel)
        self.containerView.addSubview(self.totalOddsValueLabel)

        self.containerView.addSubview(self.selectionsLabel)
        self.containerView.addSubview(self.selectionsValueLabel)

        self.containerView.addSubview(self.betButton)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])

        // Top Info stackview
        NSLayoutConstraint.activate([
            self.topInfoStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.topInfoStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.topInfoStackView.heightAnchor.constraint(equalToConstant: 40),
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
            self.followButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Tips stackview
        NSLayoutConstraint.activate([

            self.tipsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.tipsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.tipsStackView.topAnchor.constraint(equalTo: self.topInfoStackView.bottomAnchor, constant: 10),
            self.tipsStackView.bottomAnchor.constraint(equalTo: self.separatorLineView.topAnchor, constant: -10)
        ])

        // Bottom info
        NSLayoutConstraint.activate([
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            //self.separatorLineView.topAnchor.constraint(equalTo: self.tipsStackView.bottomAnchor, constant: 10),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.totalOddsLabel.topAnchor, constant: -15),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.totalOddsLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.totalOddsLabel.bottomAnchor.constraint(equalTo: self.selectionsLabel.topAnchor, constant: -10),

            self.totalOddsValueLabel.leadingAnchor.constraint(equalTo: self.totalOddsLabel.trailingAnchor),
            self.totalOddsValueLabel.centerYAnchor.constraint(equalTo: self.totalOddsLabel.centerYAnchor),

            self.selectionsLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            // self.selectionsLabel.topAnchor.constraint(equalTo: self.totalOddsLabel.bottomAnchor, constant: 10),
            self.selectionsLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -13),

            self.selectionsValueLabel.leadingAnchor.constraint(equalTo: self.selectionsLabel.trailingAnchor),
            self.selectionsValueLabel.centerYAnchor.constraint(equalTo: self.selectionsLabel.centerYAnchor),

            self.betButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.betButton.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 15),
            self.betButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
}
