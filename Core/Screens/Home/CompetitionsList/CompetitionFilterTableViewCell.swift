//
//  CompetitionFilterTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import Combine

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

    var titleLabel: UILabel = {
        var label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var selectedImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var isCellSelected: Bool = false
    var isLastCell: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.titleLabel.text = "Competition Name and selector"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {        
        super.prepareForReuse()

        self.configureAsNormalCell()

        self.selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!
        self.titleLabel.text = ""
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isLastCell {
            baseView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
        }
        else {
            baseView.layer.mask = nil
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            selectedImageView.image = UIImage(named: "checkbox_selected_icon")!
        }
        else {
            selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!
        }
    }

    func setCellSelected(_ selected: Bool) {
        self.isCellSelected = selected

        if self.isCellSelected {
            selectedImageView.image = UIImage(named: "checkbox_selected_icon")!
        }
        else {
            selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!
        }
    }

    func setupSubviews() {

        self.selectionStyle = .none

        selectedImageView.image = UIImage(named: "checkbox_unselected_icon")!

        self.addSubview(baseView)
        baseView.addSubview(titleLabel)
        baseView.addSubview(separatorLineView)
        baseView.addSubview(selectedImageView)

        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: -26),
            self.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 26),
            self.topAnchor.constraint(equalTo: baseView.topAnchor),
            self.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

            baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

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

        baseView.backgroundColor = UIColor.App2.backgroundPrimary
        titleLabel.textColor = UIColor.App2.textPrimary
        separatorLineView.backgroundColor = UIColor.App2.separatorLine
    }

    func configureAsNormalCell() {
        baseView.layer.mask = nil
        self.isLastCell = false
        self.separatorLineView.isHidden = false
    }

    func configureAsLastCell() {
        self.isLastCell = true
        self.separatorLineView.isHidden = true
    }

}
