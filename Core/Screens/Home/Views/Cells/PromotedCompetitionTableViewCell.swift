//
//  PromotedCompetitionTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 13/06/2024.
//

import UIKit

class PromotedCompetitionTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var promoImageView: UIImageView = Self.createPromoImageView()
    
    var didTapPromotedCompetition: ((String) -> Void)?

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
    
    // MARK: - Theme and Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        self.containerView.layer.cornerRadius = CornerRadius.view
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = .clear
        self.promoImageView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func configure() {
        if let featuredCompetition = Env.businessSettingsSocket.clientSettings.featuredCompetition,
           let featuredCompetitionId = featuredCompetition.id,
           let homeBanner = featuredCompetition.homeBanner,
           let url = URL(string: "\(homeBanner)") {
            self.promoImageView.kf.setImage(with: url)
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
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

extension PromotedCompetitionTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.clipsToBounds = true
        return view
    }

    private static func createPromoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.promoImageView)

        self.initConstraints()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2),
            // self.containerView.heightAnchor.constraint(equalToConstant: 100),
            
            self.promoImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.promoImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.promoImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.promoImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),
            self.promoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

    }
}
