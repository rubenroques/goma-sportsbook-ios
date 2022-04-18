//
//  AddFriendTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var checkboxBaseView: UIView = Self.createCheckboxBaseView()
    private lazy var checkboxImageView: UIImageView = Self.createCheckboxImageView()

    var viewModel: AddFriendCellViewModel?

    // MARK: Public Properties
    var isCheckboxSelected: Bool = false {
        didSet {
            if isCheckboxSelected {
                self.checkboxImageView.image = UIImage(named: "checkbox_selected_icon")
            }
            else {
                self.checkboxImageView.image = UIImage(named: "checkbox_unselected_icon")
            }
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.isCheckboxSelected = false

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isCheckboxSelected = false

        self.titleLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.checkboxBaseView.backgroundColor = .clear

        self.checkboxImageView.backgroundColor = .clear

    }

    func configure(viewModel: AddFriendCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.username

        self.isCheckboxSelected = viewModel.isCheckboxSelected

    }

    // MARK: Actions
    @objc func didTapCheckbox(_ sender: UITapGestureRecognizer) {
        print("TAPPED CELL!")

        if let viewModel = self.viewModel {
            viewModel.isCheckboxSelected = !self.isCheckboxSelected
            self.isCheckboxSelected = viewModel.isCheckboxSelected
        }

    }

}

extension AddFriendTableViewCell {

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private static func createCheckboxBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCheckboxImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "checkbox_unselected_icon")
        imageView.contentMode = .scaleToFill
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.contentView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.checkboxBaseView)

        self.checkboxBaseView.addSubview(self.checkboxImageView)

        self.initConstraints()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCheckbox(_:)))
        self.checkboxBaseView.addGestureRecognizer(tapGesture)

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.iconBaseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 30),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.checkboxBaseView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 20),
            self.checkboxBaseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.checkboxBaseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.checkboxBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.checkboxBaseView.heightAnchor.constraint(equalTo: self.checkboxBaseView.widthAnchor),

            self.checkboxImageView.widthAnchor.constraint(equalToConstant: 20),
            self.checkboxImageView.heightAnchor.constraint(equalTo: self.checkboxImageView.widthAnchor),
            self.checkboxImageView.centerXAnchor.constraint(equalTo: self.checkboxBaseView.centerXAnchor),
            self.checkboxImageView.centerYAnchor.constraint(equalTo: self.checkboxBaseView.centerYAnchor)

        ])

    }
}
