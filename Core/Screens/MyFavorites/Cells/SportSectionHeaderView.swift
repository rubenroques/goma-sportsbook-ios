//
//  SportSectionHeaderView.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import UIKit

class SportSectionHeaderView: UITableViewHeaderFooterView {

    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var collapseLargeBaseView: UIView = Self.createCollapseLargeBaseView()
    private lazy var collapseBaseView: UIView = Self.createCollapseBaseView()
    private lazy var collapseImageView: UIImageView = Self.createCollapseImageView()

    // MARK: - Public Properties
    var sectionIndex: Int?
    var didToggleHeaderViewAction: ((Int) -> Void)?

    // MARK: - Lifetime and Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didToggleCell))
        collapseLargeBaseView.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.collapseImageView.image = UIImage(named: "arrow_up_icon")

        self.sectionIndex = nil
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.collapseBaseView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Cell configuration functions
    func configureHeader(title: String, sportTypeId: String) {
        self.titleLabel.text = title

        self.sportIconImageView.image = UIImage(named: "sport_type_mono_icon_\(sportTypeId)")
    }

    func setCollapseImage(isCollapsed: Bool) {
        if isCollapsed {
            self.collapseImageView.image = UIImage(named: "arrow_down_icon")
        }
        else {
            self.collapseImageView.image = UIImage(named: "arrow_up_icon")
        }
    }

}

//
// MARK: - Actions
//
extension SportSectionHeaderView {
    @objc func didToggleCell() {
        if let sectionIndex = sectionIndex {
            self.didToggleHeaderViewAction?(sectionIndex)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension SportSectionHeaderView {

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = "Sport"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createSportIconImageView() -> UIImageView {
        let sportIconImageView = UIImageView()
        sportIconImageView.contentMode = .scaleAspectFit
        sportIconImageView.layer.cornerRadius = sportIconImageView.frame.width/2
        sportIconImageView.image = UIImage(named: "sport_type_mono_icon_default")
        sportIconImageView.translatesAutoresizingMaskIntoConstraints = false
        return sportIconImageView
    }

    private static func createCollapseLargeBaseView() -> UIView {
        let collapseLargeView = UIView()
        collapseLargeView.translatesAutoresizingMaskIntoConstraints = false
        return collapseLargeView
    }

    private static func createCollapseBaseView() -> UIView {
        let collapseView = UIView()
        collapseView.translatesAutoresizingMaskIntoConstraints = false
        collapseView.layer.cornerRadius = 4
        return collapseView
    }

    private static func createCollapseImageView() -> UIImageView {
        let collapseImageView = UIImageView()
        collapseImageView.translatesAutoresizingMaskIntoConstraints = false
        collapseImageView.image = UIImage(named: "arrow_up_icon")
        collapseImageView.contentMode = .scaleAspectFit
        return collapseImageView
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.sportIconImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.collapseLargeBaseView)
        self.collapseLargeBaseView.addSubview(self.collapseBaseView)
        self.collapseBaseView.addSubview(self.collapseImageView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.sportIconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.sportIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.sportIconImageView.heightAnchor.constraint(equalToConstant: 15),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.sportIconImageView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.collapseLargeBaseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            self.collapseLargeBaseView.widthAnchor.constraint(equalToConstant: 33),
            self.collapseLargeBaseView.heightAnchor.constraint(equalToConstant: 33),
            self.collapseLargeBaseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.collapseBaseView.centerYAnchor.constraint(equalTo: self.collapseLargeBaseView.centerYAnchor),
            self.collapseBaseView.centerXAnchor.constraint(equalTo: self.collapseLargeBaseView.centerXAnchor),
            self.collapseBaseView.widthAnchor.constraint(equalToConstant: 27),
            self.collapseBaseView.heightAnchor.constraint(equalToConstant: 27),

            self.collapseImageView.widthAnchor.constraint(equalToConstant: 16),
            self.collapseImageView.heightAnchor.constraint(equalToConstant: 15),
            self.collapseImageView.centerYAnchor.constraint(equalTo: self.collapseBaseView.centerYAnchor),
            self.collapseImageView.centerXAnchor.constraint(equalTo: self.collapseBaseView.centerXAnchor)
        ])
    }
}
