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
        self.countryImageName = Assets.flagName(withCountryCode: competition.venue?.isoCode ?? "")
    }

}

class OutrightCompetitionLargeWidgetCollectionViewCell: UICollectionViewCell {

    var tappedLineAction: ((Competition) -> Void)?

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var baseStackView: UIStackView = Self.createBaseStackView()

    private lazy var competitionBaseStackView: UIStackView = Self.createCompetitionBaseStackView()

    private lazy var favoritesIconImageView: UIImageView = Self.createFavoritesIconImageView()
    private lazy var favoriteCompetitionButton: UIButton = Self.createFavoriteCompetitionButton()
    private lazy var countryFlagCompetitionImageView: UIImageView = Self.createCountryFlagCompetitionImageView()
    private lazy var countryNameCompetitionLabel: UILabel = Self.createCountryNameCompetitionLabel()

    private lazy var topView: UIView = Self.createTopView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var bottomView: UIView = Self.createBottomView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    private var topMarginSpaceConstraint = NSLayoutConstraint()
    private var bottomMarginSpaceConstraint = NSLayoutConstraint()
    private var leadingMarginSpaceConstraint = NSLayoutConstraint()
    private var trailingMarginSpaceConstraint = NSLayoutConstraint()

    private var headerHeightConstraint = NSLayoutConstraint()
    private var buttonHeightConstraint = NSLayoutConstraint()

    private var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoritesIconImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoritesIconImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }
    
    private var cachedCardsStyle: CardsStyle?

    private var viewModel: OutrightCompetitionLargeWidgetViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
        self.adjustDesignToCardStyle()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAll))
        self.contentView.addGestureRecognizer(tapGesture)

        self.favoriteCompetitionButton.addTarget(self, action: #selector(didTapFavoritesButton(_:)), for: .primaryActionTriggered)
        
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

        self.setupWithTheme()
        self.adjustDesignToCardStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryFlagCompetitionImageView.layer.cornerRadius = self.countryFlagCompetitionImageView.frame.size.width / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
        self.adjustDesignToCardStyle()
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

        self.headerHeightConstraint.constant = 12
        self.buttonHeightConstraint.constant = 27

        self.titleLabel.font = AppFont.with(type: .bold, size: 13)
    }

    private func adjustDesignToNormalCardStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = -12
        self.bottomMarginSpaceConstraint.constant = -12

        self.headerHeightConstraint.constant = 16
        self.buttonHeightConstraint.constant = 40

        self.titleLabel.font = AppFont.with(type: .bold, size: 14)
    }

    func configure(withViewModel viewModel: OutrightCompetitionLargeWidgetViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.name
        self.countryFlagCompetitionImageView.image = UIImage(named: viewModel.countryImageName)
        self.countryNameCompetitionLabel.text = viewModel.countryName
        
        self.isFavorite = Env.favoritesManager.isEventFavorite(eventId: viewModel.competition.id)
        
    }

    @objc func didTapSeeAll() {
        if let viewModel = viewModel {
            self.tappedLineAction?(viewModel.competition)
        }
    }
    
    func markAsFavorite(competition: Competition) {
        if Env.favoritesManager.isEventFavorite(eventId: competition.id) {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
            self.isFavorite = true
        }
    }

    @objc private func didTapFavoritesButton(_ sender: Any) {
        if UserSessionStore.isUserLogged() {
            if let competition = self.viewModel?.competition {
                self.markAsFavorite(competition: competition)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
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
    private static func createFavoritesIconImageView() -> UIImageView {
        let favoritesIconImageView = UIImageView()
        favoritesIconImageView.translatesAutoresizingMaskIntoConstraints = false
        favoritesIconImageView.image = UIImage(named: "unselected_favorite_icon")
        return favoritesIconImageView
    }
    private static func createFavoriteCompetitionButton() -> UIButton {
        let favoriteCompetitionButton = UIButton(type: .custom)
        favoriteCompetitionButton.backgroundColor = .clear
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

        self.competitionBaseStackView.addArrangedSubview(self.favoritesIconImageView)
        self.competitionBaseStackView.addArrangedSubview(self.countryFlagCompetitionImageView)
        self.competitionBaseStackView.addArrangedSubview(self.countryNameCompetitionLabel)

        self.baseView.addSubview(self.titleLabel)

        self.seeAllView.addSubview(self.seeAllLabel)
        self.baseView.addSubview(self.seeAllView)

        self.baseView.addSubview(self.favoriteCompetitionButton)
        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        self.topMarginSpaceConstraint = self.competitionBaseStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 11)
        self.headerHeightConstraint = self.countryFlagCompetitionImageView.heightAnchor.constraint(equalToConstant: 16)

        self.buttonHeightConstraint = self.seeAllView.heightAnchor.constraint(equalToConstant: 40)

        self.leadingMarginSpaceConstraint = self.seeAllView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12)
        self.trailingMarginSpaceConstraint = self.seeAllView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12)
        self.bottomMarginSpaceConstraint = self.seeAllView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -12)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.competitionBaseStackView.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),
            self.competitionBaseStackView.trailingAnchor.constraint(equalTo: self.seeAllView.trailingAnchor),
            self.topMarginSpaceConstraint,

            self.favoritesIconImageView.heightAnchor.constraint(equalTo: self.favoritesIconImageView.widthAnchor),
            self.countryFlagCompetitionImageView.heightAnchor.constraint(equalTo: self.countryFlagCompetitionImageView.widthAnchor),
            self.headerHeightConstraint,

            //
            self.titleLabel.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.seeAllView.trailingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.competitionBaseStackView.bottomAnchor, constant: 6),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.seeAllView.topAnchor, constant: -6),

            //
            self.favoriteCompetitionButton.heightAnchor.constraint(equalToConstant: 40),
            self.favoriteCompetitionButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoriteCompetitionButton.centerXAnchor.constraint(equalTo: self.favoritesIconImageView.centerXAnchor),
            self.favoriteCompetitionButton.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            
            //
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor),

            self.leadingMarginSpaceConstraint, // SeeAll view
            self.trailingMarginSpaceConstraint, // SeeAll view
            self.bottomMarginSpaceConstraint, // SeeAll view
            self.buttonHeightConstraint, // SeeAll view
        ])
    }
}
