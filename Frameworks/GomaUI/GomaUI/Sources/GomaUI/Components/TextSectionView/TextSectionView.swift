//
//  TextSectionView.swift
//  GomaUI
//
//  Created by Claude on 06/11/2025.
//

import UIKit
import Combine

public final class TextSectionView: UIView {
    
    // MARK: - Private properties
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    
    private let viewModel: TextSectionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    public init(viewModel: TextSectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addSubview(self.containerStackView)
        self.containerStackView.addArrangedSubview(self.titleLabel)
        self.containerStackView.addArrangedSubview(self.descriptionLabel)
        self.initConstraints()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.contentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.configure(with: content)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(with content: TextSectionContent) {
        self.titleLabel.text = content.title
        self.descriptionLabel.text = content.description
        self.titleLabel.textColor = content.titleTextColor
        self.descriptionLabel.textColor = content.descriptionTextColor
        self.titleLabel.font = content.titleFont
        self.descriptionLabel.font = content.descriptionFont
        self.containerStackView.spacing = content.spacing
    }
}

// MARK: - Subviews Initialization and Setup
extension TextSectionView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

// MARK: - Preview
import SwiftUI

@available(iOS 17.0, *)
#Preview("Text Section") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        let viewModel = MockTextSectionViewModel.default
        let sectionView = TextSectionView(viewModel: viewModel)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(sectionView)
        
        NSLayoutConstraint.activate([
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        return vc
    }
}

