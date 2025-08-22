//
//  SportCardView.swift
//  GomaUI
//
//  Created by André Lascas on 23/05/2025.
//

import Foundation
import UIKit

public class SportCardView: UIView {
    // MARK: - Properties
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.textPrimary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    public var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    public var onTap: ((String) -> Void)?
    public let viewModel: SportCardViewModelProtocol

    // MARK: - Initialization
    public init(viewModel: SportCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundSecondary
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
        ])
        
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        backgroundColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.backgroundSecondary
        iconImageView.tintColor = isSelected ? StyleProvider.Color.buttonTextPrimary : StyleProvider.Color.textPrimary
        titleLabel.textColor = isSelected ? StyleProvider.Color.buttonTextPrimary : StyleProvider.Color.textPrimary
    }
    
    @objc private func handleTap() {
        onTap?(self.viewModel.sportFilter.id)
    }
    
    // MARK: - Public Methods
    public func configure() {
        titleLabel.text = self.viewModel.sportFilter.title
        
        if let sportImage = UIImage(named: self.viewModel.sportFilter.icon ?? "") {
            iconImageView.image = sportImage.withRenderingMode(.alwaysTemplate)
        }
        else {
            iconImageView.image = UIImage(named: "sport_type_icon_default")?.withRenderingMode(.alwaysTemplate)
        }
    }
}
