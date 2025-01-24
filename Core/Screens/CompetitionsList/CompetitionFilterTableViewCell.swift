//
//  CompetitionFilterTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import Combine

enum CompetitionFilterCellMode {
    case toggle
    case navigate
}

class CompetitionFilterCellViewModel {

    var id: String
    var locationId: String
    var title: String
    var isSelected: Bool
    var isLastCell: Bool
    var country: Country?
    var mode: CompetitionFilterCellMode

    init(competition: Competition, locationId: String, isSelected: Bool, isLastCell: Bool, country: Country?, mode: CompetitionFilterCellMode) {
        self.id = competition.id
        self.title = competition.name
        self.locationId = locationId
        self.isSelected = isSelected
        self.isLastCell = isLastCell
        self.country = country
        self.mode = mode
    }

}

class CompetitionFilterTableViewCell: UITableViewCell {

    private var baseView: UIView = {
        var baseView  = UIView()
        // baseView.layer.cornerRadius = 5
        baseView.clipsToBounds = true
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()

    private var iconLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var separatorLineView: UIView = {
        var baseView  = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()

    private var countryImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.5
        return imageView
    }()

    private var titleLabel: UILabel = {
        var label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var selectedImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var navigationArrowImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nav_arrow_right_icon")
        return imageView
    }()

    private var viewModel: CompetitionFilterCellViewModel?

    var didToggleCellAction: ((String, String) -> Void)?
    var didTapNavigationAction: ((String) -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCell))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.configureAsNormalCell()

        self.viewModel = nil

        self.selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!
        self.titleLabel.text = ""

        self.countryImageView.image = nil
        self.selectedImageView.isHidden = false
        self.navigationArrowImageView.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryImageView.layer.cornerRadius = self.countryImageView.frame.size.width / 2
        self.countryImageView.layer.masksToBounds = true
    }

    func setCellSelected(_ selected: Bool) {
        if selected {
            selectedImageView.image = UIImage(named: "checkbox_selected_icon")!
        }
        else {
            selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!
        }
    }

    func setupSubviews() {

        self.selectionStyle = .none

        selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!

        self.iconLabelStackView.addArrangedSubview(self.countryImageView)
        self.iconLabelStackView.addArrangedSubview(self.titleLabel)
        self.iconLabelStackView.addArrangedSubview(self.navigationArrowImageView)

        self.contentView.addSubview(baseView)
        self.baseView.addSubview(iconLabelStackView)
        self.baseView.addSubview(separatorLineView)
        self.baseView.addSubview(selectedImageView)

        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: -26),
            self.contentView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 26),
            self.contentView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),

            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -16),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 16),
            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor),

            self.countryImageView.widthAnchor.constraint(equalToConstant: 16),
            self.countryImageView.heightAnchor.constraint(equalTo: self.countryImageView.widthAnchor),

            self.navigationArrowImageView.widthAnchor.constraint(equalToConstant: 19),
            self.navigationArrowImageView.heightAnchor.constraint(equalTo: self.navigationArrowImageView.widthAnchor),

            self.iconLabelStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.iconLabelStackView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.iconLabelStackView.trailingAnchor.constraint(greaterThanOrEqualTo: self.baseView.trailingAnchor, constant: -6),

            self.selectedImageView.widthAnchor.constraint(equalToConstant: 19),
            self.selectedImageView.widthAnchor.constraint(equalTo: self.selectedImageView.heightAnchor),
            self.selectedImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 1),
            self.selectedImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),

            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.countryImageView.backgroundColor = .clear
        self.countryImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor

    }

    func configure(withViewModel viewModel: CompetitionFilterCellViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = "Abc De" // viewModel.title

        switch viewModel.mode {
        case .toggle:
            self.selectedImageView.isHidden = false
            self.navigationArrowImageView.isHidden = true
            self.setCellSelected(viewModel.isSelected)
        case .navigate:
            self.selectedImageView.isHidden = true
            self.navigationArrowImageView.isHidden = false
        }

        if viewModel.isLastCell {
            self.configureAsLastCell()
        } else {
            self.configureAsNormalCell()
        }

        if let countryIsoCode = viewModel.country?.iso2Code {
            if countryIsoCode != "" {
                self.countryImageView.image = UIImage(named: Assets.flagName(withCountryCode: countryIsoCode))
            } else {
                self.countryImageView.image = UIImage(named: "country_flag_240")
            }
        } else {
            self.countryImageView.image = UIImage(named: "country_flag_240")
        }

        self.layoutSubviews()
        self.layoutIfNeeded()
    }

    func configureAsNormalCell() {
        self.separatorLineView.isHidden = false

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 0
        self.baseView.layer.maskedCorners = []
    }

    func configureAsLastCell() {
        self.separatorLineView.isHidden = true

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 5
        self.baseView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    @objc func didTapCell() {
        guard let viewModel = viewModel else { return }

        switch viewModel.mode {
        case .toggle:
            viewModel.isSelected.toggle()
            self.didToggleCellAction?(viewModel.id, viewModel.locationId)
        case .navigate:
            self.didTapNavigationAction?(viewModel.id)
        }
    }

}
