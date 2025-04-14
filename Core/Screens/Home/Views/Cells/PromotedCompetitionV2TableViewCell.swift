//
//  PromotedCompetitionV2TableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2025.
//

import UIKit
import Combine

class PromotedCompetitionV2TableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var gradientView: GradientView = Self.createGradientView()
    private lazy var containerGradientView: GradientView = Self.createContainerGradientView()
    private lazy var promoImageView: UIImageView = Self.createPromoImageView()
    private lazy var countryImageView: UIImageView = Self.createCountryImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    var didTapPromotedCompetition: ((String) -> Void)?
    
    var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCellContentView))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

//        self.promoImageView.kf.cancelDownloadTask()

    }
    
    // MARK: - Theme and Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.layoutIfNeeded()
        
        self.gradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.gradientView.layer.cornerRadius = CornerRadius.button

        self.containerGradientView.startPoint = CGPoint(x: 0.5, y: 1.0)
        self.containerGradientView.endPoint = CGPoint(x: 0.5, y: 0.0)
        self.containerGradientView.layer.cornerRadius = CornerRadius.button
        
        self.countryImageView.layer.cornerRadius = self.countryImageView.frame.width / 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.gradientView.colors = [(UIColor.App.highlightPrimary, NSNumber(0.0)),
                                    (UIColor.App.highlightTertiary, NSNumber(1.0))]
        
        self.containerGradientView.colors = [(UIColor.App.backgroundCards, NSNumber(0.0)),
                                             (UIColor.App.backgroundSecondary, NSNumber(1.0))]
        
        self.promoImageView.backgroundColor = .clear
        
        self.countryImageView.backgroundColor = .clear
        self.countryImageView.layer.borderColor = UIColor.App.buttonTextSecondary.cgColor
        
        self.titleLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Functions
    func configure() {
        if let featuredCompetition = Env.businessSettingsSocket.clientSettings.featuredCompetition,
           let featuredCompetitionId = featuredCompetition.id,
           let homeBanner = featuredCompetition.homeBanner,
           let url = URL(string: "\(homeBanner)") {
            
            self.promoImageView.kf.setImage(with: url)
            
            self.titleLabel.text = featuredCompetition.name ?? ""
            
            if let countryCode = featuredCompetition.regionCountry?.isoCode {
                
                self.countryImageView.layoutIfNeeded()
                self.countryImageView.image = UIImage(named: Assets.flagName(withCountryCode: countryCode))
            }
            else {
                self.countryImageView.layoutIfNeeded()
                self.countryImageView.image = UIImage(named: "country_flag_240")
            }
            
        }
        
    }
    
    // MARK: Actions
    @objc func didTapCellContentView() {
        if let featuredCompetition = Env.businessSettingsSocket.clientSettings.featuredCompetition,
           let competitionId = featuredCompetition.id {
            self.didTapPromotedCompetition?(competitionId)
            
        }
    }
}

extension PromotedCompetitionV2TableViewCell {

    private static func createGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.clipsToBounds = true
        return view
    }
    
    private static func createContainerGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.clipsToBounds = true
        return view
    }

    private static func createPromoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }
    
    private static func createCountryImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Competition"
        label.font = AppFont.with(type: .bold, size: 18)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.gradientView)
        
        self.gradientView.addSubview(self.containerGradientView)

        self.containerGradientView.addSubview(self.promoImageView)
        self.containerGradientView.addSubview(self.countryImageView)
        self.containerGradientView.addSubview(self.titleLabel)

        self.initConstraints()
        
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.gradientView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.gradientView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.gradientView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.gradientView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            self.gradientView.heightAnchor.constraint(equalToConstant: 155),
            
            self.containerGradientView.leadingAnchor.constraint(equalTo: self.gradientView.leadingAnchor),
            self.containerGradientView.trailingAnchor.constraint(equalTo: self.gradientView.trailingAnchor),
            self.containerGradientView.topAnchor.constraint(equalTo: self.gradientView.topAnchor),
            self.containerGradientView.bottomAnchor.constraint(equalTo: self.gradientView.bottomAnchor, constant: -2),
            
            self.promoImageView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.promoImageView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.promoImageView.topAnchor.constraint(equalTo: self.containerGradientView.topAnchor),
            self.promoImageView.heightAnchor.constraint(equalToConstant: 100),
//            self.promoImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
            
            self.countryImageView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 12),
            self.countryImageView.topAnchor.constraint(equalTo: self.promoImageView.bottomAnchor, constant: 12),
            self.countryImageView.bottomAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor, constant: -11),
            self.countryImageView.widthAnchor.constraint(equalToConstant: 24),
            self.countryImageView.heightAnchor.constraint(equalTo: self.countryImageView.widthAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.countryImageView.trailingAnchor, constant: 6),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -12),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.countryImageView.centerYAnchor)
        ])

    }
}
