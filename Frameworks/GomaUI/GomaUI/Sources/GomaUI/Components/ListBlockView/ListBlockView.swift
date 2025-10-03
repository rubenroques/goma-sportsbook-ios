//
//  ListBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class ListBlockView: UIView {
    
    // MARK: Private properties
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
        self.defaultIconView.layer.cornerRadius = self.defaultIconView.frame.width / 2
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
            self.defaultIconView.isHidden = true
            self.counterLabel.isHidden = true
        } else {
            self.defaultIconView.isHidden = false
            self.counterLabel.text = self.viewModel.counter
            self.counterLabel.isHidden = false
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
    }
}

// MARK: - Subviews Initialization and Setup
extension ListBlockView {
    
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
        self.addSubview(self.iconImageView)
        self.addSubview(self.defaultIconView)
        self.defaultIconView.addSubview(self.counterLabel)
        self.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 56),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 56),
            self.iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            self.defaultIconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.defaultIconView.widthAnchor.constraint(equalToConstant: 56),
            self.defaultIconView.heightAnchor.constraint(equalToConstant: 56),
            self.defaultIconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            self.counterLabel.leadingAnchor.constraint(equalTo: self.defaultIconView.leadingAnchor, constant: 5),
            self.counterLabel.trailingAnchor.constraint(equalTo: self.defaultIconView.trailingAnchor, constant: -5),
            self.counterLabel.centerYAnchor.constraint(equalTo: self.defaultIconView.centerYAnchor),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
