//
//  TitleBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

public class TitleBlockView: UIView {
    
    // MARK: Private properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private let viewModel: TitleBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: TitleBlockViewModelProtocol) {
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
        self.titleLabel.textColor = StyleProvider.Color.highlightPrimary
        self.titleLabel.textAlignment = self.viewModel.isCentered ? .center : .left
    }
    
    // MARK: Functions
    private func configure() {
        self.titleLabel.text = self.viewModel.title
    }
}

// MARK: - Subviews Initialization and Setup
extension TitleBlockView {
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.titleLabel)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
