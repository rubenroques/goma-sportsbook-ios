//
//  ListBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class ListBlockView: UIView {
    
    // MARK: Private properties
    private lazy var contentStackView: UIStackView = Self.createContainerStackView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var defaultIconView: UIView = Self.createDefaultIconView()
    private lazy var counterLabel: UILabel = Self.createCounterLabel()
    private lazy var stackView: UIStackView = Self.createStackView()
    private let viewModel: ListBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ListBlockViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.defaultIconView.layer.cornerRadius = 28
        self.defaultIconView.clipsToBounds = true
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.iconImageView.backgroundColor = .clear
        self.defaultIconView.backgroundColor = .clear
        self.defaultIconView.layer.borderColor = StyleProvider.Color.highlightSecondaryContrast.cgColor
        self.counterLabel.textColor = StyleProvider.Color.highlightSecondaryContrast
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func configure() {
        if let imageUrl = URL(string: self.viewModel.iconUrl), !self.viewModel.iconUrl.isEmpty {
            // Note: In a real implementation, you would use an image loading library like Kingfisher
            // For now, we'll set a placeholder or system image
            self.iconImageView.image = UIImage(systemName: "star.fill")
            self.contentStackView.addArrangedSubview(self.iconImageView)
        } else {
            self.defaultIconView.isHidden = false
            self.counterLabel.text = self.viewModel.counter
            self.counterLabel.isHidden = false
            self.contentStackView.addArrangedSubview(self.defaultIconView)
        }
        
        // Clear existing arranged subviews
        for arrangedSubview in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        // Add views from viewModel
        for view in self.viewModel.views {
            self.stackView.addArrangedSubview(view)
        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
        self.contentStackView.addArrangedSubview(self.stackView)
    }
}

// MARK: - Subviews Initialization and Setup
extension ListBlockView {
    
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createDefaultIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.isHidden = true
        return view
    }
    
    private static func createCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 24)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }
    
    private func setupSubviews() {
        self.addSubview(self.contentStackView)
        self.defaultIconView.addSubview(counterLabel)

        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Content Stack view - frame
            self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16),
            self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Default Icon view - frame
            self.defaultIconView.widthAnchor.constraint(equalToConstant: 56),
            self.defaultIconView.heightAnchor.constraint(equalToConstant: 56),
            
            // Icon Image view - frame
            self.iconImageView.widthAnchor.constraint(equalToConstant: 56),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 56),
            
            // Counter label - center to `defaultIconView`
            self.counterLabel.leadingAnchor.constraint(equalTo: self.defaultIconView.leadingAnchor, constant: 5),
            self.counterLabel.trailingAnchor.constraint(equalTo: self.defaultIconView.trailingAnchor, constant: -5),
            self.counterLabel.centerYAnchor.constraint(equalTo: self.defaultIconView.centerYAnchor),
        ])
    }
}
