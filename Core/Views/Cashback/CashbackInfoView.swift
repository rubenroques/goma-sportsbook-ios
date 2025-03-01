//
//  CashbackInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2023.
//

import UIKit
import SwiftUI

class CashbackInfoView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()

    var didTapInfoAction: (() -> Void) = { }

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.headerInput
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let infoTap = UITapGestureRecognizer(target: self, action: #selector(self.tapInfo))
        self.containerView.addGestureRecognizer(infoTap)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.highlightSecondary
        self.titleLabel.textColor = UIColor.App.buttonTextPrimary
        self.iconImageView.backgroundColor = .clear
    }

    @objc private func tapInfo() {
        self.didTapInfoAction()
    }
}

extension CashbackInfoView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("cashback")
        label.font = AppFont.with(type: .bold, size: 11)
        label.numberOfLines = 0
        return label
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "info_small_icon")
        imageView.contentMode = .center
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.iconImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 5),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 1),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 11),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor)
        ])

    }

}

#if DEBUG
// MARK: - Preview
@available(iOS 17.0, *)
#Preview("CashbackInfoView") {
    // Create container view with auto layout
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    // Create CashbackInfoView
    let cashbackView = CashbackInfoView()
    cashbackView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(cashbackView)

    // Setup constraints to show a reasonable preview size
    NSLayoutConstraint.activate([
        cashbackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
        cashbackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
        cashbackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
        container.heightAnchor.constraint(equalToConstant: 100),
        container.widthAnchor.constraint(equalToConstant: 200)
    ])

    // Add tap action for testing
    cashbackView.didTapInfoAction = {
        print("Info tapped in preview")
    }

    return container
}
#endif
