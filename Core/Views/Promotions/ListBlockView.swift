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
    private lazy var defaultIconView: UIView = Self.createDefaultIconView()
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
        
        self.defaultIconView.layer.cornerRadius = self.defaultIconView.frame.width / 2
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.iconImageView.backgroundColor = .clear
        
        self.defaultIconView.backgroundColor = UIColor.App.highlightPrimary
        
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func configure(iconName: String, views: [UIView]) {
        
        if let imageUrl = URL(string: iconName) {
            self.iconImageView.kf.setImage(with: imageUrl)
        }
        else {
            self.defaultIconView.isHidden = false
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
    
    private static func createDefaultIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
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
        self.addSubview(self.defaultIconView)
        self.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 40),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 40),
            self.iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            self.defaultIconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.defaultIconView.widthAnchor.constraint(equalToConstant: 40),
            self.defaultIconView.heightAnchor.constraint(equalToConstant: 40),
            self.defaultIconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
            
        ])
    }
}
