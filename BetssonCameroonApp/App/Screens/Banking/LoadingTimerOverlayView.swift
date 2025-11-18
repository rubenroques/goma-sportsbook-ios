//
//  LoadingTimerOverlayView.swift
//  BetssonCameroonApp
//
//  Created for visual timing display of deposit/withdraw loading phases
//  Displays APP, API, and WEB phase timing with color coding
//

import UIKit

final class LoadingTimerOverlayView: UIView {

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let phaseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.95)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let responsibilityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.85)
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let topStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        return view
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "doc.on.doc", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        return button
    }()

    // MARK: - Properties

    private var timer: Timer?
    private var metrics: BankingTimingMetrics

    /// Callback to get the cashier URL for copying
    var onCopyRequested: (() -> String?)?

    // MARK: - Initialization

    init(metrics: BankingTimingMetrics) {
        self.metrics = metrics
        super.init(frame: .zero)
        setupUI()
        startTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopTimer()
    }

    // MARK: - Setup

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(closeButton)
        containerView.addSubview(copyButton)

        topStackView.addArrangedSubview(phaseLabel)
        topStackView.addArrangedSubview(timerLabel)

        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(responsibilityLabel)
        stackView.addArrangedSubview(summaryLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -90), // Leave space for buttons
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // Close button in top-right corner
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            // Copy button to the left of close button
            copyButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            copyButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            copyButton.widthAnchor.constraint(equalToConstant: 32),
            copyButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        updateUI()
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateUI()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Public Methods

    func updateMetrics(_ metrics: BankingTimingMetrics) {
        self.metrics = metrics
        updateUI()
    }

    func hideOverlay() {
        // Stop the timer before hiding
        stopTimer()

        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - UI Updates

    private func updateUI() {
        let phase = metrics.currentPhase
        phaseLabel.text = phase.displayName

        // Show elapsed time - stop counting when fully ready
        if phase == .webViewFullyReady || phase == .completed {
            // Use total duration (frozen value)
            if let totalDuration = metrics.totalDuration {
                timerLabel.text = String(format: "%.3fs", totalDuration)
            }
            // Stop the timer once we're fully ready
            stopTimer()
        } else {
            // Still loading - show real-time elapsed
            let elapsedTime = metrics.elapsedTime()
            timerLabel.text = String(format: "%.3fs", elapsedTime)
        }

        // Update background color based on responsibility
        let responsibility = phase.responsibility
        let colorTuple = responsibility.color
        let backgroundColor = UIColor(
            red: colorTuple.red,
            green: colorTuple.green,
            blue: colorTuple.blue,
            alpha: 0.9
        )

        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = backgroundColor
        }

        // Update responsibility indicator
        responsibilityLabel.text = responsibility.displayName

        // Update summary
        updateSummary()
    }

    private func updateSummary() {
        var summaryParts: [String] = []

        if let appDuration = metrics.appDuration {
            summaryParts.append("APP render+parse: \(String(format: "%.3fs", appDuration))")
        }

        if let apiDuration = metrics.apiDuration {
            summaryParts.append("Cashier API (get url): \(String(format: "%.3fs", apiDuration))")
        }

        if let webDuration = metrics.webDuration {
            summaryParts.append("Cashier WEB (webpage rendering): \(String(format: "%.3fs", webDuration))")
        }

        if summaryParts.count >= 2 {
            if let totalDuration = metrics.totalDuration {
                summaryParts.append("TOTAL: \(String(format: "%.3fs", totalDuration))")
            }
        }

        if !summaryParts.isEmpty {
            summaryLabel.text = summaryParts.joined(separator: "\n")
            summaryLabel.isHidden = false
        } else {
            summaryLabel.text = "Measuring performance..."
            summaryLabel.isHidden = false
        }
    }

    // MARK: - Button Actions

    @objc private func copyButtonTapped() {
        // Build formatted report
        var report = "Banking Flow Timing Report\n"
        report += "-------------------------\n"
        report += "APP: \(metrics.formattedAppDuration)\n"
        report += "API: \(metrics.formattedApiDuration)\n"
        report += "WEB: \(metrics.formattedWebDuration)\n"
        report += "TOTAL: \(metrics.formattedTotalDuration)\n"
        report += "-------------------------\n"

        // Add URL if available
        if let url = onCopyRequested?() {
            report += "URL: \(url)\n"
        }

        // Copy to clipboard
        UIPasteboard.general.string = report

        // Show visual feedback
        showCopyFeedback()

        print("📋 Timing report copied to clipboard")
    }

    @objc private func closeButtonTapped() {
        hideOverlay()
    }

    private func showCopyFeedback() {
        // Briefly change copy button to checkmark
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let checkmark = UIImage(systemName: "checkmark", withConfiguration: config)

        copyButton.setImage(checkmark, for: .normal)

        // Revert back after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let copyIcon = UIImage(systemName: "doc.on.doc", withConfiguration: config)
            self?.copyButton.setImage(copyIcon, for: .normal)
        }
    }
}
