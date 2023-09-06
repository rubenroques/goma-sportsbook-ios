//
//  TopCompetitionItemCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit

struct TopCompetitionItemCellViewModel {

    var id: String
    var name: String
    var sport: Sport
    var country: Country?

    init(id: String, name: String, sport: Sport, country: Country?) {
        self.id = id
        self.name = name
        self.sport = sport
        self.country = country
    }

}

class TopCompetitionItemCollectionViewCell: UICollectionViewCell {

    var selectedItemAction: (TopCompetitionItemCellViewModel) -> Void = { _ in }

    private let baseView: UIView = {
        let baseView = UIView()
        baseView.layer.cornerRadius = 8
        baseView.layer.masksToBounds = true
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.clipsToBounds = true
        return baseView
    }()

    private let iconsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.clipsToBounds = true
        return stackView
    }()

    private let sportImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let countryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.5
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = "Top Competition Name"
        label.textColor = .white
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }()

    private var viewModel: TopCompetitionItemCellViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    private func commonInit() {

        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        self.addGestureRecognizer(nextTapGesture)

        self.setupViews()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.sportImageView.layer.cornerRadius = self.sportImageView.frame.height / 2
        self.countryImageView.layer.cornerRadius = self.countryImageView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.baseView.layer.borderWidth = 1
        self.baseView.layer.borderColor = UIColor.App.backgroundOdds.cgColor

        self.nameLabel.textColor = UIColor.App.textPrimary

        self.countryImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor

    }

    private func setupViews() {

        self.iconsStackView.addArrangedSubview(self.sportImageView)
        self.iconsStackView.addArrangedSubview(self.countryImageView)

        self.baseView.addSubview(self.iconsStackView)
        self.baseView.addSubview(self.nameLabel)

        self.addSubview(self.baseView)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconsStackView.heightAnchor.constraint(equalToConstant: 18),
            self.iconsStackView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.iconsStackView.bottomAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: -4),

            self.nameLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 4),
            self.nameLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -4),
            self.nameLabel.topAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 8),

            self.sportImageView.widthAnchor.constraint(equalTo: self.sportImageView.heightAnchor),

            self.countryImageView.widthAnchor.constraint(equalTo: self.countryImageView.heightAnchor),

        ])
    }

    // Configure the cell with your data
    func configureWithViewModel(_ viewModel: TopCompetitionItemCellViewModel) {
        self.viewModel = viewModel

        self.nameLabel.text = viewModel.name

        if let sportIconImage = UIImage(named: "sport_type_icon_\(viewModel.sport.id)") {
            self.sportImageView.image = sportIconImage
            self.sportImageView.setImageColor(color: UIColor.App.textPrimary)
        }
        else {
            self.sportImageView.image = UIImage(named: "sport_type_icon_default")
            self.sportImageView.setImageColor(color: UIColor.App.textPrimary)
        }

        if let country = viewModel.country {
            self.countryImageView.image = UIImage(named: Assets.flagName(withCountryCode: country.iso2Code))
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc func didTapItemView() {
        if let viewModel = self.viewModel {
            self.selectedItemAction(viewModel)
        }
    }

}
