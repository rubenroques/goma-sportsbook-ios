//
//  FloatingOverlayView.swift
//  GomaUI
//
//  Created on 06/04/2025.
//

import UIKit
import Combine
import SwiftUI

final public class FloatingOverlayView: UIView {
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var contentStackView: UIStackView = Self.createStackView()
    
    // MARK: - Properties
    private let viewModel: FloatingOverlayViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var dismissTimer: Timer?
    private var isAnimating = false
    
    // MARK: - Public Properties
    public var onTap: (() -> Void)?
    
    // MARK: - Initialization
    public init(viewModel: FloatingOverlayViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        setupViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
        setupBindings()
        setupGestures()
    }
    
    private func setupViewHierarchy() {
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(messageLabel)
        containerView.addSubview(contentStackView)
        addSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container to self
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view in container
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Icon size
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupAdditionalConfiguration() {
        
        self.backgroundColor = .clear
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: 50).scaledBy(x: 0.95, y: 0.95)
        
        self.containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.messageLabel.textColor = StyleProvider.Color.textPrimary
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Rendering
    private func render(state: FloatingOverlayDisplayState) {
        iconImageView.image = state.mode.icon
        messageLabel.text = state.mode.message
        
        if state.isVisible {
            showWithAnimation(duration: state.duration)
        } else {
            hideWithAnimation()
        }
    }
    
    // MARK: - Animations
    private func showWithAnimation(duration: TimeInterval?) {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Cancel any existing timer
        dismissTimer?.invalidate()
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1
                self.transform = .identity
            },
            completion: { _ in
                self.isAnimating = false
                
                // Set up auto-dismiss timer if duration is specified
                if let duration = duration {
                    self.dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                        self?.viewModel.hide()
                    }
                }
            }
        )
    }
    
    private func hideWithAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Cancel any existing timer
        dismissTimer?.invalidate()
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: 50).scaledBy(x: 0.95, y: 0.95)
            },
            completion: { _ in
                self.isAnimating = false
            }
        )
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
        viewModel.hide()
    }
}

// MARK: - UI Elements Factory
extension FloatingOverlayView {
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }
    
    private static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("FloatingOverlayView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "FloatingOverlayView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Sportsbook Mode
        let sportsbookViewModel = MockFloatingOverlayViewModel.sportsbookMode
        let sportsbookOverlay = FloatingOverlayView(viewModel: sportsbookViewModel)
        sportsbookOverlay.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sportsbookViewModel.show(mode: .sportsbook, duration: 3)
        }

        // Casino Mode
        let casinoViewModel = MockFloatingOverlayViewModel.casinoMode
        let casinoOverlay = FloatingOverlayView(viewModel: casinoViewModel)
        casinoOverlay.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            casinoViewModel.show(mode: .casino, duration: nil)
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(sportsbookOverlay)
        stackView.addArrangedSubview(casinoOverlay)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            // Fixed heights for overlays
            sportsbookOverlay.heightAnchor.constraint(equalToConstant: 60),
            casinoOverlay.heightAnchor.constraint(equalToConstant: 60)
        ])

        return vc
    }
}

#endif
