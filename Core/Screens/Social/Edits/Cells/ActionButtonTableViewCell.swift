//
//  ActionButtonTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 10/05/2022.
//

import UIKit

class ActionButtonTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var actionButton: UIButton = Self.createActionButton()

    // MARK: Public Properties
    var didTapActionButtonCallback: (() -> Void)?

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.actionButton.backgroundColor = .clear
        self.actionButton.tintColor = UIColor.App.highlightSecondary
        self.actionButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

    }

    // MARK: Actions
    @objc func didTapActionButton() {
        self.didTapActionButtonCallback?()
    }
}

extension ActionButtonTableViewCell {

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add_orange_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.setTitle(localized("add_more_friends"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.separatorLineView)

        self.contentView.addSubview(self.actionButton)

        self.initConstraints()

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.separatorLineView.widthAnchor.constraint(equalToConstant: 40),
            self.separatorLineView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.actionButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.actionButton.heightAnchor.constraint(equalToConstant: 40),
            self.actionButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)

        ])

    }
}
