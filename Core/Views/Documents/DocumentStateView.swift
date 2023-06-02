//
//  DocumentStateView.swift
//  Sportsbook
//
//  Created by André Lascas on 02/06/2023.
//

import UIKit

class DocumentStateView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var stateView: UIView = Self.createStateView()
    private lazy var stateLabel: UILabel = Self.createStateLabel()

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

        self.stateView.layer.cornerRadius = CornerRadius.headerInput
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textSecondary

        self.dateLabel.textColor = UIColor.App.textSecondary

        self.stateView.backgroundColor = UIColor.App.alertSuccess

        self.stateLabel.textColor = UIColor.App.buttonTextPrimary
    }

    // MARK: Functions
    func configure(documentFileInfo: DocumentFileInfo) {

        self.titleLabel.text = documentFileInfo.name

        self.dateLabel.text = documentFileInfo.uploadDate.toString(formatString: "dd-MM-yyyy")

        switch documentFileInfo.status {
        case .approved:
            self.stateView.backgroundColor = UIColor.App.alertSuccess
        case .pendingApproved:
            self.stateView.backgroundColor = UIColor.App.statsAway
        case .failed:
            self.stateView.backgroundColor = UIColor.App.alertSuccess
        }

        self.stateLabel.text = documentFileInfo.status.statusName

    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension DocumentStateView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Document"
        label.font = AppFont.with(type: .bold, size: 14)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date"
        label.font = AppFont.with(type: .bold, size: 11)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }

    private static func createStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "State"
        label.font = AppFont.with(type: .bold, size: 11)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.stateView)

        self.stateView.addSubview(self.stateLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.stateView.leadingAnchor, constant: -8),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.dateLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.stateView.leadingAnchor, constant: -8),

            self.stateView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.stateView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.stateLabel.leadingAnchor.constraint(equalTo: self.stateView.leadingAnchor, constant: 6),
            self.stateLabel.trailingAnchor.constraint(equalTo: self.stateView.trailingAnchor, constant: -6),
            self.stateLabel.topAnchor.constraint(equalTo: self.stateView.topAnchor, constant: 4),
            self.stateLabel.bottomAnchor.constraint(equalTo: self.stateView.bottomAnchor, constant: -4)

        ])


    }
}
