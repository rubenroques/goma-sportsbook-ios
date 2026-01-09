//
//  StackViewBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class StackViewBlockView: UIView {
    
    // MARK: Private properties
    private lazy var stackView: UIStackView = Self.createStackView()
    private let viewModel: StackViewBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: StackViewBlockViewModelProtocol) {
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
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func configure() {
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
extension StackViewBlockView {
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }
    
    private func setupSubviews() {
        self.addSubview(self.stackView)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
}
