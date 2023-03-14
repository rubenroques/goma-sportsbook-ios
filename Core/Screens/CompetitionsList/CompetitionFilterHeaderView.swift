//
//  CompetitionFilterHeaderView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit

class CompetitionFilterHeaderViewModel {

}

class CompetitionFilterHeaderView: UITableViewHeaderFooterView {

    private lazy var baseView: UIView = {
        var baseView  = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()

    private lazy var iconImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        var label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var selectedFiltersBaseView: UIView = {
        var baseView  = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()

    private lazy var selectedFiltersLabel: UILabel = {
        var label  = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.text = ""
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var isExpanded: Bool = true {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    var section: Int?

    var sectionIdentifier: String?

    var selectionCount: Int = 0 {
        didSet {
            self.selectedFiltersLabel.text = "\(selectionCount)"
            if selectionCount == 0 {
                self.selectedFiltersBaseView.isHidden = true
            }
            else {
                self.selectedFiltersBaseView.isHidden = false
            }
        }
    }

    var viewModel: CompetitionFilterSectionViewModel? {
        didSet {
            self.titleLabel.text = viewModel?.name ?? ""

            if let countryIsoCode = viewModel?.country?.iso2Code {
                if countryIsoCode != "" {
                    self.iconImageView.image = UIImage(named: Assets.flagName(withCountryCode: countryIsoCode))
                }
                else {
                    self.iconImageView.image = UIImage(named: "country_flag_240")
                }
            }
            else {
                self.iconImageView.image = UIImage(named: "country_flag_240")
            }

            // TEMP
            self.iconImageView.isHidden = true

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var delegate: CollapsibleTableViewHeaderDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapHeader() {

        guard let sectionIdentifier = sectionIdentifier else {
            return
        }
//
//        if self.isExpanded {
//            self.isExpanded = false
//            delegate?.didCollapseSection(section: section)
//        }
//        else {
//            self.isExpanded = true
//            delegate?.didExpandSection(section: section)
//        }

        self.delegate?.didToogleSection(sectionIdentifier: sectionIdentifier)
        self.isExpanded.toggle()
     }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.sectionIdentifier = nil
        self.section = nil
        self.isExpanded = false
        self.viewModel = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.selectedFiltersBaseView.layer.cornerRadius = self.selectedFiltersBaseView.frame.height / 2

        if self.isExpanded {
            baseView.layer.mask = nil
            baseView.roundCorners(corners: [.topLeft, .topRight], radius: 5)
            arrowImageView.image = UIImage(named: "arrow_up_icon")
        }
        else {
            baseView.layer.mask = nil
            baseView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5)
            arrowImageView.image = UIImage(named: "arrow_down_icon")
        }

        self.iconImageView.layer.cornerRadius = 18 / 2
    }

    func setupSubviews() {

        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.image = UIImage(named: "arrow_down_icon")

        self.selectedFiltersBaseView.addSubview(self.selectedFiltersLabel)
        self.selectedFiltersBaseView.isHidden = true

        self.addSubview(self.baseView)
        self.baseView.addSubview(self.iconImageView)
        self.baseView.addSubview(self.titleLabel)
        self.baseView.addSubview(self.arrowImageView)
        self.baseView.addSubview(self.selectedFiltersBaseView)

        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: -26),
            self.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 26),
            self.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            self.baseView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),
//
            self.baseView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -1),
//            self.baseView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 18),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

//            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -6),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -4),

            self.arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            self.arrowImageView.widthAnchor.constraint(equalTo: arrowImageView.heightAnchor),
            self.arrowImageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: 1),
            self.arrowImageView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20),

            self.selectedFiltersBaseView.trailingAnchor.constraint(equalTo: self.arrowImageView.leadingAnchor, constant: -8),
            self.selectedFiltersBaseView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: 1),
            self.selectedFiltersBaseView.widthAnchor.constraint(equalTo: self.selectedFiltersBaseView.heightAnchor),
            self.selectedFiltersBaseView.widthAnchor.constraint(equalToConstant: 24),

            self.selectedFiltersLabel.centerXAnchor.constraint(equalTo: self.selectedFiltersBaseView.centerXAnchor),
            self.selectedFiltersLabel.centerYAnchor.constraint(equalTo: self.selectedFiltersBaseView.centerYAnchor),
        ])

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.arrowImageView.backgroundColor = .clear

        self.selectedFiltersBaseView.backgroundColor = UIColor.App.highlightSecondary
        self.selectedFiltersLabel.textColor = UIColor.App.buttonTextPrimary

        self.iconImageView.backgroundColor = .clear
    }

}

protocol CollapsibleTableViewHeaderDelegate: AnyObject {
    func didToogleSection(sectionIdentifier: String)
}
