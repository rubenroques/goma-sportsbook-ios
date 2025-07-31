//
//  LeagueOptionRowView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit

public class LeagueOptionRowView: UIView {
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
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
        
    public var isSelected: Bool = false {
        didSet {
            updateSelectedState()
        }
    }
    
    public var didTappedOption: ((LeagueOption) -> Void)?
    
    public var leagueOption: LeagueOption?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        NSLayoutConstraint.activate([
            leftIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            leftIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftIndicatorView.widthAnchor.constraint(equalToConstant: 4),
            
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateSelectedState() {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear

        leftIndicatorView.isHidden = !isSelected
        
        iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        
        titleLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 14) : StyleProvider.fontWith(type: .regular, size: 14)
        
        countLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 12) : StyleProvider.fontWith(type: .regular, size: 12)
        countLabel.textColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary

    }
    
    @objc private func handleTap() {
        if let option = leagueOption {
            didTappedOption?(option)
        }
    }
    
    // MARK: - Public Methods
    public func configure(with option: LeagueOption) {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear
        leagueOption = option
        leftIndicatorView.isHidden = !isSelected
        iconImageView.image = UIImage(named: option.icon ?? "")
        iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        titleLabel.text = option.title
        countLabel.text = option.count > 0 ? String(option.count) : "No Events"
    }
    
}
