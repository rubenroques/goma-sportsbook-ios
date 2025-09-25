//
//  HeaderTextView.swift
//  GomaUI
//
//  Created by Assistant on 2025-01-27.
//

import UIKit

public class HeaderTextView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    // MARK: ViewModel
    private let viewModel: HeaderTextViewViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: HeaderTextViewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
        self.setupBindings()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
    }
    
    // MARK: Functions
    public func configure() {
        self.titleLabel.text = viewModel.title
        
    }
    
    private func setupBindings() {
        self.viewModel.refreshData = { [weak self] in
            self?.configure()
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension HeaderTextView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Title Label
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8)
        ])
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("HeaderTextView Examples") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.systemBackground
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        // Default style
        let defaultViewModel = MockHeaderTextViewViewModel()
        defaultViewModel.updateTitle("Suggested Events")
        let defaultView = HeaderTextView(viewModel: defaultViewModel)
        defaultView.configure()
        
        stackView.addArrangedSubview(defaultView)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}
#endif
