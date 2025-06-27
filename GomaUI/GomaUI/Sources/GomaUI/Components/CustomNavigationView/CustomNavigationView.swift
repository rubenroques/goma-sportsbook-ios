//
//  CustomNavigationView.swift
//  GomaUI
//
//  Created by André Lascas on 12/06/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

public final class CustomNavigationView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = StyleProvider.Color.allWhite
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: CustomNavigationViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    public var onCloseTapped: (() -> Void) = { }
    
    // MARK: - Initialization
    public init(viewModel: CustomNavigationViewModelProtocol = MockCustomNavigationViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockCustomNavigationViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Logo image view
            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            logoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            
            // Close button
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func configure(with data: CustomNavigationData) {
        
        if let backgroundColor = data.backgroundColor {
            containerView.backgroundColor = backgroundColor
        }
        
        if let logoImage = data.logoImage {
            logoImageView.image = UIImage(named: logoImage)
        }
        
        if let closeIcon = data.closeIcon {
            let closeIconImage = UIImage(named: data.closeIcon ?? "")
            
            closeButton.setImage(closeIconImage, for: .normal)
        }
        
        if let closeButtonBackgroundColor = data.closeButtonBackgroundColor {
            closeButton.backgroundColor = closeButtonBackgroundColor
        }
        
        if let closeIconTintColor = data.closeIconTintColor {
            closeButton.tintColor = closeIconTintColor
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        onCloseTapped()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PreviewUIView {
                CustomNavigationView(viewModel: MockCustomNavigationViewModel.defaultMock)
            }
            .frame(height: 80)
            .previewDisplayName("Betsson Style")
            
            PreviewUIView {
                CustomNavigationView(viewModel: MockCustomNavigationViewModel.blueMock)
            }
            .frame(height: 80)
            .previewDisplayName("Blue Style")
        }
        .frame(maxHeight: 280)
    }
}
#endif
