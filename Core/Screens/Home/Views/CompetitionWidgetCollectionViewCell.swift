//
//  CompetitionWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/02/2022.
//

import UIKit
import Combine

class CompetitionWidgetViewModel {

    var competition: Competition
    var name: String
    var countryImageName: String

    init(competition: Competition) {
        self.competition = competition
        self.name = competition.name

        if let isoCode = competition.venue?.isoCode {
            self.countryImageName = Assets.flagName(withCountryCode: isoCode)
        }
        else {
            self.countryImageName = "country_flag_240"
        }
    }

}

class CompetitionWidgetCollectionViewCell: UICollectionViewCell {

    var didSelectCompetitionAction: ((Competition) -> Void)?

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var baseStackView: UIStackView = Self.createBaseStackView()

    private lazy var topView: UIView = Self.createTopView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var flagImageView: UIImageView = Self.createFlagImageView()

    private lazy var bottomView: UIView = Self.createBottomView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    private var topMarginSpaceConstraint = NSLayoutConstraint()
    private var bottomMarginSpaceConstraint = NSLayoutConstraint()
    private var leadingMarginSpaceConstraint = NSLayoutConstraint()
    private var trailingMarginSpaceConstraint = NSLayoutConstraint()

    private var imageHeightConstraint = NSLayoutConstraint()
    private var buttonHeightConstraint = NSLayoutConstraint()

    private var cachedCardsStyle: CardsStyle?

    private var viewModel: CompetitionWidgetViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
        self.adjustDesignToCardStyle()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOpenCompetition))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)

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
        self.flagImageView.image = nil

        self.setupWithTheme()
        self.adjustDesignToCardStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.flagImageView.layer.cornerRadius = self.flagImageView.frame.size.width / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.seeAllView.backgroundColor = UIColor.App.backgroundOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary
    }

    private func adjustDesignToCardStyle() {

        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardStyle()
        case .normal:
            self.adjustDesignToNormalCardStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToSmallCardStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = -8
        self.bottomMarginSpaceConstraint.constant = -8

        self.imageHeightConstraint.constant = 12
        self.buttonHeightConstraint.constant = 27

        self.titleLabel.font = AppFont.with(type: .bold, size: 13)
    }

    private func adjustDesignToNormalCardStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = -12
        self.bottomMarginSpaceConstraint.constant = -12

        self.imageHeightConstraint.constant = 16
        self.buttonHeightConstraint.constant = 40

        self.titleLabel.font = AppFont.with(type: .bold, size: 14)
    }

    func configure(withViewModel viewModel: CompetitionWidgetViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.name
        self.flagImageView.image = UIImage(named: viewModel.countryImageName)
    }

    @objc func didTapOpenCompetition() {
        if let competition = self.viewModel?.competition {
            self.didSelectCompetitionAction?(competition)
        }
    }

}

extension CompetitionWidgetCollectionViewCell {

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
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createFlagImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
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
        seeAllLabel.text = localized("open_competition_details")
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        return seeAllLabel
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.flagImageView)
        self.baseView.addSubview(self.titleLabel)

        self.seeAllView.addSubview(self.seeAllLabel)
        self.baseView.addSubview(self.seeAllView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        self.imageHeightConstraint = self.flagImageView.widthAnchor.constraint(equalToConstant: 16)
        self.topMarginSpaceConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 11)

        self.leadingMarginSpaceConstraint = self.seeAllView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12)
        self.trailingMarginSpaceConstraint = self.seeAllView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12)
        self.bottomMarginSpaceConstraint = self.seeAllView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -12)
        self.buttonHeightConstraint = self.seeAllView.heightAnchor.constraint(equalToConstant: 40)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.seeAllView.leadingAnchor),
            self.topMarginSpaceConstraint,
            self.titleLabel.bottomAnchor.constraint(equalTo: self.seeAllView.topAnchor, constant: -6),

            self.flagImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor, constant: -1),
            self.flagImageView.trailingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor, constant: -5),
            self.flagImageView.widthAnchor.constraint(equalTo: self.flagImageView.heightAnchor),
            self.imageHeightConstraint,

            //
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),

            self.leadingMarginSpaceConstraint, // See All view
            self.trailingMarginSpaceConstraint, // See All view
            self.bottomMarginSpaceConstraint, // See All view
            self.buttonHeightConstraint, // See All view
        ])
    }
}
