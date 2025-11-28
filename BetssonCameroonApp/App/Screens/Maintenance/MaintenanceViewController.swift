//
//  MaintenanceViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 13/08/2021.
//

import UIKit

class MaintenanceViewController: UIViewController {

    // MARK: - UI Components

    private lazy var brandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "betsson_logo_orange")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "maintenance_mode")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = localized("maintenance_title")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.with(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = localized("maintenance_subtitle")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        
        setupViews()
        setupConstraints()
        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheme()
        }
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(brandImageView)
        view.addSubview(illustrationImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Brand logo at top
            brandImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            brandImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandImageView.heightAnchor.constraint(equalToConstant: 20),

            // Illustration centered vertically (offset slightly up)
            illustrationImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            illustrationImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            illustrationImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            illustrationImageView.heightAnchor.constraint(equalTo: illustrationImageView.widthAnchor, multiplier: 0.80),

            // Title below illustration
            titleLabel.topAnchor.constraint(equalTo: illustrationImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // Subtitle below title
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func applyTheme() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        titleLabel.textColor = UIColor.App.textPrimary
        subtitleLabel.textColor = UIColor.App.textPrimary
    }
}

// MARK: - Preview

import SwiftUI

@available(iOS 17.0, *)
#Preview("Light Mode") {
    PreviewUIViewController {
        MaintenanceViewController()
    }
    .preferredColorScheme(.light)
}

@available(iOS 17.0, *)
#Preview("Dark Mode") {
    PreviewUIViewController {
        MaintenanceViewController()
    }
    .preferredColorScheme(.dark)
}
