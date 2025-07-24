//
//  SettingsTitleView.swift
//  MultiBet
//
//  Created by André Lascas on 20/11/2024.
//

import UIKit

class SettingsTitleView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

}

//
// MARK: Subviews initialization and setup
//
extension SettingsTitleView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            self.containerView.heightAnchor.constraint(equalToConstant: 30),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),


        ])

    }

}

