//
//  BannerTournamentTableViewHeader.swift
//  Sportsbook
//
//  Created by André Lascas on 14/06/2024.
//

import UIKit
import Combine
import Kingfisher

class BannerTournamentTableViewHeader: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var countryFlagImageView: UIImageView = Self.createCountryFlagImageView()
    private lazy var nameTitleLabel: UILabel = Self.createNameTitleLabel()
    private lazy var favoriteLeagueBaseView: UIView = Self.createFavoriteLeagueBaseView()
    private lazy var favoriteLeagueImageView: UIImageView = Self.createFavoriteLeagueImageView()
    
    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    private var aspectRatio: CGFloat = 1.0

    var competition: Competition? {
        didSet {
            self.setupCompetition()
        }
    }
    
    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoriteLeagueImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoriteLeagueImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }
    
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    
    // MARK: - Lifetime and Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        let tapFavoriteGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteImageView))
        self.favoriteLeagueBaseView.addGestureRecognizer(tapFavoriteGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: "pt") )

        self.nameTitleLabel.text = ""

        self.isFavorite = false
    }

    // MARK: - Layout and Theme
    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryFlagImageView.layer.cornerRadius = self.countryFlagImageView.frame.size.width / 2

        self.countryFlagImageView.layer.borderWidth = 0.5
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.favoriteLeagueBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.nameTitleLabel.textColor = UIColor.App.buttonTextPrimary

        self.countryFlagImageView.backgroundColor = .clear
        self.countryFlagImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor
    }
    
    // MARK: Functions
    func configure(competition: Competition) {
        
        self.competition = competition
        self.nameTitleLabel.text = competition.name
        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
        
        if let featuredCompetitionTopBanner = Env.businessSettingsSocket.clientSettings.featuredCompetition?.pageDetailBanner {
            if let url = URL(string: featuredCompetitionTopBanner) {
                self.bannerImageView.kf.setImage(
                    with: url,
                    placeholder: nil,
                    options: [
                    ])
                {
                    result in
                    switch result {
                    case .success(let value):
                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        self.resizeBannerImageView(width: value.image.size.width, height: value.image.size.height)
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func resizeBannerImageView(width: CGFloat, height: CGFloat) {
        
        self.aspectRatio = width/height
        
        self.bannerImageViewFixedHeightConstraint.isActive = false
        
        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        
        self.bannerImageViewDynamicHeightConstraint.isActive = true
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    func setupCompetition() {
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value {
            if competitionId == self.competition!.id {
                self.isFavorite = true
            }
        }
    }
    
    func markAsFavorite(competition: Competition) {
        
        var isFavorite = false
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value where competitionId == competition.id {
            isFavorite = true
        }

        if Env.favoritesManager.isEventFavorite(eventId: competition.id) {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
            self.isFavorite = true
        }
    
    }
    
    // MARK: Actions
    @objc func didTapFavoriteImageView() {
        
        if Env.userSessionStore.isUserLogged() {
            if let competition = competition {
                self.markAsFavorite(competition: competition)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension BannerTournamentTableViewHeader {

    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = CornerRadius.view
        return imageView
    }
    
    private static func createCountryFlagImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createNameTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = ""
        label.font = AppFont.with(type: .bold, size: 15)
        label.textAlignment = .left
        return label
    }

    private static func createFavoriteLeagueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.squareView
        return view
    }
    
    private static func createFavoriteLeagueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_favorite_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    // Constraints
    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.bannerImageView)
        self.contentView.addSubview(self.countryFlagImageView)
        self.contentView.addSubview(self.nameTitleLabel)
        self.contentView.addSubview(self.favoriteLeagueBaseView)
        
        self.favoriteLeagueBaseView.addSubview(self.favoriteLeagueImageView)
        
        self.initConstraints()
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            
            self.bannerImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.bannerImageView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant: -14),
            self.bannerImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            
            self.countryFlagImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.countryFlagImageView.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 25),
            self.countryFlagImageView.widthAnchor.constraint(equalToConstant: 18),
            self.countryFlagImageView.heightAnchor.constraint(equalTo: self.countryFlagImageView.widthAnchor),
            self.countryFlagImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25),
            
            self.nameTitleLabel.leadingAnchor.constraint(equalTo: self.countryFlagImageView.trailingAnchor, constant: 5),
            self.nameTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 50),
            self.nameTitleLabel.centerYAnchor.constraint(equalTo: self.countryFlagImageView.centerYAnchor),
            
            self.favoriteLeagueBaseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.favoriteLeagueBaseView.centerYAnchor.constraint(equalTo: self.countryFlagImageView.centerYAnchor),
            self.favoriteLeagueBaseView.widthAnchor.constraint(equalToConstant: 27),
            self.favoriteLeagueBaseView.heightAnchor.constraint(equalTo: self.favoriteLeagueBaseView.widthAnchor),
            
            self.favoriteLeagueImageView.widthAnchor.constraint(equalToConstant: 17),
            self.favoriteLeagueImageView.heightAnchor.constraint(equalToConstant: 15),
            self.favoriteLeagueImageView.centerXAnchor.constraint(equalTo: self.favoriteLeagueBaseView.centerXAnchor),
            self.favoriteLeagueImageView.centerYAnchor.constraint(equalTo: self.favoriteLeagueBaseView.centerYAnchor)
        ])
        
        self.bannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 190)
        self.bannerImageViewFixedHeightConstraint.isActive = true

        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
    }
}
