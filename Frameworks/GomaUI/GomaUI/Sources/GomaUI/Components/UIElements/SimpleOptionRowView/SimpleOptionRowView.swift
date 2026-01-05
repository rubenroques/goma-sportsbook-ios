//
//  SimpleOptionRowView.swift
//  GomaUI
//
//  Created by Claude on 07/11/2025.
//

import UIKit

public final class SimpleOptionRowView: UIView {
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var radioButton: UIButton = Self.createRadioButton()
    private lazy var selectedDot: UIView = Self.createSelectedDot()
    
    // MARK: - Properties
    public let viewModel: SimpleOptionRowViewModelProtocol
    public var isSelected: Bool = false {
        didSet { updateSelectedState() }
    }
    public var didTapOption: ((SortOption) -> Void)?
    
    // MARK: - Initializers
    public init(viewModel: SimpleOptionRowViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func commonInit() {
        addSubview(titleLabel)
        addSubview(radioButton)
        radioButton.addSubview(selectedDot)
        setupConstraints()
        setupInteractions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: radioButton.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            radioButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 20),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            
            selectedDot.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
            selectedDot.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
            selectedDot.widthAnchor.constraint(equalToConstant: 12),
            selectedDot.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        radioButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    // MARK: - Configuration
    public func configure() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        titleLabel.text = viewModel.option.title
        updateSelectedState()
    }
    
    private func updateSelectedState() {
        selectedDot.isHidden = !isSelected
        radioButton.layer.borderColor = isSelected ? StyleProvider.Color.highlightPrimary.cgColor : StyleProvider.Color.iconSecondary.cgColor
        radioButton.backgroundColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.allWhite
    }
    
    @objc private func handleTap() {
        didTapOption?(viewModel.option)
    }
}

// MARK: - Subview Factories
private extension SimpleOptionRowView {
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    static func createRadioButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.layer.borderColor = StyleProvider.Color.iconSecondary.cgColor
        button.backgroundColor = StyleProvider.Color.allWhite
        return button
    }
    
    static func createSelectedDot() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.allWhite
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Simple Option Row") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        let sortOption = SortOption(
            id: "none",
            icon: nil,
            title: "Receive personalized offers",
            count: -1,
            iconTintChange: false
        )
        let viewModel = MockSimpleOptionRowViewModel(option: sortOption)
        let rowView = SimpleOptionRowView(viewModel: viewModel)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.isSelected = true
        rowView.configure()
        
        vc.view.addSubview(rowView)
        
        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            rowView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            rowView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            rowView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        return vc
    }
}
#endif
