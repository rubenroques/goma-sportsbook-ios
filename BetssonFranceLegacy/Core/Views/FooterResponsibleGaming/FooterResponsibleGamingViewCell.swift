//
//  FooterResponsibleGamingViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2023.
//

import Foundation
import UIKit

class FooterResponsibleGamingViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var footerResponsibleGamingView: FooterResponsibleGamingView = Self.createFooterResponsibleGamingView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.commonInit()
        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.footerResponsibleGamingView.hideLinksView()
        self.footerResponsibleGamingView.hideSocialView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

}

extension FooterResponsibleGamingViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createFooterResponsibleGamingView() -> FooterResponsibleGamingView {
        let footerResponsibleGamingView = FooterResponsibleGamingView()
        footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false
        return footerResponsibleGamingView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.footerResponsibleGamingView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 24),
            self.footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -18),
            self.footerResponsibleGamingView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 12),
            self.footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -36),
        ])
    }

}
