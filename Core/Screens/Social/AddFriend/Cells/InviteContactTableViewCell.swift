//
//  InviteContactTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 12/09/2022.
//

import UIKit

class InviteContactTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var inviteButton: UIButton = Self.createInviteButton()

    // MARK: Public Properties
    var didTapInviteAction: (() -> Void)?

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.inviteButton.addTarget(self, action: #selector(didTapInviteButton), for: .primaryActionTriggered)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.inviteButton.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.inviteButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

    }

    // MARK: Actions
    @objc func didTapInviteButton() {

        self.didTapInviteAction?()

    }

}

extension InviteContactTableViewCell {

    private static func createInviteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("invite_friends_via"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.layer.cornerRadius = CornerRadius.button
        // button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        button.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30), imageTitlePadding: CGFloat(0))
        return button
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.inviteButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.inviteButton.heightAnchor.constraint(equalToConstant: 40),
            self.inviteButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.inviteButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15),
            self.inviteButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)

        ])

    }
}
