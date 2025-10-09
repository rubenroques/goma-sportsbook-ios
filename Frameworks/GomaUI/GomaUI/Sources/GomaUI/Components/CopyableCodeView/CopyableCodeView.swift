import Foundation
import UIKit
import SwiftUI

/// A component for displaying and copying codes (booking codes, promo codes, referral codes, etc.)
public final class CopyableCodeView: UIView {

    // MARK: - Properties
    private let viewModel: CopyableCodeViewModelProtocol
    private var isShowingCopied = false
    private var resetTimer: Timer?

    // MARK: - UI Components

    private lazy var labelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 13)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var copiedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var copyIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "doc.on.doc.fill")
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    public init(viewModel: CopyableCodeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        resetTimer?.invalidate()
    }

    // MARK: - Setup
    private func setupSubviews() {
                
        backgroundColor = StyleProvider.Color.backgroundSecondary
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 4
        
        
        addSubview(labelLabel)
        addSubview(containerView)

        containerView.addSubview(codeLabel)
        containerView.addSubview(copiedLabel)
        containerView.addSubview(copyIconImageView)
        containerView.addSubview(copyButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Label on the left
            labelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Container on the right
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: labelLabel.trailingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 44),

            // Code label (inside container)
            codeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            codeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            codeLabel.trailingAnchor.constraint(equalTo: copyIconImageView.leadingAnchor, constant: -1),

            // Copied label (inside container, centered)
            copiedLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            copiedLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            copiedLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Copy icon (trailing inside container)
            copyIconImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            copyIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            copyIconImageView.widthAnchor.constraint(equalToConstant: 24),
            copyIconImageView.heightAnchor.constraint(equalToConstant: 24),

            // Copy button (covers entire container)
            copyButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            copyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            copyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    private func configure() {
        labelLabel.text = viewModel.label
        codeLabel.text = viewModel.code
        copiedLabel.text = viewModel.copiedMessage
    }

    // MARK: - Actions
    @objc private func copyButtonTapped() {
        guard !isShowingCopied else { return }

        viewModel.onCopyTapped()
        showCopiedState()
    }

    // MARK: - State Management
    private func showCopiedState() {
        isShowingCopied = true

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        // Animate transition
        UIView.transition(with: containerView, duration: 0.3, options: .transitionCrossDissolve) {
            self.codeLabel.isHidden = true
            self.copyIconImageView.isHidden = true
            self.copiedLabel.isHidden = false
        }

        // Auto-revert after 2 seconds
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.resetToNormalState()
        }
    }

    private func resetToNormalState() {
        guard isShowingCopied else { return }
        isShowingCopied = false

        UIView.transition(with: containerView, duration: 0.3, options: .transitionCrossDissolve) {
            self.codeLabel.isHidden = false
            self.copyIconImageView.isHidden = false
            self.copiedLabel.isHidden = true
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Booking Code") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockCopyableCodeViewModel.bookingCodeMock
        let codeView = CopyableCodeView(viewModel: mockViewModel)
        codeView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(codeView)

        NSLayoutConstraint.activate([
            codeView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            codeView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            codeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Promo Code") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockCopyableCodeViewModel.promoCodeMock
        let codeView = CopyableCodeView(viewModel: mockViewModel)
        codeView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(codeView)

        NSLayoutConstraint.activate([
            codeView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            codeView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            codeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Long Code") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockCopyableCodeViewModel.longCodeMock
        let codeView = CopyableCodeView(viewModel: mockViewModel)
        codeView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(codeView)

        NSLayoutConstraint.activate([
            codeView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            codeView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            codeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
