//
//  ListBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

class ListBlockView: UIView {

    // MARK: Private properties
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var stackView: UIStackView = Self.createStackView()

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
        
        self.iconImageView.backgroundColor = .clear
        
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func configure(iconName: String, views: [UIView]) {
        
        if let imageUrl = URL(string: iconName) {
            self.iconImageView.kf.setImage(with: imageUrl)
        }
        
        for viewItem in views {
            self.stackView.addArrangedSubview(viewItem)
        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }

}

extension ListBlockView {
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }
    
    func setupSubviews() {
        
        self.addSubview(self.iconImageView)
        self.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 30),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 30),
            self.iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
            
        ])
    }
}
