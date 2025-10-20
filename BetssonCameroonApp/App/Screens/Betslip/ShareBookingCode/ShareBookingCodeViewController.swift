//
//  ShareBookingCodeViewController.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 15/10/2025.
//

import UIKit
import Combine
import GomaUI

final class ShareBookingCodeViewController: UIViewController {
    // MARK: Private properties
    private var viewModel: ShareBookingCodeViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Header elements
    private let headerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "share_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = "Share Betslip"
        label.numberOfLines = 1
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close_circle_icon"), for: .normal)
        return button
    }()

    // Content components
    private lazy var codeClipboardView: CodeClipboardView = {
        let view = CodeClipboardView(viewModel: viewModel.codeClipboardViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var shareButton: ButtonIconView = {
        let view = ButtonIconView(viewModel: viewModel.shareButtonViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initializer
    init(viewModel: ShareBookingCodeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupLayout()
        setupBindings()
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    // MARK: - Setup
    private func setupBindings() {
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        // Bind protocol callbacks
        viewModel.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        viewModel.onShare = { [weak self] code in
            self?.presentShareSheet(code: code)
        }
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(headerImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(codeClipboardView)
        containerView.addSubview(shareButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),

            // Header
            headerImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerImageView.widthAnchor.constraint(equalToConstant: 24),
            headerImageView.heightAnchor.constraint(equalToConstant: 24),

            closeButton.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -8),

            // Code clipboard block
            codeClipboardView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 20),
            codeClipboardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            codeClipboardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Share button
            shareButton.topAnchor.constraint(equalTo: codeClipboardView.bottomAnchor, constant: 20),
            shareButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    @objc private func didTapClose() {
        viewModel.closeRequested()
    }

    private func presentShareSheet(code: String) {
        let shareText = "Check out my betslip! Booking Code: \(code)"
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(activityViewController, animated: true)
    }
}


