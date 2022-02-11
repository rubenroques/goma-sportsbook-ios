//
//  SportLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/02/2022.
//

import UIKit

class SportLineTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = "Upcoming"
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    lazy var linesStackView: UIStackView = {
        var linesStackView = UIStackView()
        linesStackView.axis = .vertical
        linesStackView.alignment = .fill
        linesStackView.distribution = .fill
        linesStackView.spacing = 8
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }()

    lazy var topCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.alwaysBounceHorizontal = true
        return topCollectionView
    }()

    lazy var bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var bottomCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionView.showsVerticalScrollIndicator = false
        bottomCollectionView.showsHorizontalScrollIndicator = false
        bottomCollectionView.alwaysBounceHorizontal = true
        return bottomCollectionView
    }()

    lazy var seeAllView: UIView = {
        var seeAllView = UIView()
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        return seeAllView
    }()

    lazy var seeAllLabel: UILabel = {
        var seeAllLabel = UILabel()
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = "See All"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        return seeAllLabel
    }()

    var linesCollectionViews: [UICollectionView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.linesStackView.backgroundColor = .lightGray

        self.topCollectionView.backgroundView?.backgroundColor = .clear
        self.topCollectionView.backgroundColor = .clear

        self.bottomCollectionView.backgroundView?.backgroundColor = .clear
        self.bottomCollectionView.backgroundColor = .clear
    }
}

extension SportLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }

}

extension SportLineTableViewCell {

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.titleLabel)

        self.linesStackView.addArrangedSubview(self.topCollectionView)
        self.linesStackView.addArrangedSubview(self.bottomCollectionView)

        self.contentView.addSubview(self.linesStackView)

        self.contentView.addSubview(self.seeAllView)
        self.seeAllView.addSubview(self.seeAllLabel)

        self.topCollectionView.delegate = self
        self.bottomCollectionView.delegate = self

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([

            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 19),

            self.linesStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.linesStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.linesStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.linesStackView.bottomAnchor.constraint(equalTo: self.seeAllView.topAnchor, constant: -16),

            self.topCollectionView.heightAnchor.constraint(equalToConstant: 160),
            self.bottomCollectionView.heightAnchor.constraint(equalToConstant: 160),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.seeAllView.trailingAnchor, constant: 8),

            self.seeAllView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.seeAllView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.seeAllView.heightAnchor.constraint(equalToConstant: 34),
            self.seeAllView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 16),
     ])
    }
}
