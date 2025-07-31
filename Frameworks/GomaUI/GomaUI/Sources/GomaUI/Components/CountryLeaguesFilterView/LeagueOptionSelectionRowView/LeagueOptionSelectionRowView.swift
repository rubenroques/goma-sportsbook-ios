//
//  LeagueOptionSelectionRowView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit

public class LeagueOptionSelectionRowView: UIView {
    // MARK: - Properties
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        return view
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
            
    public var isSelected: Bool = false {
        didSet {
            updateSelectedState()
        }
    }
        
    public var didTappedOption: ((LeagueOption) -> Void)?
    public let viewModel: LeagueOptionSelectionRowViewModelProtocol
        
    // MARK: - Initialization
    public init(viewModel: LeagueOptionSelectionRowViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(radioButton)
        radioButton.addSubview(selectedDot)
        
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            countLabel.trailingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: -12),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            radioButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 20),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            
            selectedDot.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
            selectedDot.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
            selectedDot.widthAnchor.constraint(equalToConstant: 12),
            selectedDot.heightAnchor.constraint(equalToConstant: 12),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        radioButton.addGestureRecognizer(tapGesture)
    }
    
    private func updateSelectedState() {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear
        
        titleLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 14) : StyleProvider.fontWith(type: .regular, size: 14)
        
        countLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 12) : StyleProvider.fontWith(type: .regular, size: 12)
        countLabel.textColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary

        selectedDot.isHidden = !isSelected
        
        radioButton.layer.borderColor = isSelected ?
        StyleProvider.Color.highlightPrimary.cgColor : UIColor.black.cgColor
        
        radioButton.backgroundColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.allWhite
    }
    
    @objc private func handleTap() {
        let option = self.viewModel.leagueOption
            
        didTappedOption?(option)
        
    }
    
    // MARK: - Public Methods
    public func configure(selectedLeagueId: String) {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear
        titleLabel.text = viewModel.leagueOption.title
        countLabel.text = viewModel.leagueOption.count > 0 ? String(viewModel.leagueOption.count) : "No Events"
        
        self.isSelected = viewModel.leagueOption.id == selectedLeagueId ? true : false
    }
    
}
