//
//  VersionUpdateViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 16/08/2021.
//

import UIKit

class VersionUpdateViewController: UIViewController {

    // MARK: - Properties

    private let updateRequired: Bool
    var dismissCallback: (() -> Void)?

    // MARK: - UI Components

    private lazy var brandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: TargetVariables.brandLogoAssetName)
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.with(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.setTitle(localized("update_app"), for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.setTitle(localized("dismiss_title"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [updateButton, dismissButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initialization

    init(updateRequired: Bool) {
        self.updateRequired = updateRequired
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = updateRequired

        setupViews()
        setupConstraints()
        configureContent()
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
        view.addSubview(buttonStackView)
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
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // Button stack at bottom
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),

            // Button heights
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureContent() {
        if updateRequired {
            titleLabel.text = localized("update_required_title")
            subtitleLabel.text = localized("update_required_text")
            dismissButton.isHidden = true
        } else {
            titleLabel.text = localized("update_available_title")
            subtitleLabel.text = localized("update_available_text")
            dismissButton.isHidden = false
        }
    }

    private func applyTheme() {
        view.backgroundColor = UIColor.App.backgroundPrimary

        // Labels
        titleLabel.textColor = UIColor.App.textPrimary
        subtitleLabel.textColor = UIColor.App.textPrimary

        // Primary button (Update App) - filled style
        updateButton.backgroundColor = UIColor.App.highlightPrimary
        updateButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        updateButton.layer.borderWidth = 1
        updateButton.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        // Secondary button (Dismiss) - text style
        dismissButton.backgroundColor = .clear
        dismissButton.setTitleColor(UIColor.App.textSecondary, for: .normal)
    }

    // MARK: - Actions

    @objc private func updateButtonTapped() {
        if let url = URL(string: TargetVariables.appStoreURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc private func dismissButtonTapped() {
        guard !updateRequired else { return }

        dismissCallback?()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Update Required - Light") {
    PreviewUIViewController {
        VersionUpdateViewController(updateRequired: true)
    }
    .preferredColorScheme(.light)
}

@available(iOS 17.0, *)
#Preview("Update Required - Dark") {
    PreviewUIViewController {
        VersionUpdateViewController(updateRequired: true)
    }
    .preferredColorScheme(.dark)
}

@available(iOS 17.0, *)
#Preview("Update Available - Light") {
    PreviewUIViewController {
        VersionUpdateViewController(updateRequired: false)
    }
    .preferredColorScheme(.light)
}

@available(iOS 17.0, *)
#Preview("Update Available - Dark") {
    PreviewUIViewController {
        VersionUpdateViewController(updateRequired: false)
    }
    .preferredColorScheme(.dark)
}
#endif
