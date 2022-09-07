//
//  RankingTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 07/09/2022.
//

import UIKit
import Combine

struct Ranking {
    var id: Int
    var ranking: Int
    var username: String
    var score: Double

    init(id: Int, ranking: Int, username: String, score: Double) {
        self.id = id
        self.ranking = ranking
        self.username = username
        self.score = score
    }
}

class RankingCellViewModel {
    private var ranking: Ranking

    init(ranking: Ranking) {
        self.ranking = ranking
    }

    func getRanking() -> String {
        return "\(self.ranking.ranking)"
    }

    func getUsername() -> String {
        return self.ranking.username
    }

    func getRankingScore() -> String {
        return "\(self.ranking.score)"
    }
}

class RankingTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var rankingInfoStackView: UIStackView = Self.createRankingInfoStackView()
    private lazy var rankingBaseView: UIView = Self.createRankingBaseView()
    private lazy var rankingView: UIView = Self.createRankingView()
    private lazy var rankingLabel: UILabel = Self.createRankingLabel()
    private lazy var userImageBaseView: UIView = Self.createUserImageBaseView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var rankingScoreView: UIView = Self.createRankingScoreView()
    private lazy var rankingScoreLabel: UILabel = Self.createRankingScoreLabel()

    // MARK: Public Properties
    var viewModel: RankingCellViewModel?

    var shouldShowUserProfile: (() -> Void)?

    // MARK: - Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapUser = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        self.containerView.addGestureRecognizer(tapUser)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Layout and Theme
    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.rankingView.layer.cornerRadius = self.rankingView.frame.height / 2
        self.rankingView.layer.masksToBounds = true

        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.layer.masksToBounds = true

        self.rankingScoreView.layer.cornerRadius = CornerRadius.checkBox
        self.rankingScoreView.layer.masksToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.rankingInfoStackView.backgroundColor = .clear

        self.rankingBaseView.backgroundColor = .clear

        self.rankingView.backgroundColor = UIColor.App.highlightSecondary

        self.rankingLabel.textColor = UIColor.App.buttonTextPrimary

        self.userImageBaseView.backgroundColor = .clear

        self.userImageView.backgroundColor = .clear
        self.userImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.usernameLabel.textColor = UIColor.App.textPrimary

        self.rankingScoreView.backgroundColor = UIColor.App.backgroundCards

        self.rankingScoreLabel.textColor = UIColor.App.inputText
    }

    // MARK: Functions
    func configure(viewModel: RankingCellViewModel) {

        self.rankingLabel.text = viewModel.getRanking()

        self.usernameLabel.text = viewModel.getUsername()

        self.rankingScoreLabel.text = viewModel.getRankingScore()
    }

    // MARK: Actions
    @objc private func didTapUser() {
        self.shouldShowUserProfile?()
    }
}

extension RankingTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fillProportionally
        return stackView
    }

    private static func createRankingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }

    private static func createRankingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingLabel() -> UILabel {
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
        label.font = AppFont.with(type: .semibold, size: 14)
        return label
    }

    private static func createRankingScoreView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.rankingInfoStackView)

        self.rankingInfoStackView.addArrangedSubview(self.rankingBaseView)

        self.rankingBaseView.addSubview(self.rankingView)

        self.rankingView.addSubview(self.rankingLabel)

        self.rankingInfoStackView.addArrangedSubview(self.userImageBaseView)
        self.userImageBaseView.addSubview(self.userImageView)

        self.rankingInfoStackView.addArrangedSubview(self.usernameLabel)

        self.containerView.addSubview(self.rankingScoreView)

        self.rankingScoreView.addSubview(self.rankingScoreLabel)

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

        // Ranking Info stackview
        NSLayoutConstraint.activate([
            self.rankingInfoStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.rankingInfoStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.rankingInfoStackView.heightAnchor.constraint(equalToConstant: 40),
            self.rankingInfoStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -60),
            self.rankingInfoStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -5),

            self.rankingView.leadingAnchor.constraint(equalTo: self.rankingBaseView.leadingAnchor),
            self.rankingView.trailingAnchor.constraint(equalTo: self.rankingBaseView.trailingAnchor),
            self.rankingView.widthAnchor.constraint(equalToConstant: 17),
            self.rankingView.heightAnchor.constraint(equalTo: self.rankingView.widthAnchor),
            self.rankingView.centerYAnchor.constraint(equalTo: self.rankingBaseView.centerYAnchor),

            self.rankingLabel.leadingAnchor.constraint(equalTo: self.rankingView.leadingAnchor, constant: 4),
            self.rankingLabel.trailingAnchor.constraint(equalTo: self.rankingView.trailingAnchor, constant: -4),
            self.rankingLabel.centerYAnchor.constraint(equalTo: self.rankingView.centerYAnchor),

            self.userImageView.leadingAnchor.constraint(equalTo: self.userImageBaseView.leadingAnchor),
            self.userImageView.trailingAnchor.constraint(equalTo: self.userImageBaseView.trailingAnchor),
            self.userImageView.widthAnchor.constraint(equalToConstant: 26),
            self.userImageView.heightAnchor.constraint(equalTo: self.userImageView.widthAnchor),
            self.userImageView.centerYAnchor.constraint(equalTo: self.userImageBaseView.centerYAnchor),

            self.usernameLabel.centerYAnchor.constraint(equalTo: self.rankingInfoStackView.centerYAnchor),

            self.rankingScoreView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.rankingScoreView.heightAnchor.constraint(equalToConstant: 25),
            self.rankingScoreView.centerYAnchor.constraint(equalTo: self.rankingInfoStackView.centerYAnchor),

            self.rankingScoreLabel.leadingAnchor.constraint(equalTo: self.rankingScoreView.leadingAnchor, constant: 6),
            self.rankingScoreLabel.trailingAnchor.constraint(equalTo: self.rankingScoreView.trailingAnchor, constant: -6),
            self.rankingScoreLabel.centerYAnchor.constraint(equalTo: self.rankingScoreView.centerYAnchor)
        ])

    }
}
