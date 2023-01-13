//
//  DocumentView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/01/2023.
//

import UIKit

class DocumentView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.card

        self.statusView.layer.cornerRadius = CornerRadius.headerInput
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.statusView.backgroundColor = UIColor.App.bubblesPrimary

        self.statusLabel.textColor = UIColor.App.buttonTextPrimary
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension DocumentView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Document Title"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Status"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.statusView)

        self.statusView.addSubview(self.statusLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),


            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 19),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -40),

            self.statusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.statusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 10),
            self.statusView.heightAnchor.constraint(equalToConstant: 18),
            self.statusView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

            self.statusLabel.leadingAnchor.constraint(equalTo: self.statusView.leadingAnchor, constant: 5),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.statusView.trailingAnchor, constant: -5),
            self.statusLabel.centerXAnchor.constraint(equalTo: self.statusView.centerXAnchor),
            self.statusLabel.centerYAnchor.constraint(equalTo: self.statusView.centerYAnchor)
        ])
    }
}
