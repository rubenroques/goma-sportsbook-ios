//
//  SportStatisticView.swift
//  Sportsbook
//
//  Created by André Lascas on 23/09/2022.
//

import UIKit

class SportStatisticView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var progressBarView: UIProgressView = Self.createProgressBarView()
    private lazy var valueLabel: UILabel = Self.createValueLabel()

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

        self.containerView.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = .clear

        self.iconImageView.backgroundColor = .clear

        self.progressBarView.trackTintColor = UIColor.App.scroll
        self.progressBarView.progressTintColor = UIColor.App.statsAway

        self.valueLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    func configure(sportId: String, sportPercentage: Float) {

        if let sportIconImage = UIImage(named: "sport_type_icon_\(sportId)") {
            self.iconImageView.image = sportIconImage
        }
        else {
            self.iconImageView.image = UIImage(named: "sport_type_icon_default")
        }

        self.progressBarView.progress = sportPercentage

        let valueString = "\(Int(100 * sportPercentage))%"
        self.valueLabel.text = valueString
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension SportStatisticView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sport_type_soccer_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createProgressBarView() -> UIProgressView {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        return progressView
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "80%"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.progressBarView)

        self.containerView.addSubview(self.valueLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 4),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.progressBarView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.progressBarView.heightAnchor.constraint(equalToConstant: 5),
            self.progressBarView.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

            self.valueLabel.leadingAnchor.constraint(equalTo: self.progressBarView.trailingAnchor, constant: 5),
            self.valueLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -4),
            self.valueLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor)

        ])
    }
}
