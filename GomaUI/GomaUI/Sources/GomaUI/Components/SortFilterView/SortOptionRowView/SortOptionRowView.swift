//
//  SortOptionRowView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit

public class SortOptionRowView: UIView {
    // MARK: - Properties
    private let leftIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.isHidden = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
            return label
        return label
    }()
    
    private let radioButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = StyleProvider.Color.allWhite
        return button
    }()
    
    private let selectedDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.allWhite
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()
    
    public let viewModel: SortOptionRowViewModelProtocol

    public var isSelected: Bool = false {
        didSet {
            updateSelectedState()
        }
    }
    
    public var didTappedOption: ((SortOption) -> Void)?
    
    // MARK: - Initialization
    public init(viewModel: SortOptionRowViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(leftIndicatorView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(radioButton)
        radioButton.addSubview(selectedDot)
        
        NSLayoutConstraint.activate([
            leftIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            leftIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftIndicatorView.widthAnchor.constraint(equalToConstant: 4),
            
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -4),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: -12),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            radioButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 20),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            
            selectedDot.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
            selectedDot.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
            selectedDot.widthAnchor.constraint(equalToConstant: 12),
            selectedDot.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        radioButton.addGestureRecognizer(tapGesture)
    }
    
    private func updateSelectedState() {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear

        leftIndicatorView.isHidden = !isSelected
        
        if viewModel.sortOption.iconTintChange {
            iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        }
        
        titleLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 14) : StyleProvider.fontWith(type: .regular, size: 14)
        
        countLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 12) : StyleProvider.fontWith(type: .regular, size: 12)
        countLabel.textColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary

        selectedDot.isHidden = !isSelected
        
        radioButton.layer.borderColor = isSelected ?
        StyleProvider.Color.highlightPrimary.cgColor : UIColor.black.cgColor
        
        radioButton.backgroundColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.allWhite
    }
    
    @objc private func handleTap() {
        let sortOption = self.viewModel.sortOption
        
        didTappedOption?(sortOption)
        
    }
    
    // MARK: - Public Methods
    public func configure() {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear
        
        leftIndicatorView.isHidden = !isSelected
        
        if viewModel.sortOption.iconTintChange {
            iconImageView.image = UIImage(named: self.viewModel.sortOption.icon ?? "")?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        }
        else {
            iconImageView.image = UIImage(named: self.viewModel.sortOption.icon ?? "")
        }
        
        titleLabel.text = self.viewModel.sortOption.title
        
        countLabel.text = self.viewModel.sortOption.count > 0 ? String(self.viewModel.sortOption.count) : "No Events"
    }
    
}
