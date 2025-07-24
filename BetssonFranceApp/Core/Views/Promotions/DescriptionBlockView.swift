//
//  DescriptionBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

class DescriptionBlockView: UIView {

    // MARK: Private properties
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()

    // MARK: Lifetime and cycle
    init() {
                
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Functions
    func configure(description: String) {
        self.descriptionLabel.text = description
    }

}

extension DescriptionBlockView {
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .regular, size: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    func setupSubviews() {
        
        self.addSubview(self.descriptionLabel)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
