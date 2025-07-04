//
//  TransactionVerificationView.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

public final class TransactionVerificationView: UIView {
    
    // MARK: - UI Components
    private lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var highlightedTextView: HighlightedTextView = {
        let textView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    // MARK: - Properties
    private let viewModel: TransactionVerificationViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: TransactionVerificationViewModelProtocol = MockTransactionVerificationViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockTransactionVerificationViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        
        addSubview(topImageView)
        addSubview(titleLabel)
        addSubview(highlightedTextView)
        addSubview(bottomImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top image view
            topImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            topImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topImageView.widthAnchor.constraint(equalToConstant: 40),
            topImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Highlighted text view
            highlightedTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            highlightedTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            highlightedTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Bottom image view
            bottomImageView.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 32),
            bottomImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bottomImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bottomImageView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomImageView.heightAnchor.constraint(equalToConstant: 200)
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
    
    private func configure(with data: TransactionVerificationData) {
        titleLabel.text = data.title
                
        if let topImage = UIImage(named: data.topImage ?? "") {
            topImageView.image = topImage

        }
        else if let topImage = UIImage(systemName: data.topImage ?? "") {
            topImageView.image = topImage

        }
        
        if let bottomImage = UIImage(named: data.bottomImage ?? "") {
            bottomImageView.image = bottomImage

        }
        else if let bottomImage = UIImage(systemName: data.bottomImage ?? "") {
            bottomImageView.image = bottomImage

        }
        
        topImageView.isHidden = data.topImage == nil
        bottomImageView.isHidden = data.bottomImage == nil
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        TransactionVerificationView(viewModel: MockTransactionVerificationViewModel.defaultMock)
    }
    .background(Color(StyleProvider.Color.backgroundColor))
    .padding()
}

@available(iOS 17.0, *)
#Preview("Simple") {
    PreviewUIView {
        TransactionVerificationView(viewModel: MockTransactionVerificationViewModel.simpleMock)
    }
    .background(Color(StyleProvider.Color.backgroundColor))
    .padding()
}
#endif
