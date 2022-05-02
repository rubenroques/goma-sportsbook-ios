//
//  CompetitionFilterTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import Combine

class CompetitionFilterCellViewModel {

    var id: String
    var locationId: String
    var title: String
    var isSelected: Bool
    var isLastCell: Bool

    init(competition: Competition, locationId: String, isSelected: Bool, isLastCell: Bool) {
        self.id = competition.id
        self.title = competition.name
        self.locationId = locationId
        self.isSelected = isSelected
        self.isLastCell = isLastCell
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

    private var separatorLineView: UIView = {
        var baseView  = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
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
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var viewModel: CompetitionFilterCellViewModel?

    var didTapCellAction: ((CompetitionFilterCellViewModel) -> Void)?

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
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if viewModel?.isLastCell ?? false {
//            baseView.clipsToBounds = true
//            baseView.layer.cornerRadius = 5
//            baseView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        }
//        else {
//            baseView.clipsToBounds = true
//            baseView.layer.cornerRadius = 0
//            baseView.layer.maskedCorners = []
//        }
//    }

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

        self.contentView.addSubview(baseView)
        baseView.addSubview(titleLabel)
        baseView.addSubview(separatorLineView)
        baseView.addSubview(selectedImageView)

        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: -26),
            self.contentView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 26),
            self.contentView.topAnchor.constraint(equalTo: baseView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

            baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),

            baseView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),
            baseView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -1),
            baseView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            baseView.leadingAnchor.constraint(equalTo: separatorLineView.leadingAnchor, constant: -16),
            baseView.trailingAnchor.constraint(equalTo: separatorLineView.trailingAnchor, constant: 16),
            baseView.bottomAnchor.constraint(equalTo: separatorLineView.bottomAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            titleLabel.heightAnchor.constraint(equalToConstant: 46),
            titleLabel.trailingAnchor.constraint(equalTo: selectedImageView.leadingAnchor, constant: -6),

            selectedImageView.widthAnchor.constraint(equalToConstant: 19),
            selectedImageView.widthAnchor.constraint(equalTo: selectedImageView.heightAnchor),
            selectedImageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: 1),
            selectedImageView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20),
        ])
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func configure(withViewModel viewModel: CompetitionFilterCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.title

        self.setCellSelected(viewModel.isSelected)

        if viewModel.isLastCell {
            self.configureAsLastCell()
        }
        else {
            self.configureAsNormalCell()
        }

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
        if let viewModel = viewModel {
            viewModel.isSelected.toggle()
            self.didTapCellAction?(viewModel)
        }
    }

}
