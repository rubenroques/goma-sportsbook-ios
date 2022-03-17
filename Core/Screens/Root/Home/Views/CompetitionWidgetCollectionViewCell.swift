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
    
    private var viewModel: CompetitionWidgetViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOpenCompetition))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.titleLabel.text = ""
        self.flagImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.flagImageView.layer.cornerRadius = self.flagImageView.frame.size.width / 2
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

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.seeAllView.backgroundColor = UIColor.App.backgroundOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary
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
        seeAllLabel.text = "Open Competition Details"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        return seeAllLabel
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.baseStackView)

        self.topView.addSubview(self.flagImageView)
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
            self.contentView.heightAnchor.constraint(equalToConstant: 120),

            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.baseStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.baseStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.baseStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 16),
            self.baseStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -10),

            self.titleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.topView.leadingAnchor),

            self.flagImageView.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.flagImageView.trailingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor, constant: -5),
            self.flagImageView.widthAnchor.constraint(equalTo: self.flagImageView.heightAnchor),
            self.flagImageView.widthAnchor.constraint(equalToConstant: 16),

            //
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),

            self.seeAllView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor),
            self.seeAllView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor),
            self.seeAllView.topAnchor.constraint(equalTo: self.bottomView.topAnchor, constant: 2),
            self.seeAllView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 16),
        ])
    }
}
