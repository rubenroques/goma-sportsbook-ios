//
//  OutrightCompetitionLargeWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/02/2022.
//

import UIKit
import Combine


class OutrightCompetitionLargeWidgetViewModel {

    var competition: Competition
    var name: String
    var countryImageName: String
    var countryName: String

    init(competition: Competition) {
        self.competition = competition
        self.name = competition.name

        self.countryName = competition.venue?.name ?? ""

        if let isoCode = competition.venue?.isoCode {
            self.countryImageName = Assets.flagName(withCountryCode: isoCode)
        }
        else {
            self.countryImageName = "country_flag_240"
        }
    }

}

class OutrightCompetitionLargeWidgetCollectionViewCell: UICollectionViewCell {

    var tappedLineAction: ((Competition) -> Void)?

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var baseStackView: UIStackView = Self.createBaseStackView()

    private lazy var competitionBaseStackView: UIStackView = Self.createCompetitionBaseStackView()

    private lazy var favoriteCompetitionButton: UIButton = Self.createFavoriteCompetitionButton()
    private lazy var countryFlagCompetitionImageView: UIImageView = Self.createCountryFlagCompetitionImageView()
    private lazy var countryNameCompetitionLabel: UILabel = Self.createCountryNameCompetitionLabel()

    private lazy var topView: UIView = Self.createTopView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var bottomView: UIView = Self.createBottomView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    private var viewModel: OutrightCompetitionLargeWidgetViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAll))
        self.contentView.addGestureRecognizer(tapGesture)

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.titleLabel.text = ""

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryFlagCompetitionImageView.layer.cornerRadius = self.countryFlagCompetitionImageView.frame.size.width / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.countryNameCompetitionLabel.textColor = UIColor.App.textSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.seeAllView.backgroundColor = UIColor.App.backgroundOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: OutrightCompetitionLargeWidgetViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.name
        self.countryFlagCompetitionImageView.image = UIImage(named: viewModel.countryImageName)
        self.countryNameCompetitionLabel.text = viewModel.countryName
    }

    @objc func didTapSeeAll() {
        if let viewModel = viewModel {
            self.tappedLineAction?(viewModel.competition)
        }
    }

}

extension OutrightCompetitionLargeWidgetCollectionViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        return view
    }

    private static func createBaseStackView() -> UIStackView {
        let linesStackView = UIStackView()
        linesStackView.axis = .vertical
        linesStackView.alignment = .fill
        linesStackView.distribution = .fillEqually
        linesStackView.spacing = 9
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }

    private static func createCompetitionBaseStackView() -> UIStackView {
        let linesStackView = UIStackView()
        linesStackView.axis = .horizontal
        linesStackView.alignment = .fill
        linesStackView.spacing = 7
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }

    private static func createFavoriteCompetitionButton() -> UIButton {
        let favoriteCompetitionButton = UIButton(type: .custom)
        favoriteCompetitionButton.setImage(UIImage(named: "unselected_favorite_icon"), for: .normal)
        favoriteCompetitionButton.translatesAutoresizingMaskIntoConstraints = false
        return favoriteCompetitionButton
    }
    private static func createCountryFlagCompetitionImageView() -> UIImageView {
        let countryFlagCompetitionButton = UIImageView()
        countryFlagCompetitionButton.clipsToBounds = true
        countryFlagCompetitionButton.image = UIImage(named: "country_flag_240")
        countryFlagCompetitionButton.translatesAutoresizingMaskIntoConstraints = false
        return countryFlagCompetitionButton
    }
    private static func createCountryNameCompetitionLabel() -> UILabel {
        let countryNameCompetitionLabel = UILabel()
        countryNameCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)
        countryNameCompetitionLabel.translatesAutoresizingMaskIntoConstraints = false
        return countryNameCompetitionLabel
    }

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.text = "NBA"
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }


    private static func createBottomView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSeeAllView() -> UIView {
        let seeAllView = UIView()
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        seeAllView.layer.borderColor = UIColor.gray.cgColor
        seeAllView.layer.borderWidth = 0
        seeAllView.layer.cornerRadius = 6
        return seeAllView
    }

    private static func createSeeAllLabel() -> UILabel {
        let seeAllLabel = UILabel()
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = "View Competition Markets"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        return seeAllLabel
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.competitionBaseStackView)

        self.competitionBaseStackView.addArrangedSubview(favoriteCompetitionButton)
        self.competitionBaseStackView.addArrangedSubview(countryFlagCompetitionImageView)
        self.competitionBaseStackView.addArrangedSubview(countryNameCompetitionLabel)

        self.baseView.addSubview(self.baseStackView)

        self.topView.addSubview(self.titleLabel)

        self.bottomView.addSubview(self.seeAllView)

        self.seeAllView.addSubview(self.seeAllLabel)

        self.baseStackView.addArrangedSubview(self.topView)
        self.baseStackView.addArrangedSubview(self.bottomView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.competitionBaseStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12),
            self.competitionBaseStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12),
            self.competitionBaseStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 9),

            self.favoriteCompetitionButton.heightAnchor.constraint(equalTo: self.favoriteCompetitionButton.widthAnchor),
            self.countryFlagCompetitionImageView.heightAnchor.constraint(equalTo: self.countryFlagCompetitionImageView.widthAnchor),
            self.countryFlagCompetitionImageView.heightAnchor.constraint(equalToConstant: 16),

            self.baseStackView.topAnchor.constraint(equalTo: self.competitionBaseStackView.bottomAnchor, constant: 9),
            self.baseStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.baseStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.baseStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -10),

            self.titleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.topView.leadingAnchor),

            //
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),

            self.seeAllView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor),
            self.seeAllView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor),
            self.seeAllView.heightAnchor.constraint(equalToConstant: 40),
            self.seeAllView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 16),
        ])
    }
}
