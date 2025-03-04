//
//  GenericAlertView.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import UIKit

class GenericAlertView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var lineSeparatorView: UIView = Self.createLineSeparatorView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var textLabel: UILabel = Self.createTextLabel()

    // MARK: Public Properties
    var alertType: AlertType = .success {
        didSet {
            switch self.alertType {
            case .success:
                iconImageView.image = UIImage(named: "success_circle_icon")
                titleLabel.text = localized("success")
                titleLabel.textColor = UIColor.App.alertSuccess
                textLabel.text = localized("success_edit")
            case .error:
                iconImageView.image = UIImage(named: "error_input_icon")
                titleLabel.textColor = UIColor.App.alertError
                titleLabel.text = localized("error")
                textLabel.text = localized("error_edit")
            }
        }
    }

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.lineSeparatorView.backgroundColor = UIColor.App.separatorLineHighlightPrimary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.alertSuccess

        self.textLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    func configure(alertType: AlertType, text: String) {

        self.alertType = alertType

        self.textLabel.text = text
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension GenericAlertView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "success_circle_icon")
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("success")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("success_edit")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.lineSeparatorView)
        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.textLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.lineSeparatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.lineSeparatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.lineSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.lineSeparatorView.topAnchor.constraint(equalTo: self.containerView.topAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 3),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor, constant: 2),

            self.textLabel.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.textLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.textLabel.topAnchor.constraint(equalTo: self.titleLabel.topAnchor),
            self.textLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15)

        ])
    }
}
