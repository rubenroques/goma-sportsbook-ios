//
//  DescriptionBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

public class DescriptionBlockView: UIView {
    
    // MARK: Private properties
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private let viewModel: DescriptionBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: DescriptionBlockViewModelProtocol) {
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
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.descriptionLabel.textColor = StyleProvider.Color.highlightSecondaryContrast
    }
    
    // MARK: Functions
    private func configure() {
        self.descriptionLabel.text = self.viewModel.description
    }
}

// MARK: - Subviews Initialization and Setup
extension DescriptionBlockView {
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.descriptionLabel)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
