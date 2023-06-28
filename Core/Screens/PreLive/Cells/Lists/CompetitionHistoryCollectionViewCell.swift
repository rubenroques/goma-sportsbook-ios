//
//  CompetitionHistoryCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 28/06/2023.
//

import UIKit

class CompetitionHistoryCollectionViewCell: UICollectionViewCell {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    var competition: Competition?

    var didTapCloseAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.filter

        self.containerView.layer.borderWidth = 1
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()

    }

    func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.pillNavigation

        self.containerView.layer.borderColor = UIColor.App.buttonActiveHoverTertiary.cgColor

        self.titleLabel.textColor = UIColor.App.textSecondary

        self.closeButton.backgroundColor = .clear

    }

    func setupInfo(competition: Competition) {
        self.titleLabel.text = competition.name

        self.competition = competition
    }

    @objc private func didTapCloseButton() {
        print("CLOSE COMPETITION FILTER!")
        self.didTapCloseAction?()
    }
}

extension CompetitionHistoryCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "x_close_circle_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.closeButton)
        self.initConstraints()

        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 22),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.closeButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 3),
            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.closeButton.widthAnchor.constraint(equalToConstant: 10),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor)

        ])
    }
}
